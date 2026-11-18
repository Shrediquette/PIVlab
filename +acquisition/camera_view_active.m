function active = camera_view_active()
%CAMERA_VIEW_ACTIVE True when the CAM button of the Tools panel chooses the cameras shown in the image
%acquisition (acquisition.camera_view): Image Acquisition panel open and stereo acquisition (two cameras).
handles = gui.gethand;
active = isfield(handles, 'multip24') && strcmp(get(handles.multip24, 'Visible'), 'on') && acquisition.capture_cameras == 2;
end
