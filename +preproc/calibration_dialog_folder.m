function folder = calibration_dialog_folder(kind)
%CALIBRATION_DIALOG_FOLDER Folder in which a camera calibration file dialog starts.
%   folder = preproc.calibration_dialog_folder('lens')     images of the calibration target (lens calibration),
%                                                           also "Find ChArUco parameters"
%   folder = preproc.calibration_dialog_folder('target')   the image of the target in the light sheet
% The first existing folder of:
%   1. the folder of the last pick of this dialog (of the camera that is shown in stereo-PIV mode)
%   2. stereo-PIV: the folder of the other camera's pick in this dialog (camera 2 starts where camera 1's were)
%   3. 'target': the folder of the lens calibration images (of this camera)
%   4. the folder of the PIV images (of this camera), then the last image folder, then the current folder
if strcmp(kind, 'target')
    key = 'cam_selected_rectification_image';
else
    key = 'cam_selected_target_images';
end
candidates = {folder_of(gui.retr(key))};
if isequal(gui.retr('stereomode'), 1)
    state = gui.retr('stereo_cam_state');
    active = gui.retr('stereo_active_camera');
    if isempty(active)
        active = 1;
    end
    other = 3 - active;
    if iscell(state) && numel(state) >= other && isstruct(state{other}) && isfield(state{other}, key)
        candidates{end + 1} = folder_of(state{other}.(key));
    end
end
if strcmp(kind, 'target')
    candidates{end + 1} = folder_of(gui.retr('cam_selected_target_images'));
end
candidates{end + 1} = folder_of(gui.retr('filepath'));
candidates{end + 1} = gui.retr('pathname');
candidates{end + 1} = pwd;
folder = pwd;
for k = 1:numel(candidates)
    if ischar(candidates{k}) && ~isempty(candidates{k}) && isfolder(candidates{k})
        folder = candidates{k};
        return
    end
end
end

function folder = folder_of(files)
% folder of the first file of a file name or a list of file names, '' if there is none
folder = '';
if iscell(files) && ~isempty(files)
    files = files{1};
end
if ischar(files) && ~isempty(files)
    folder = fileparts(files);
end
end
