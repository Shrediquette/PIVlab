function active = camera_view_active()
%CAMERA_VIEW_ACTIVE True when the CAM button of the Tools panel chooses the cameras shown in the image
%acquisition (acquisition.camera_view): Image Acquisition panel open and stereo acquisition (two cameras).
%Not when loaded images are shown instead of camera images (e.g. after a stereo recording, which is loaded
%in stereo mode): then the CAM button is the camera switch of stereo-PIV.
handles = gui.gethand;
active = isfield(handles, 'multip24') && strcmp(get(handles.multip24, 'Visible'), 'on') && acquisition.capture_cameras == 2;
if active && ~isempty(gui.retr('filepath')) && ~camera_images_shown()
    active = false;
end
end

function shown = camera_images_shown()
%camera images of acquisition.live_images in the image area (live image, PIV capture, also after Stop)
shown = false;
imgs = findobj(gui.retr('pivlab_axis'), 'Type', 'image');
for i = 1:numel(imgs)
    if isappdata(imgs(i), 'camera')
        shown = true;
        return
    end
end
end
