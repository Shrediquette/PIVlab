function cam = cam_settings(opts)
%CAM_SETTINGS Camera undistortion / rectification settings used by import.read_frame.
%   cam = import.cam_settings()            no undistortion (default)
%   cam = import.cam_settings(Name=Value)  see the field names below
%   cam = import.cam_settings(FromGUI=true) settings currently active in the PIVlab GUI
arguments
    opts.view = 'valid'                 % 'valid' | 'same' | 'full'
    opts.use_calibration = 0
    opts.use_rectification = 0
    opts.cameraParams = []
    opts.rectification_tform = []
    opts.use_tilted_model = false
    opts.tilted_D = []
    opts.K_opencv = []
    opts.stereo_map = []                % stereo-PIV: map of stereo.camera_map (replaces undistortion
                                        % and rectification, see preproc.cam_undistort_with)
    opts.FromGUI (1,1) logical = false
end
if opts.FromGUI
    handles=gui.gethand;
    views = {'valid','same','full'};
    opts.view = views{handles.calib_viewtype.Value};
    opts.use_calibration = gui.retr('cam_use_calibration');
    opts.use_rectification = gui.retr('cam_use_rectification');
    opts.cameraParams = gui.retr('cameraParams');
    opts.rectification_tform = gui.retr('rectification_tform');
    opts.use_tilted_model = gui.retr('cam_use_tilted_model');
    opts.tilted_D = gui.retr('cam_tilted_D');
    opts.K_opencv = gui.retr('cam_K_opencv');
    if isempty(opts.use_tilted_model); opts.use_tilted_model = false; end
    if isequal(gui.retr('stereomode'), 1) % stereo-PIV: map of the camera that is shown (stereo.update_maps)
        maps = gui.retr('stereo_maps');
        active = gui.retr('stereo_active_camera');
        if iscell(maps) && ~isempty(active) && active <= numel(maps)
            opts.stereo_map = maps{active};
        end
    end
end
cam = rmfield(opts,'FromGUI');
end
