function [background, text] = camera_colors(k)
%CAMERA_COLORS Colour of camera k in the stereo-PIV GUI (camera switch, image label, plots).
%   [background, text] = stereo.camera_colors(k): camera 1 blue, camera 2 orange; text = readable
%   text colour on that background.
if k == 1
    background = [0.20 0.55 1.00];
    text = [1 1 1];
else
    background = [1.00 0.55 0.10];
    text = [0 0 0];
end
end
