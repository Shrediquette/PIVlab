function live_overlays(himg, mode)
%LIVE_OVERLAYS Sharpness, grid and live ChArUco detection on the camera images (one or two cameras).
%   acquisition.live_overlays(himg, mode)
%   himg    image objects of acquisition.live_images; the frames are put in with acquisition.show_frame
%   mode    'live' (live image: also the ChArUco detection) or 'capture' (PIV preview / recording)
%   Called by the camera drivers at their display rate, not for every camera frame (CPU load).
hgui = getappdata(0, 'hgui');
PIVlab_axis = gui.retr('pivlab_axis');
n = numel(himg);
% CPU load: the overlays (sharpness, ChArUco detection) take about 0.1 - 0.2 s with large images. After an
% update, the next one waits at least as long as the last one took, so they use at most half of the time and
% PIVlab stays responsive (Stop button).
timing = getappdata(himg{1}, 'overlay_timing');
if ~isempty(timing) && toc(timing.finished) < timing.duration
    return
end
started = tic;
frames = cell(1, n);
for k = 1:n
    if isvalid(himg{k}) && ~isequal(getappdata(himg{k}, 'hidden'), true) % stereo: only the cameras shown (acquisition.apply_camera_view)
        frames{k} = getappdata(himg{k}, 'frame');
    end
end

%% sharpness indicator
if getappdata(hgui, 'sharpness_enabled') == 1
    if n == 1
        if ~isempty(frames{1})
            PIVlab_capture_sharpness_indicator(frames{1}, 1);
        end
    else
        delete(findobj('tag', 'sharpness_display_text'));
        for k = 1:n
            if ~isempty(frames{k})
                PIVlab_capture_sharpness_indicator(frames{k}, 1, getappdata(himg{k}, 'x_offset'));
            end
        end
    end
else
    delete(findobj('tag', 'sharpness_display_text'));
end

%% grid (lines at 15, 50 and 85 % of each image)
draw_grid(himg, frames, PIVlab_axis, getappdata(hgui, 'crosshair_enabled') == 1);

%% live ChArUco detection (live image only)
if strcmp(mode, 'live')
    do_charuco_detection = gui.retr('do_charuco_detection');
    if isempty(do_charuco_detection)
        do_charuco_detection = 0;
    end
    last_detection = getappdata(himg{1}, 'last_charuco_detection');
    if do_charuco_detection && ~isempty(last_detection) && toc(last_detection) < 0.5
        % the marker detection is slow (CPU load): at most twice per second, the markers of the last one stay
    elseif do_charuco_detection
        setappdata(himg{1}, 'last_charuco_detection', tic);
        if n == 1
            if ~isempty(frames{1})
                PIVlab_capture_charuco_detector(frames{1}, PIVlab_axis, himg{1});
            end
        else
            for k = 1:n
                if ~isempty(frames{k})
                    PIVlab_capture_charuco_detector(frames{k}, PIVlab_axis, himg{k}, getappdata(himg{k}, 'x_offset'), k);
                end
            end
        end
    else
        delete(findobj('-regexp', 'tag', '^charucolabel'));
    end
end
timing.duration = toc(started);
timing.finished = tic;
if isvalid(himg{1})
    setappdata(himg{1}, 'overlay_timing', timing);
end
end

function draw_grid(himg, frames, PIVlab_axis, enabled)
old_lines = findobj(PIVlab_axis, 'tag', 'capture_grid');
if ~enabled
    delete(old_lines);
    return
end
if ~isempty(old_lines)
    return % drawn already (the lines stay until the axes is cleared)
end
locations = [0.15 0.5 0.85];
for k = 1:numel(himg)
    if isempty(frames{k})
        continue
    end
    h = size(frames{k}, 1);
    w = size(frames{k}, 2);
    x_offset = getappdata(himg{k}, 'x_offset');
    for loca = locations
        line(PIVlab_axis, x_offset + [1 1] * round(w * loca), [1 h], 'Color', [1 1 1], 'LineWidth', 1, 'tag', 'capture_grid', 'HitTest', 'off');
        line(PIVlab_axis, x_offset + [1 w], [1 1] * round(h * loca), 'Color', [1 1 1], 'LineWidth', 1, 'tag', 'capture_grid', 'HitTest', 'off');
    end
end
end
