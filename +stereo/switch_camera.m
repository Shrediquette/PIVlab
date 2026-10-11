function switch_camera(k)
%SWITCH_CAMERA Show and edit camera k in stereo-PIV mode.
%   stereo.switch_camera(k)
% Stores the per-camera data of the active camera (stereo.store_active_camera), loads the data of
% camera k into the GUI and redraws. All settings stay as they are: they apply to both cameras.
% Does nothing outside stereo mode.
if ~isequal(gui.retr('stereomode'), 1)
    return
end
active = gui.retr('stereo_active_camera');
if isempty(active)
    active = 1;
end
if k ~= active
    stereo.store_active_camera;
    state = gui.retr('stereo_cam_state');
    camera = state{k};
    keys = stereo.camera_data_keys;
    for i = 1:numel(keys)
        if isfield(camera, keys{i})
            gui.put(keys{i}, camera.(keys{i}));
        else
            gui.put(keys{i}, []);
        end
    end
    handles = gui.gethand;
    tags = stereo.camera_controls;
    for i = 1:numel(tags)
        value = 0;
        if isfield(camera, 'controls') && isfield(camera.controls, tags{i})
            value = camera.controls.(tags{i});
        end
        set(handles.(tags{i}), 'Value', value);
    end
    gui.put('stereo_active_camera', k);
    if isempty(gui.retr('stereo_calib'))
        stereo.check_result('apply'); % 2D check result of camera k (before the stereo calibration)
    end
    % background subtraction is a setting of both cameras: the background images of this camera are
    % made now if they do not exist yet
    if get(handles.bg_subtract, 'Value') > 1 && ~isempty(gui.retr('filepath')) && ...
            (isempty(gui.retr('bg_img_A')) || isempty(gui.retr('bg_img_B')))
        preproc.generate_BG_img
    end
end
stereo.show_active_camera;
end
