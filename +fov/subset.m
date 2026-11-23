function cam = subset(cam, sel)
%SUBSET Camera settings for a part of the frame list (larger field of view: camera 2 frames follow).
%   cam = fov.subset(cam, sel)
%   cam  camera settings (import.cam_settings); with cam.fov the frame list of camera 2 is reduced to the
%        frames sel, so that frame i of the reduced list of camera 1 is combined with frame i of camera 2.
%        Without cam.fov cam is returned unchanged.
%   Needed where a caller reads frames from a reduced list (e.g. ensemble PIV of selected pairs).
if fov.is_combined(cam)
    cam.fov.src = import.frame_list(cam.fov.src, sel);
end
end
