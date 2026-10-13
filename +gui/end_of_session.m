function end_of_session(store_preferences)
%END_OF_SESSION What PIVlab does before its window closes, and before "Reset PIVlab GUI".
%   gui.end_of_session        stores the preferences that the next start reads (folders, image
%                             acquisition panel), sets the lens to neutral, switches off the laser
%                             warning sign and closes the second monitor window
%   gui.end_of_session(false) the same without storing the preferences
if nargin < 1
    store_preferences = true;
end
if store_preferences
    try
        gui.set_preference('homedir',gui.retr('homedir'));
        gui.set_preference('pathname',gui.retr('pathname'));
        gui.store_last_acquisition_settings %image acquisition panel for the next start
    catch
    end
end
try
    PIVlab_capture_lensctrl (1400,1400,0) %lens needs to be set to neutral otherwise re-enabling power might cause issues
catch
end
try
    hgui = getappdata(0,'hgui');
    serpo=getappdata(hgui,'serpo');
    if ~isempty(serpo)
        string3='WarningSignDisable!';
        pause(1)
        writeline(serpo,string3); %disable the lighting of the laser warning sign
        pause(0.5)
    end
catch
end
try
    second_monitor_fig = gui.retr('second_monitor_fig');
    if ~isempty(second_monitor_fig) && isvalid(second_monitor_fig)
        delete(second_monitor_fig);
    end
catch
end
end
