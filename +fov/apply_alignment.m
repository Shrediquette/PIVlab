function apply_alignment(calib)
%APPLY_ALIGNMENT The alignment of the combined data set in the PIVlab window (a new one, or the same cameras moved
%onto the measured light sheet).
%   fov.apply_alignment(calib)
%   calib  stereo.calibrate (calib.use = "fov"), possibly fov.measure_sheet
% New alignment (no gui.retr('fov_calib') yet, fov.enter_combined): everything that belonged to the camera images
% is cleared, the part no camera sees is masked in all frames, the region of interest is the whole image and the
% spatial calibration (px -> mm) is set.
% Same data set (fov.measure_sheet_Callback): the output grid and the spatial calibration stay; results and the
% background (made with the old maps) are cleared; masks drawn by the user stay, the mask of the part no camera
% sees is replaced (the views move a little on the sheet).
old = gui.retr('fov_calib');
first = isempty(old);
old_uncovered = {};
if ~first
    old_maps = gui.retr('fov_maps');
    old_uncovered = fov.uncovered_mask(old_maps.owner);
end
calib.report = fov.report(calib);
gui.put('fov_calib', calib);
fov.update_maps
F = gui.retr('fov_maps');
uncovered = fov.uncovered_mask(F.owner);
n_pairs = floor(numel(gui.retr('filepath')) / 2);
if first
    stereo.clear_image_data % what belongs to the camera images
    masks_in_frame = cell(1, n_pairs);
    if ~isempty(uncovered)
        masks_in_frame(:) = {uncovered};
        gui.put('masks_in_frame', masks_in_frame);
    end
    roi.clear_roi_Callback % region of interest: the whole combined image
else
    % results and backgrounds were made with the old maps
    masks_in_frame = gui.retr('masks_in_frame');
    stereo.clear_image_data
    gui.put('masks_in_frame', replaced_uncovered(masks_in_frame, old_uncovered, uncovered, n_pairs));
end
% board images of both cameras combined (the calibration panel)
if isfield(calib, 'boards') && all(cellfun(@(b) (ischar(b) || isstring(b)) && isfile(b), calib.boards))
    gui.put('caliimg', fov.compose(imread(calib.boards{1}), imread(calib.boards{2}), F));
end
handles = gui.gethand;
if first
    % spatial calibration like the stereo calibration: reference distance along x on the combined grid
    calibrate.set_grid_scale(F.size(2), F.mm_per_px);
    filename = gui.retr('filename');
    if ~isempty(filename)
        set(handles.filenamebox, 'String', filename, 'Value', 1);
    end
    gui.sliderrange(0);
end
gui.update_dependent_controls(handles);
stereo.update_panel(handles); % the checklist also when the panel is hidden (update_dependent_controls: only when shown)
if ~isempty(gui.retr('filepath'))
    gui.sliderdisp(gui.retr('pivlab_axis'));
end
end

function masks = replaced_uncovered(masks, old_uncovered, uncovered, n_pairs)
% masks of all frames: the rows of the old mask of the part no camera sees removed (same polygon), the new one added
if isempty(masks)
    masks = cell(1, n_pairs);
end
old_pos = {};
if ~isempty(old_uncovered)
    old_pos = old_uncovered(:, 2);
end
for i = 1:numel(masks)
    entry = masks{i};
    if ~isempty(entry) && ~isempty(old_pos)
        auto = cellfun(@(p) any(cellfun(@(q) isequal(p, q), old_pos)), entry(:, 2));
        entry = entry(~auto, :);
    end
    if ~isempty(uncovered)
        entry = [entry; uncovered]; %#ok<AGROW>
    end
    masks{i} = entry;
end
end
