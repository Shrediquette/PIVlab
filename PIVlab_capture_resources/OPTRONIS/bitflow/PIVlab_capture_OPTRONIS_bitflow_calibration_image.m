function [OutputError,ima_out,frame_nr_display] = PIVlab_capture_OPTRONIS_bitflow_calibration_image(img_amount,exposure_time,ROI_OPTRONIS,n_cameras)
% Calibration / live image for the OPTRONIS Cyclone on the BitFlow grabber, one camera or two side by side
% (stereo acquisition, n_cameras = 2): free run at 20 frames/s.
% img_amount: number of camera frames to show (inf = until Stop, 1 = one image for the ROI selection).
% ima_out: the last frame; stereo: cell {camera 1, camera 2}.
% The frames are drawn at a limited rate (PIVlab_capture_rate_limited_preview, acquisition.display_rate) and
% the overlays are computed at that rate, not for every camera frame.
if nargin < 4
    n_cameras = 1;
end
OutputError=0;
hgui=getappdata(0,'hgui');
ima_out=[];

OPTRONIS_bits = gui.camera_setting('OPTRONIS_bits');
if isempty(OPTRONIS_bits) || ~isnumeric(OPTRONIS_bits)
    OPTRONIS_bits=8;
    gui.set_camera_setting('OPTRONIS_bits', OPTRONIS_bits);
end
bitmode = OPTRONIS_bits;

OPTRONIS_gain = gui.camera_setting('OPTRONIS_gain');
if isempty(OPTRONIS_gain)
    OPTRONIS_gain=1;
end
if bitmode==8
    camfilemode='PIVMode8bit'; % funktioniert ohne Fehlermeldung, timing + dropped frames nicht kontrolliert.
else
    camfilemode='PIVMode10bit';
end

%% Prepare cameras
[OPTRONIS_vids,imaq_error] = PIVlab_capture_OPTRONIS_bitflow_open(camfilemode,n_cameras,4);
if imaq_error ~= 0
    OutputError=1;
    frame_nr_display=[];
    return
end

%% exposure gap of the camera model
OPTRONIS_src = OPTRONIS_vids{1}.Source;
try
    OPTRONIS_src.BFGTLNodeName = 'AcquisitionStop';
    OPTRONIS_src.BFGTLNodeValueStr = '1';
    OPTRONIS_src.BFGTLNodeName = 'DeviceModelName';
    OPTRONIS_name = OPTRONIS_src.BFGTLNodeValueStr;
catch
    OPTRONIS_name = 'Cyclone-2-2000-M';
end
if contains(OPTRONIS_name,'2000')
    disp('Found camera: Cyclone-2-2000-M')
    exposure_gap=2;
elseif contains(OPTRONIS_name,'3500') || contains(OPTRONIS_name,'1HS')
    disp('Found camera: Cyclone-1HS-3500-M')
    exposure_gap=2;
elseif contains(OPTRONIS_name,'25-150') || contains(OPTRONIS_name,'25150')
    disp('Found camera: Cyclone-25-150-M')
    exposure_gap=24;
else
    disp(['camera type unknown: ' OPTRONIS_name])
    exposure_gap=2;
end
if bitmode > 8
    exposure_gap = exposure_gap + 1;
end

preview_framerate=20;
%% Clamp exposure time to valid range for preview frame rate
if exposure_time > 1/preview_framerate*1000^2-exposure_gap
    exposure_time = 1/preview_framerate*1000^2-exposure_gap;
    disp(['Exposure time adjusted to ' num2str(exposure_time) ' µs (' num2str(exposure_time/1000) ' ms)'])
end
if exposure_time < 500
    exposure_time = 500;
    disp(['Exposure time adjusted to ' num2str(exposure_time) ' µs (' num2str(exposure_time/1000) ' ms)'])
end

ROI_OPTRONIS=[ROI_OPTRONIS(1)-1, ROI_OPTRONIS(2)-1, ROI_OPTRONIS(3), ROI_OPTRONIS(4)];
ROI_OPTRONIS(3) = max(64, floor(ROI_OPTRONIS(3)/64)*64); % width must be multiple of 64 (4 CXP links × 16-pixel quantum)
for k=1:n_cameras
    configure_live(OPTRONIS_vids{k},bitmode,ROI_OPTRONIS,preview_framerate,exposure_time,OPTRONIS_gain);
