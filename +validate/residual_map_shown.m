function shown = residual_map_shown(handles)
%true when the stereo based validation panel shows the residual map: stereo-PIV, panel open,
%"Reconstruction residual filter" and "Show residual map" ticked
shown = false;
if ~isfield(handles, 'multip32') || ~isequal(gui.retr('stereomode'), 1)
    return
end
if strcmp(get(handles.multip32, 'Visible'), 'on') && get(handles.residual_enable, 'Value') == 1 && get(handles.stereo_show_residual, 'Value') == 1
    shown = true;
end
