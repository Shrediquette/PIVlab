classdef videoinput < handle
    %VIDEOINPUT Simulated camera for tests without hardware (shadows the Image Acquisition Toolbox).
    %   Only on the path in the capture tests (unittests/mocks_imaq). The cameras are listed in
    %   getappdata(0,'mock_imaq') (see mock_imaq_setup): device names, serial numbers, trigger rate.
    %   Frames are made when they are due (elapsed time x frame rate), by a hidden timer and whenever a
    %   property such as FramesAcquired is read. Every frame carries its trigger number in pixels (1,1)
    %   (low byte) and (1,2) (high byte) and the camera number of the device list in pixel (1,3).
    %   Hardware trigger: frames at the trigger rate of mock_imaq (no laser needed); a trigger in
    %   mock_imaq.drop{camera} is missed by that camera. Live image (TriggerMode 'Off'): frames at
    %   min(AcquisitionFrameRate, 1/ExposureTime). preview() calls the UpdatePreviewWindowFcn of the image
    %   (appdata) for every frame, or sets CData, like imaq.
    properties
        AdaptorName = 'gentl'
        DeviceID = 1
        VideoFormat = 'Mono8'
        Tag = ''
        Name = ''
        ROIPosition = [0 0 1936 1216]
        FramesPerTrigger = 10
        PreviewFullBitDepth = 'Off'
        ErrorFcn = ''
        Source
        TriggerType = 'immediate'
        Type = 'videoinput'
    end
    properties (Dependent)
        FramesAcquired
        FramesAvailable
        Eventlog
    end
    properties (Hidden)
        camera_index = 1
        acquired = 0          % frames acquired since start
        logged = {}           % frames in memory (getdata / peekdata)
        logged_times = []
        triggers_done = 0     % triggers handled since start
        running = false
        previewing = false
        preview_image = []
        started = []          % tic of start / preview
        live_frames_done = 0
        frame_timer = []
        template = []
        last_frame = []
        preview_calls = 0     % frames handed to the preview (test statistics)
        updating = false
    end
    methods
        function obj = videoinput(adaptor, device_id, video_format)
            reg = getappdata(0, 'mock_imaq');
            obj.AdaptorName = adaptor;
            obj.DeviceID = device_id;
            obj.VideoFormat = video_format;
            obj.camera_index = device_id;
            obj.Source = mock_imaq_source(reg.devices(device_id).serial);
            obj.Name = [video_format '-' adaptor '-' int2str(device_id)];
            objects = getappdata(0, 'mock_imaq_objects');
            objects{end + 1} = obj;
            setappdata(0, 'mock_imaq_objects', objects);
            pause(reg.open_time); % opening a real camera takes ~2 s
        end
        function delete(obj)
            stop_timer(obj);
        end
        function n = get.FramesAcquired(obj)
            update(obj);
            n = obj.acquired;
        end
        function n = get.FramesAvailable(obj)
            update(obj);
            n = numel(obj.logged);
        end
        function e = get.Eventlog(obj)
            e = [];
            if obj.running || obj.acquired > 0
                e = struct('Type', 'Start');
            end
        end
        function varargout = subsref(obj, s)
            % like imaq: vid.Source.Property in one expression is an error (src = vid.Source; src.Property works)
            for i = 1:numel(s) - 1
                if strcmp(s(i).type, '.') && strcmp(s(i).subs, 'Source') && strcmp(s(i + 1).type, '.')
                    error('mock:imaq:chainedSource', 'Inconsistently placed ''.'' in subscript expression (imaq does not allow vid.Source.%s).', s(i + 1).subs);
                end
            end
            [varargout{1:nargout}] = builtin('subsref', obj, s);
        end
        function s = get(obj, name)
            % get(vid) gives a struct of the properties (the Source in it is the real handle, as in imaq)
            if nargin > 1
                s = obj.(name);
                return
            end
            s = struct('Source', obj.Source, 'VideoFormat', obj.VideoFormat, 'Tag', obj.Tag, 'Name', obj.Name, ...
                'ROIPosition', obj.ROIPosition, 'FramesPerTrigger', obj.FramesPerTrigger, 'PreviewFullBitDepth', obj.PreviewFullBitDepth);
        end
        function triggerconfig(obj, type)
            obj.TriggerType = type;
        end
        function start(obj)
            obj.running = true;
            obj.acquired = 0;
            obj.triggers_done = 0;
            obj.logged = {};
            obj.logged_times = [];
            obj.started = tic;
            start_timer(obj);
        end
        function stop(obj)
            update(obj);
            obj.running = false;
            if ~obj.previewing
                stop_timer(obj);
            end
        end
        function r = isrunning(obj)
            update(obj);
            r = obj.running;
        end
        function preview(obj, himage)
            obj.preview_image = himage;
            obj.previewing = true;
            obj.live_frames_done = 0;
            if isempty(obj.started) || ~obj.running
                obj.started = tic;
            end
            start_timer(obj);
        end
        function stoppreview(obj)
            obj.previewing = false;
            obj.preview_image = [];
            if ~obj.running
                stop_timer(obj);
            end
        end
        function flushdata(obj)
            update(obj);
            obj.logged = {};
            obj.logged_times = [];
        end
        function data = peekdata(obj, n)
            update(obj);
            m = numel(obj.logged);
            data = cat(4, obj.logged{max(1, m - n + 1):m});
        end
        function [data, times] = getdata(obj, n)
            update(obj);
            if n > numel(obj.logged)
                error('imaq:getdata:timeout', 'mock: only %d frames available', numel(obj.logged));
            end
            data = cat(4, obj.logged{1:n});
            times = obj.logged_times(1:n)';
            obj.logged(1:n) = [];
            obj.logged_times(1:n) = [];
        end
        function update(obj)
            % make the frames that are due now (not re-entrant: the hidden timer can call it while it runs)
            reg = getappdata(0, 'mock_imaq');
            if isempty(obj.started) || obj.updating
                return
            end
            obj.updating = true;
            update_frames(obj, reg);
            obj.updating = false;
        end
        function update_frames(obj, reg)
            elapsed = toc(obj.started);
            hardware = strcmp(obj.TriggerType, 'hardware') && strcmp(obj.Source.TriggerMode, 'On');
            if obj.running && hardware
                due = floor(elapsed * reg.trigger_fps);
                new_frames = 0;
                while obj.triggers_done < due && obj.acquired < obj.FramesPerTrigger
                    obj.triggers_done = obj.triggers_done + 1;
                    if any(reg.drop{obj.camera_index} == obj.triggers_done)
                        continue % this camera misses the trigger
                    end
                    frame = make_frame(obj, obj.triggers_done);
                    obj.acquired = obj.acquired + 1;
                    obj.logged{end + 1} = frame;
                    obj.logged_times(end + 1) = obj.triggers_done / reg.trigger_fps;
                    new_frames = new_frames + 1;
                end
                if obj.acquired >= obj.FramesPerTrigger
                    obj.running = false;
                end
                if obj.previewing && new_frames > 0
                    show_preview(obj, obj.logged{end}, new_frames);
                end
            elseif obj.previewing && ~hardware
                rate = 1e6 / obj.Source.ExposureTime;
                if strcmp(obj.Source.AcquisitionFrameRateEnable, 'True')
                    rate = min(rate, obj.Source.AcquisitionFrameRate);
                end
                rate = min(rate, 160);
                due = floor(elapsed * rate);
                if due > obj.live_frames_done
                    n_new = due - obj.live_frames_done;
                    obj.live_frames_done = due;
                    show_preview(obj, make_frame(obj, due), n_new);
                end
            end
        end
    end
    methods (Hidden)
        function frame = make_frame(obj, number)
            w = obj.ROIPosition(3);
            h = obj.ROIPosition(4);
            if isempty(obj.template) || ~isequal(size(obj.template), [h w])
                reg = getappdata(0, 'mock_imaq');
                if isfield(reg, 'images') && numel(reg.images) >= obj.camera_index && ~isempty(reg.images{obj.camera_index})
                    % a real image (e.g. a board image of a stereo recording), cut / padded to the ROI
                    I = im2double(imread(reg.images{obj.camera_index}));
                    t = zeros(h, w);
                    hh = min(h, size(I, 1));
                    ww = min(w, size(I, 2));
                    t(1:hh, 1:ww) = I(1:hh, 1:ww, 1);
                else
                    rng(obj.camera_index, 'twister');
                    t = zeros(h, w);
                    t(rand(h, w) > 0.98) = 1;
                    t = imgaussfilt(t, 1) * 3;
                end
                if strcmp(obj.VideoFormat, 'Mono8')
                    obj.template = uint8(min(t, 1) * 200 + 10);
                else
                    obj.template = uint16(min(t, 1) * 3500 + 40);
                end
            end
            frame = obj.template;
            reg = getappdata(0, 'mock_imaq');
            if mod(number, 2) == 0 && isfield(reg, 'pair_shift') && any(reg.pair_shift ~= 0)
                frame = circshift(frame, reg.pair_shift); % B frame of a PIV pair: the particles moved
            end
            frame(1, 1) = mod(number, 256);
            frame(1, 2) = floor(number / 256);
            frame(1, 3) = obj.camera_index;
            obj.last_frame = frame;
        end
        function show_preview(obj, frame, n_frames)
            himage = obj.preview_image;
            if isempty(himage) || ~isvalid(himage)
                return
            end
            fcn = getappdata(himage, 'UpdatePreviewWindowFcn');
            for i = 1:min(n_frames, 20) % imaq hands every frame to the preview (as far as MATLAB keeps up)
                obj.preview_calls = obj.preview_calls + 1;
                if isempty(fcn)
                    set(himage, 'CData', frame);
                else
                    event = struct('Data', frame, 'Resolution', [size(frame, 2) size(frame, 1)], 'Status', '', 'Timestamp', '');
                    fcn(obj, event, himage);
                end
            end
        end
        function start_timer(obj)
            if isempty(obj.frame_timer) || ~isvalid(obj.frame_timer)
                % hidden: control_simple_sync_serial deletes all visible timers
                obj.frame_timer = timer('ObjectVisibility', 'off', 'ExecutionMode', 'fixedSpacing', 'Period', 0.02, ...
                    'BusyMode', 'drop', 'TimerFcn', {@videoinput.timer_tick, obj}, 'Tag', 'mock_imaq_timer');
            end
            if strcmp(obj.frame_timer.Running, 'off')
                start(obj.frame_timer);
            end
        end
        function stop_timer(obj)
            if ~isempty(obj.frame_timer) && isvalid(obj.frame_timer)
                stop(obj.frame_timer);
                delete(obj.frame_timer);
            end
            obj.frame_timer = [];
        end
    end
    methods (Static, Hidden)
        function timer_tick(~, ~, obj)
            if isvalid(obj)
                update(obj);
            end
        end
    end
end