end

%% Prepare axis
PIVlab_axis = gui.retr('pivlab_axis');
[image_handles,frame_nr_display] = acquisition.live_images(n_cameras,[ROI_OPTRONIS(3) ROI_OPTRONIS(4)],2^bitmode);
setappdata(hgui,'image_handles_OPTRONIS',image_handles);
setappdata(hgui,'image_handle_OPTRONIS',image_handles{1});

%% Start camera acquisition and preview
max_rate = preview_framerate;
pixel_budget = 40e6;
set(frame_nr_display,'String','');
for k=1:n_cameras
    OPTRONIS_src = OPTRONIS_vids{k}.Source;
    pause(0.05)
    OPTRONIS_src.BFGTLNodeName = 'AcquisitionStart';
    OPTRONIS_src.BFGTLNodeValueStr = '1';
    pause(0.05)
    OPTRONIS_vids{k}.FramesPerTrigger = 1;
    if bitmode > 8
        set(OPTRONIS_vids{k}, 'PreviewFullBitDepth', 'on');
    end
    %preview() first shows a placeholder image until the first camera frame arrives. The callback only
    %receives real frames, so it counts them: needed for the single-image grab (ROI selection).
    setappdata(image_handles{k},'frames_shown',0);
    setappdata(image_handles{k},'max_display_rate',max_rate);
    setappdata(image_handles{k},'UpdatePreviewWindowFcn',@PIVlab_capture_rate_limited_preview);
    preview(OPTRONIS_vids{k}, image_handles{k})
end
caxis(PIVlab_axis,[0 2^bitmode]); %#ok<CAXIS>
acquisition.apply_camera_view %preview() sets the axes limits to its own image: show the cameras chosen with the CAM button

