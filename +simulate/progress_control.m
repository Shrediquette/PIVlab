function varargout = progress_control(action, arg)
% Progress bar and cancel button of the long computations of the particle image generator (flow
% simulation, preview, generation). Used as the Progress function of simulate.recording_3d:
%   simulate.progress_control('open', button)   the button (Generate images / Preview) becomes "Cancel"
%   simulate.progress_control('update', text)   shows text in the status line; moves the progress bar of PIVlab
%                                               with the "time step n of N" messages of the flow solver; raises the
%                                               error 'simulate:cancelled' if the user pressed Cancel
%   simulate.progress_control('close')          the button is as before, the progress bar is empty
%   tf = simulate.progress_control('isCancel', err)   true for the error of a cancelled computation
switch action
    case 'open'
        close_control();
        button = arg;
        state.button = button;
        state.label = get(button, 'String');
        state.callback = get(button, 'Callback');
        gui.put('sim3d_progress_button', state);
        gui.put('sim3d_cancel', 0);
        set(button, 'String', 'Cancel', 'Callback', @simulate.cancel_3d_Callback, 'Enable', 'on');
        drawnow
    case 'update'
        update(arg);
    case 'close'
        close_control();
    case 'isCancel'
        varargout{1} = strcmp(arg.identifier, 'simulate:cancelled');
end
end

function update(text)
try
    handles = gui.gethand;
    set(handles.sim3d_status, 'String', text);
catch
end
step = regexp(text, 'time step (\d+) of (\d+)', 'tokens', 'once');
try
    if ~isempty(step) % the flow simulation is most of the work: 0 ... 90 %
        gui.update_progress(90 * str2double(step{1}) / str2double(step{2}));
    elseif contains(text, 'Particle images')
        gui.update_progress(95);
    end
catch
end
drawnow
if isequal(gui.retr('sim3d_cancel'), 1)
    close_control();
    error('simulate:cancelled', 'Cancelled.');
end
end

function close_control()
state = gui.retr('sim3d_progress_button');
if ~isempty(state) && isstruct(state)
    if isvalid(state.button)
        set(state.button, 'String', state.label, 'Callback', state.callback);
    end
    gui.put('sim3d_progress_button', []);
    try
        gui.update_progress(0);
    catch
    end
end
gui.put('sim3d_cancel', 0);
end
