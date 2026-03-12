function stereocheckbox_Callback (~,caller,~)
stereomode=gui.retr('stereomode');
if isempty(stereomode)
    stereomode=0;
end
button = gui.custom_msgbox('quest',getappdata(0,'hgui'),'Warning','Switching mode will reset current results and settings. Continue?','modal',{'Yes','No'},'No');
if strcmpi(button,'Yes')
    gui.put('stereomode',caller.Source.Value); % enable or disable stereo PIV mode, write to GUI variables.
    'Here, all settings in the GUI must be cleared.'
else % omit changing the box value
    caller.Source.Value = stereomode;
end