displayed_img_amount=0;
delaycounter=0; %autofocus state
delaycounter2=0;
delay_time_1=tic;
sharpness_focus_table=[];
sharp_loop_cnt=[];
t0 = tic;
next_update = 0;
while getappdata(hgui,'cancel_capture') ~=1 && displayed_img_amount < img_amount
    if toc(t0) < next_update
        pause(0.01); %sleep and process GUI callbacks instead of spinning
        continue
    end
    rate = acquisition.display_rate(image_handles,max_rate,pixel_budget); %zoom / CAM button change the pixels drawn
    if isequal(getappdata(hgui,'autofocus_enabled'),1) && n_cameras == 1
        rate = max(rate,5); %autofocus: a new frame is needed after each focus step (0.35 s)
        setappdata(image_handles{1},'max_display_rate',rate);
    end
    next_update = toc(t0) + 1/rate;
    frames_shown = inf; %real camera frames of the slowest camera, read BEFORE the frames: they are then real frames if frames_shown >= 1
    for k=1:n_cameras
        frames_shown = min(frames_shown,getappdata(image_handles{k},'frames_shown'));
    end
    acquisition.live_overlays(image_handles,'live'); %sharpness, grid, ChArUco detection
    ima = getappdata(image_handles{1},'frame');
    drawnow limitrate
    if isempty(ima) %no camera frame yet
        continue
    end
    if n_cameras > 1 %autofocus: one camera (one lens controller)
        displayed_img_amount = frames_shown;
        continue
    end

    %% Autofocus
    autofocus_enabled = getappdata(hgui,'autofocus_enabled');

    if autofocus_enabled == 1
        delaycounter=delaycounter+1;
    else
        delaycounter=0;
        delaycounter2=0;
        delay_time_1=tic;
    end

    delay_time=0.5;
    if autofocus_enabled == 1
        if delaycounter>10
            focus_start = getappdata(hgui,'focus_servo_lower_limit');
            focus_end   = getappdata(hgui,'focus_servo_upper_limit');
            amount_of_raw_steps=20;
            fine_step_resolution_increase=8;
            focus_step_raw=round(abs(focus_end-focus_start)/amount_of_raw_steps);
            focus_step_fine=round(1/fine_step_resolution_increase*(abs(focus_end-focus_start)/amount_of_raw_steps));
            if ~exist('sharpness_focus_table','var') || isempty(sharpness_focus_table) || isempty(sharp_loop_cnt)
                sharpness_focus_table=zeros(1,2);
                sharp_loop_cnt=0;
                focus=focus_start;
                raw_finished=0;
                aperture=getappdata(hgui,'aperture');
                lighting=getappdata(hgui,'lighting');
                PIVlab_capture_lensctrl(focus,aperture,lighting)
            end
            if raw_finished==0
                if focus < focus_end
                    if toc(delay_time_1)>=delay_time
                        delay_time_1=tic;
                        sharp_loop_cnt=sharp_loop_cnt+1;
                        [sharpness,~]=PIVlab_capture_sharpness_indicator(ima,0);
                        sharpness_focus_table(sharp_loop_cnt,1)=focus;
                        sharpness_focus_table(sharp_loop_cnt,2)=sharpness;
                        focus=focus+focus_step_raw;
                        PIVlab_capture_lensctrl(focus,aperture,lighting)
                        autofocus_notification(1)
                    end
                else
                    [r,~]=find(sharpness_focus_table==max(sharpness_focus_table(:,2)));
                    focus_peak=sharpness_focus_table(r(1),1);
                    disp(['Best raw focus: ' num2str(focus_peak)])
                    raw_finished=1;
                    focus_start_fine=focus_peak-6*focus_step_raw;
                    focus_end_fine=focus_peak+3*focus_step_raw;
                    if focus_start_fine < focus_start; focus_start_fine=focus_start; end
                    if focus_end_fine   > focus_end;   focus_end_fine=focus_end;     end
                    focus=focus_start_fine;
                    PIVlab_capture_lensctrl(focus,aperture,lighting)
                    sharp_loop_cnt=0;
                    raw_data=[sharpness_focus_table(:,1),normalize(sharpness_focus_table(:,2),'range')];
                    sharpness_focus_table=zeros(1,2);
                end
            end
            if raw_finished==1; delaycounter2=delaycounter2+1; else; delaycounter2=0; end
            if raw_finished==1
                delay_time=0.35;
                if delaycounter2>10
                    if focus < focus_end_fine
                        if toc(delay_time_1)>=delay_time
                            delay_time_1=tic;
                            sharp_loop_cnt=sharp_loop_cnt+1;
                            [sharpness,~]=PIVlab_capture_sharpness_indicator(ima,0);
                            sharpness_focus_table(sharp_loop_cnt,1)=focus;
                            sharpness_focus_table(sharp_loop_cnt,2)=sharpness;
                            focus=focus+focus_step_fine;
                            PIVlab_capture_lensctrl(focus,aperture,lighting)
                            autofocus_notification(1)
                        end
                    else
                        [r,~]=find(sharpness_focus_table==max(sharpness_focus_table(:,2)));
                        focus_peak=sharpness_focus_table(r(1),1);
                        disp(['Best fine focus: ' num2str(focus_peak)])
                        PIVlab_capture_lensctrl(focus_end_fine,aperture,lighting)
                        pause(0.5)
                        PIVlab_capture_lensctrl(focus_start_fine,aperture,lighting)
                        pause(0.5)
                        PIVlab_capture_lensctrl(focus_peak,aperture,lighting)
                        setappdata(hgui,'autofocus_enabled',0);
                        lens_control_window=getappdata(0,'hlens');
                        focus_edit_field=getappdata(lens_control_window,'handle_to_focus_edit_field');
                        set(focus_edit_field,'String',num2str(focus_peak));
                        figure;plot(raw_data(:,1),raw_data(:,2),'Linewidth',2)
                        hold on;plot(sharpness_focus_table(:,1),normalize(sharpness_focus_table(:,2),'range'),'Linewidth',2);hold off
                        title('Focus search');xlabel('Pulsewidth us');ylabel('Sharpness')
                        legend('Coarse search','Fine search');grid on
                    end
                end
            end
        end
    else
        autofocus_notification(0)
        sharpness_focus_table=[];
        sharp_loop_cnt=[];
    end

    displayed_img_amount = frames_shown; %real camera frames (placeholder not counted)
