function preview_3d_Callback(~, ~, ~)
% "Show 3D preview" (panel 3D particle image generator)
handles = gui.gethand;
set(handles.sim3d_status, 'String', 'Drawing the 3D preview...'); drawnow;
try
    fig = simulate.preview_3d(simulate.setup_3d_from_gui(handles), OnChange=@simulate.setup_3d_to_gui);
    figure(fig);
    set(handles.sim3d_status, 'String', '');
catch err
    set(handles.sim3d_status, 'String', ['Preview not possible: ' err.message]);
end
end
