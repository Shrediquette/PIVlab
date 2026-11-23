function imgs = gui_image_sets(handles)
%GUI_IMAGE_SETS The images of both cameras of the GUI as image sets (like pivlab.readImages).
%   imgs = stereo.gui_image_sets(handles)
% imgs{k}: filepath, framenum, framepart, sequencer, pairs, cam (lens calibration, stereo.camera_lens),
% imageSize, background (none), preprocess = the image pre-processing of the GUI (global for both
% cameras, in the names of pivlab.preprocess, with the region of interest of the GUI), mask = the masks
% of the camera (masks_in_frame, one entry per image pair). Used for the disparity measurement
% (stereo.measure_disparity).
% Two cameras combined into one image (fov.gui_active): the raw images of both cameras (camera 1: the frame list
% of the window, camera 2: gui.retr('fov_src2')) with their lens calibration from gui.retr('fov_calib');
% imgs{1}.mask = the masks of the combined images (fov.measure_sheet).
if nargin < 1
    handles = gui.gethand;
end
combined = fov.gui_active;
if combined
    calib = gui.retr('fov_calib');
    state = {struct('filepath', {gui.retr('filepath')}, 'framenum', gui.retr('framenum'), 'framepart', gui.retr('framepart'), ...
        'masks_in_frame', {gui.retr('masks_in_frame')}), gui.retr('fov_src2')};
else
    stereo.store_active_camera
    state = gui.retr('stereo_cam_state');
end
s = piv.settings_from_gui(handles);
pre.CLAHE = logical(s.clahe);
pre.CLAHESize = s.clahesize;
pre.Highpass = logical(s.highp);
pre.HighpassSize = s.highpsize;
pre.IntensityCapping = logical(s.intenscap);
pre.Wiener = logical(s.wienerwurst);
pre.WienerSize = s.wienerwurstsize;
pre.AutoLimit = logical(s.autolimit);
pre.MinIntensity = s.minintens;
pre.MaxIntensity = s.maxintens;
pre.Roi = gui.retr('roirect');
pre.Background = "none";
imgs = cell(1, 2);
for k = 1:2
    camera = state{k};
    im.filepath = camera.filepath;
    im.framenum = camera.framenum;
    im.framepart = camera.framepart;
    im.sequencer = gui.retr('sequencer');
    im.pairs = floor(numel(camera.filepath) / 2);
    if combined
        im.cam = calib.cams{k};
        im.imageSize = calib.image_size{k};
    else
        im.cam = stereo.camera_lens(camera);
        im.imageSize = camera.expected_image_size;
    end
    im.background = [];
    im.preprocess = pre;
    im.mask = {};
    if isfield(camera, 'masks_in_frame') && ~isempty(camera.masks_in_frame)
        im.mask = camera.masks_in_frame;
    end
    imgs{k} = im;
end
end