end
ima_out = cell(1,n_cameras);
for k=1:n_cameras
    try
        stoppreview(OPTRONIS_vids{k})
    catch ME
        fprintf('BitFlow cleanup warning (non-fatal): %s\n', ME.message);
    end
    ima_out{k} = getappdata(image_handles{k},'frame');
end
if n_cameras == 1
    ima_out = ima_out{1};
end

function configure_live(OPTRONIS_vid,bitmode,ROI_OPTRONIS,preview_framerate,exposure_time,OPTRONIS_gain)
%free-running camera for the live image (stereo: the same settings for both cameras)
OPTRONIS_src = OPTRONIS_vid.Source;
%% Stop acquisition before changing parameters
bf_set(OPTRONIS_src, 'AcquisitionStop', '1');
pause(0.05)

%% Pixel format
if bitmode==8
    bf_set(OPTRONIS_src, 'PixelFormat', 'Mono8');
elseif bitmode==10
    bf_set(OPTRONIS_src, 'PixelFormat', 'Mono10');
end

%% Set ROI
bf_set(OPTRONIS_src, 'OffsetX', '0');   % zero offsets before changing size to avoid constraint violations
bf_set(OPTRONIS_src, 'OffsetY', '0');
bf_set(OPTRONIS_src, 'Width',   num2str(ROI_OPTRONIS(3)));
bf_set(OPTRONIS_src, 'Height',  num2str(ROI_OPTRONIS(4)));
bf_set(OPTRONIS_src, 'OffsetX', num2str(ROI_OPTRONIS(1)));
bf_set(OPTRONIS_src, 'OffsetY', num2str(ROI_OPTRONIS(2)));
% VideoResolution stays at the BFML default (sensor size); clip to the actual frame size
OPTRONIS_vid.ROIPosition = [0 0 ROI_OPTRONIS(3) ROI_OPTRONIS(4)];

%% Acquisition mode
bf_set(OPTRONIS_src, 'AcquisitionMode', 'Continuous');

%% Counter off for calibration
bf_set(OPTRONIS_src, 'CounterInformation', 'Off');
bf_set(OPTRONIS_src, 'AGain', num2str(OPTRONIS_gain));

%% Exposure and trigger
bf_set(OPTRONIS_src, 'ExposureMode',         'Timed');
bf_set(OPTRONIS_src, 'AcquisitionFrameRate',  num2str(preview_framerate));
bf_set(OPTRONIS_src, 'ExposureTime',          num2str(exposure_time));

%% Configure external trigger via camera Sync In connector
bf_set(OPTRONIS_src, 'SyncInActivation', 'RisingEdge');
OPTRONIS_src.TriggerMode = 'Free Run';

function autofocus_notification(running)
auto_focus_active_hint=findobj('tag', 'auto_focus_active');
if running == 1
    PIVlab_axis=gui.retr('pivlab_axis');
    postix=get(PIVlab_axis,'XLim');
    postiy=get(PIVlab_axis,'YLim');
    bg_col=get(auto_focus_active_hint,'BackgroundColor');
    if ~isempty(bg_col)
        if sum(bg_col)==0.75
            bg_col=[0.05 0.05 0.05];
        else
            bg_col=[0.25 0.25 0.25];
        end
        set(auto_focus_active_hint,'BackgroundColor',bg_col);
    else
        bg_col=[0.25 0.25 0.25];
        text(PIVlab_axis,postix(2)/2,postiy(2)/2,'Autofocus running, please wait...','HorizontalAlignment','center','VerticalAlignment','middle','color','y','fontsize',24,'BackgroundColor',bg_col,'tag','auto_focus_active','margin',10,'Clipping','on');
    end
else
    delete(auto_focus_active_hint);
end
function bf_set(src, name, value)
lastwarn('');
src.BFGTLNodeName     = name;
src.BFGTLNodeValueStr = value;
[w, wid] = lastwarn;
if ~isempty(w)
    fprintf('*** BFGTLNode warning: %-30s = %-20s  [%s]\n', name, value, wid);
end
