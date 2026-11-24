function panel_Callback(~, ~, ~)
%PANEL_CALLBACK Menu Analysis -> Stereo-PIV / multicam: show the Stereo-PIV / multicam panel.
if ~misc.require_toolbox('Computer Vision Toolbox','Stereo-PIV')
    return
end
gui.switchui('multip30')
stereo.update_panel
end
