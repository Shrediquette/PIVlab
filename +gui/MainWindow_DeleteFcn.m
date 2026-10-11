function MainWindow_DeleteFcn(hObject, ~)
%MAINWINDOW_DELETEFCN Runs when the PIVlab window is deleted (closed by the user, by close / delete or
%   when MATLAB quits): the serial port readline warning, switched off by PIVlab_GUI while PIVlab is
%   open, gets back the setting it had before PIVlab started. Other warning settings are not touched.
id = 'serialport:serialport:ReadlineWarning';
before = getappdata(hObject, 'warnings_before_pivlab');
if isempty(before)
    return
end
now_state = warning;
new_state = struct('identifier', {}, 'state', {});
for k = 1:numel(now_state)
    if ~strcmp(now_state(k).identifier, id)
        new_state(end+1) = now_state(k); %#ok<AGROW>
    end
end
for k = 1:numel(before)
    if strcmp(before(k).identifier, id)
        new_state(end+1) = before(k); %#ok<AGROW>
    end
end
warning(new_state);
end
