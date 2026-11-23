function apply_alignment(calib)
%APPLY_ALIGNMENT The alignment of the combined data set in the PIVlab window (a new one, or the same cameras moved
%onto the measured light sheet).
%   fov.apply_alignment(calib)
%   calib  stereo.calibrate (calib.use = "fov"), possibly fov.measure_sheet
% New alignment (no gui.retr('fov_calib') yet, fov.enter_combined): everything that belonged to the camera images
% is cleared, the region of interest is set automatically inside the part the cameras see (fov.auto_roi, as in
% stereo-PIV; users who want more vectors delete it and draw masks) and the spatial calibration (px -> mm) is set.
% Same data set (fov.measure_sheet_Callback): the output grid and the spatial calibration stay; results and the
% background (made with the old maps) are cleared; masks stay; the automatic region of interest is adapted (the
% views move a little on the sheet), one set by the user stays.
old = gui.retr('fov_calib');
first = isempty(old);
calib.report = fov.report(calib);
gui.put('fov_calib', calib);
fov.update_maps
F = gui.retr('fov_maps');
masks_in_frame = gui.retr('masks_in_frame');
roirect = gui.retr('roirect');
stereo.clear_image_data % what belongs to the camera images (first) / was made with the old maps
if ~first
    gui.put('masks_in_frame', masks_in_frame);
end
if first || isempty(roirect) || (isfield(old, 'auto_roi') && isequal(roirect, old.auto_roi))
    roirect = fov.auto_roi(F.owner);
    calib.auto_roi = roirect;
    gui.put('fov_calib', calib);
end
gui.put('roirect', roirect);
roi.updateROIinfo
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
