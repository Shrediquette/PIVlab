function theme_changed(MainWindow, ~)
% ThemeChangedFcn of the PIVlab window (set by PIVlab_GUI when no colour theme is stored in the
% preferences): the window then follows the MATLAB theme, and the colours of the PIVlab controls
% (gui.retr('darkmode')) follow the window.
%   The first window of a MATLAB session without desktop (matlab -batch, standalone PIVlab, where the
%   splash screen is that window) is light at first with the MATLAB theme "System" and gets the system
%   theme only some seconds later (R2026b: 1.5 to 4 s). The user can also change the MATLAB or system
%   theme while PIVlab runs.
%   While PIVlab starts, nothing is done here: PIVlab_GUI calls this once more at the end of the start.
%   While PIVlab is busy (gui.toolsavailable(0)), the controls are built again once it is done.
if ~isvalid(MainWindow) || ~isequal(getappdata(0,'hgui'), MainWindow)
    return % PIVlab was closed
end
if ~isempty(gui.get_preference('dark_mode_theme',[]))
    return % theme chosen in PIVlab (Preferences): the window does not follow MATLAB
end
if isempty(gui.retr('startup_appdata'))
    return % PIVlab is still starting
end
dark = strcmpi(MainWindow.Theme.BaseColorStyle,'dark');
if dark == isequal(gui.retr('darkmode'),1)
    return % the colours already match the window
end
if isequal(gui.retr('tools_locked'),1)
    wait_until_not_busy(MainWindow)
    return
end
gui.put('darkmode',double(dark));
gui.rebuild_for_theme(false)
end

function wait_until_not_busy(MainWindow)
if ~isempty(timerfindall('Tag','PIVlab_theme_follow'))
    return % already waiting
end
t = timer('Tag','PIVlab_theme_follow','ObjectVisibility','off','ExecutionMode','fixedSpacing', ...
    'Period',1,'BusyMode','drop','TimerFcn',@(tmr,~) check_again(tmr, MainWindow));
start(t);
end

function check_again(tmr, MainWindow)
if isvalid(MainWindow) && isequal(getappdata(0,'hgui'), MainWindow) && isequal(gui.retr('tools_locked'),1)
    return % still busy
end
stop(tmr);
delete(tmr);
gui.theme_changed(MainWindow);
end
