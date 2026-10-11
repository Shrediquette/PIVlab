function disparity_display_Callback(~, ~, ~)
%DISPARITY_DISPLAY_CALLBACK Popup "Show:" of the Stereo-PIV panel: redraw the image.
if ~isempty(gui.retr('filepath'))
    gui.sliderdisp(gui.retr('pivlab_axis'));
end
end
