function panel_Callback(~, ~, ~)
%PANEL_CALLBACK Menu Analysis -> Stereo-PIV: show the Stereo-PIV panel.
gui.switchui('multip30')
stereo.update_panel
end
