function imgs = gui_image_sets(handles)
%GUI_IMAGE_SETS The images of both cameras of the GUI as image sets (like pivlab.readImages).
%   imgs = stereo.gui_image_sets(handles)
% imgs{k}: filepath, framenum, framepart, sequencer, pairs, cam (lens calibration, stereo.camera_lens),
% imageSize, background (none), preprocess = the image pre-processing of the GUI (global for both
% cameras, in the names of pivlab.preprocess, region of interest off). Used for the disparity
% measurement (stereo.measure_disparity).
if nargin < 1
    handles = gui.gethand;
end
stereo.store_active_camera
state = gui.retr('stereo_cam_state');
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
pre.Roi = [];
pre.Background = "none";
imgs = cell(1, 2);
for k = 1:2
    camera = state{k};
    im.filepath = camera.filepath;
    im.framenum = camera.framenum;
    im.framepart = camera.framepart;
    im.sequencer = gui.retr('sequencer');
    im.pairs = numel(camera.filepath) / 2;
    im.cam = stereo.camera_lens(camera);
    im.imageSize = camera.expected_image_size;
    im.background = [];
    im.preprocess = pre;
    im.mask = {};
    imgs{k} = im;
end
end
