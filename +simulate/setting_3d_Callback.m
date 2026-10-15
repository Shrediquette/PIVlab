function setting_3d_Callback(src, ~, ~)
% A setting of the panel "3D particle image generator" changed: check the value, show the
% dependent controls and update the 3D preview (if it is open).
handles = gui.gethand;
if nargin >= 1 && ~isempty(src) && isgraphics(src) && strcmp(get(src, 'Style'), 'edit')
    value = str2double(get(src, 'String'));
    if ~isfinite(value) % back to the default value
        default = gui.default_settings;
        set(src, 'String', gui.setting_text(default.tools.(get(src, 'Tag'))));
        set(handles.sim3d_status, 'String', 'Please enter a number.');
    end
end
gui.update_dependent_controls(handles);
simulate.update_board_info_3d(handles);
fig = findall(groot, 'Type', 'figure', 'Tag', 'PIVlab_sim3d_preview');
if ~isempty(fig)
    simulate.preview_3d(simulate.setup_3d_from_gui(handles), OnChange=@simulate.setup_3d_to_gui);
end
end
