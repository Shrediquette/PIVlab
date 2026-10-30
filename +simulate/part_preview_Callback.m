function part_preview_Callback(~, ~, ~)
% "Preview particle images" (panel Particle image generator): one image pair per camera. While it
% computes, the button is "Cancel" and the progress bar of PIVlab shows the flow simulation.
handles = gui.gethand;
mode = get(handles.sim3d_setup, 'Value'); % 1 simple, 2 one camera, 3 two cameras
if mode > 1 && ~misc.require_toolbox('Computer Vision Toolbox','The particle image preview')
    return
end
setup = simulate.setup_3d_from_gui(handles);
text = 'Rendering the particle images...';
if any(strcmp(setup.flow.Type, {'sphere', 'jet'}))
    text = 'Rendering the particle images... The first preview of a flow runs the flow simulation (about a minute); the next ones are fast.';
end
gui.toolsavailable(0, 'Rendering the particle images...');
simulate.progress_control('open', handles.sim3d_part_preview);
set(handles.sim3d_status, 'String', text); drawnow;
try
    fig = simulate.preview_particles(setup, Progress=@progress);
    simulate.progress_control('close');
    gui.toolsavailable(1);
    figure(fig);
    set(handles.sim3d_status, 'String', '');
catch err
    simulate.progress_control('close');
    gui.toolsavailable(1);
    if simulate.progress_control('isCancel', err)
        set(handles.sim3d_status, 'String', 'Preview cancelled.');
    else
        set(handles.sim3d_status, 'String', ['Preview not possible: ' err.message]);
    end
end
end

function progress(text)
simulate.progress_control('update', text);
end
