function hgui = helper_start_pivlab(cores)
%HELPER_START_PIVLAB PIVlab window in its start state for a test.
%   hgui = helper_start_pivlab()       serial analysis
%   hgui = helper_start_pivlab(cores)  cores > 1: the GUI analyses in parallel
%   If PIVlab is already open (same cores), it is reset with "Reset PIVlab GUI" instead of a new start,
%   and the reset window must be the same as the newly started one of this test file
%   (helper_gui_snapshot, taken after the start): otherwise the test fails with the differences and
%   PIVlab is closed, so that the next test starts fresh. For a real new start (e.g. preferences that
%   are only read at the start, session round trips), call helper_close_pivlab() first.
%   The window gets a fixed size (screenshots and layouts do not depend on the screen), and
%   batchModeActive tells PIVlab that a script drives it (no questions).
if nargin < 1
    cores = 1;
end
hgui = getappdata(0, 'hgui');
fresh = getappdata(0, 'pivlab_test_fresh_state');
if ~isempty(hgui) && ishghandle(hgui) && ~isempty(fresh) && isequal(getappdata(0, 'pivlab_test_cores'), cores)
    % other windows (figures of the previous test) are closed, as by helper_close_pivlab
    figures = findall(0, 'Type', 'figure');
    for k = 1:numel(figures)
        if figures(k) ~= hgui
            close(figures(k), 'force');
        end
    end
    gui.put('batchModeActive', 1);
    gui.reset_gui_Callback([], [], false); % no preferences stored: like the closing with delete before
    prepare_window(hgui);
    differences = helper_snapshot_differences(fresh, helper_gui_snapshot(hgui));
    if ~isempty(differences)
        helper_close_pivlab();
        error('helper_start_pivlab:reset', '"Reset PIVlab GUI" is not the same as a new start:\n%s', ...
            strjoin(differences, newline));
    end
    return
end
helper_close_pivlab();
PIVlab_GUI(cores);
drawnow;
hgui = getappdata(0, 'hgui');
prepare_window(hgui);
setappdata(0, 'pivlab_test_cores', cores);
setappdata(0, 'pivlab_test_fresh_state', helper_gui_snapshot(hgui));
end

function prepare_window(hgui)
gui.put('batchModeActive', 1);
set(hgui, 'Units', 'pixels', 'Position', [20 40 1600 1000]);
drawnow;
try
    gui.MainWindow_ResizeFcn(hgui);
catch
end
drawnow;
end
