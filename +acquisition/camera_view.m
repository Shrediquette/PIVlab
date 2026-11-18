function view = camera_view()
%CAMERA_VIEW Which cameras the stereo live image and PIV capture show: 0 = both side by side, 1 or 2 = only this
%camera. Set with the CAM button of the Tools panel (stereo.camera_toggle_Callback) while the Image Acquisition
%panel is open. Only the display follows it, plus the snapshot and the image for the ROI selection: both
%cameras keep recording. With one camera it is always 0.
view = 0;
if acquisition.capture_cameras < 2
    return
end
stored = gui.retr('capture_camera_view');
if isequal(stored, 1) || isequal(stored, 2)
    view = stored;
end
end
