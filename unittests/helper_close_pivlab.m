function helper_close_pivlab()
%HELPER_CLOSE_PIVLAB Closes the PIVlab window and all other figures without questions.
%   Also switches the MATLAB warnings back on as they were at helper_setup_once (PIVlab_GUI
%   switches all warnings off).
hgui = getappdata(0, 'hgui');
if ~isempty(hgui) && ishghandle(hgui)
    try
        gui.put('batchModeActive', 1);
    catch
    end
    try
        delete(hgui);
    catch
        close(hgui, 'force');
    end
end
setappdata(0, 'hgui', []);
try
    close(findall(0, 'Type', 'figure'), 'force');
catch
end
if isappdata(0, 'pivlab_test_warning_state')
    warning(getappdata(0, 'pivlab_test_warning_state'));
end
end
