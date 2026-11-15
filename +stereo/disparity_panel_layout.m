function disparity_panel_layout(handles)
%DISPARITY_PANEL_LAYOUT Disparity correction panel: the manual settings only in manual mode.
%   In automatic mode the manual settings are hidden and the panel is shorter (its top stays).
%   Called by gui.update_dependent_controls.
manual = get(handles.stereo_disp_mode, 'Value') == 2;
if manual
    set(handles.stereo_disp_manual, 'Visible', 'on');
else
    set(handles.stereo_disp_manual, 'Visible', 'off');
end
margin = gui.retr('margin');
panel = get(handles.stereo_disp_panel, 'Position');
manual_pos = get(handles.stereo_disp_manual, 'Position');
results_pos = get(handles.stereo_disp_results, 'Position');
height = get(handles.stereo_disp_panel, 'UserData'); % height in manual mode (gui.generateUI)
if ~manual
    height = height - manual_pos(4);
end
top = panel(2) + panel(4);
set(handles.stereo_disp_panel, 'Position', [panel(1) top - height panel(3) height]);
% rows from the top of the panel, as in gui.generateUI
mode_text = get(handles.stereo_disp_mode_text, 'Position');
mode_text(2) = height - margin - mode_text(4);
set(handles.stereo_disp_mode_text, 'Position', mode_text);
mode_popup = get(handles.stereo_disp_mode, 'Position');
mode_popup(2) = mode_text(2);
set(handles.stereo_disp_mode, 'Position', mode_popup);
offset = mode_text(4) + margin / 4;
manual_pos(2) = height - margin - offset - manual_pos(4);
set(handles.stereo_disp_manual, 'Position', manual_pos);
if manual
    offset = offset + manual_pos(4);
end
results_pos(2) = height - margin - offset - results_pos(4);
set(handles.stereo_disp_results, 'Position', results_pos);
end
