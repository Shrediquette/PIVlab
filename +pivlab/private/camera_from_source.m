function cam = camera_from_source(source, view, rectification)
%CAMERA_FROM_SOURCE Camera undistortion / rectification settings (import.cam_settings) for the API.
%   cam = camera_from_source(source, view, rectification)
%
%   source         "none"                    no undistortion
%                  camera calibration file   saved in the PIVlab GUI ("Save camera parameters"):
%                                            undistortion (incl. the tilted camera model)
%                  PIVlab session file       the camera calibration and rectification of the session,
%                                            exactly as they were used in the session
%                  cameraParameters / cameraIntrinsics object (MATLAB Computer Vision Toolbox)
%   view           "valid" | "same" | "full", or [] (from the session, else "valid")
%   rectification  [] (from the session, else none), true / false, or a 2-D geometric
%                  transformation (e.g. projtform2d) that maps the undistorted image to the
%                  rectified image
views = ["valid", "same", "full"];
if (ischar(source) || isstring(source)) && strcmpi(source, "none")
    cam = import.cam_settings();
    return
end

use_rectification = 0;
tform = [];
use_tilted = false;
tilted_D = [];
K_opencv = [];
file_view = "valid";
if isa(source, 'cameraParameters') || isa(source, 'cameraIntrinsics')
    params = source;
elseif ischar(source) || isstring(source)
    file = char(source);
    if ~isfile(file)
        error('pivlab:preprocess:cameraFile', 'Camera calibration file not found: %s', file);
    end
    [session, ~] = import.read_session_file(file);
    if ~isempty(session)
        % camera calibration of a PIVlab session, as it was used in the session
        data = session.data;
        if ~isfield(data, 'cameraParams') || isempty(data.cameraParams) || ~has_flag(data, 'cam_use_calibration')
            error('pivlab:preprocess:noCameraCalibration', ...
                'The session %s does not use a camera calibration.', file);
        end
        params = data.cameraParams;
        if has_flag(data, 'cam_use_rectification') && isfield(data, 'rectification_tform')
            use_rectification = 1;
            tform = data.rectification_tform;
        end
        if has_flag(data, 'cam_use_tilted_model')
            use_tilted = true;
            tilted_D = data.cam_tilted_D;
            K_opencv = data.cam_K_opencv;
        end
        if isfield(session.settings, 'calibration') && isfield(session.settings.calibration, 'calib_viewtype')
            file_view = views(session.settings.calibration.calib_viewtype);
        end
    else
        try
            vars = who('-file', file);
        catch
            vars = {};    % not a MAT file
        end
        if ~ismember('cameraParams', vars)
            error('pivlab:preprocess:cameraFile', ...
                ['%s is neither a camera calibration file of PIVlab ("Save camera parameters") ' ...
                'nor a PIVlab session.'], file);
        end
        loaded = load(file);
        params = loaded.cameraParams;
        if isfield(loaded, 'cam_use_tilted_model') && ~isempty(loaded.cam_use_tilted_model) && loaded.cam_use_tilted_model
            use_tilted = true;
            tilted_D = loaded.cam_tilted_D;
            K_opencv = loaded.cam_K_opencv;
        end
    end
else
    error('pivlab:preprocess:camera', ...
        'Camera must be "none", a file name, or a cameraParameters / cameraIntrinsics object.');
end

% view: given, else from the session, else "valid"
if isempty(view)
    view = file_view;
end
view = lower(string(view));
if ~ismember(view, views)
    error('pivlab:preprocess:cameraView', 'CameraView must be "valid", "same" or "full".');
end

% rectification: given (true / false / transformation), else from the session
if ~isempty(rectification)
    if islogical(rectification) || isnumeric(rectification)
        if rectification
            if isempty(tform)
                error('pivlab:preprocess:rectification', ...
                    ['Rectification=true needs a rectification from a PIVlab session (Camera=session file) ' ...
                    'or a transformation (Rectification=projtform2d(...)).']);
            end
            use_rectification = 1;
        else
            use_rectification = 0;
        end
    else
        tform = rectification;
        use_rectification = 1;
    end
end

cam = import.cam_settings(view=char(view), use_calibration=1, use_rectification=use_rectification, ...
    cameraParams=params, rectification_tform=tform, use_tilted_model=use_tilted, ...
    tilted_D=tilted_D, K_opencv=K_opencv);
end

function tf = has_flag(data, name)
tf = isfield(data, name) && ~isempty(data.(name)) && isequal(double(data.(name)), 1);
end
