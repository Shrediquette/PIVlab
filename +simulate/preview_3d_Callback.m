function preview_3d_Callback(~, ~, ~)
% "Show 3D preview" (panel Particle image generator; camera setups only)
handles = gui.gethand;
if get(handles.sim3d_setup, 'Value') == 1
    set(handles.sim3d_status, 'String', 'The simple setup has no 3D preview.');
    return
end
if ~misc.require_toolbox('Computer Vision Toolbox','The 3D preview')
    return
end
set(handles.sim3d_status, 'String', 'Drawing the 3D preview...'); drawnow;
try
    fig = simulate.preview_3d(simulate.setup_3d_from_gui(handles), OnChange=@simulate.setup_3d_to_gui);
    figure(fig);
    set(handles.sim3d_status, 'String', '');
catch err
    set(handles.sim3d_status, 'String', ['Preview not possible: ' err.message]);
end
end
