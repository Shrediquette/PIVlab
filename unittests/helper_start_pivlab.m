function hgui = helper_start_pivlab(cores)
%HELPER_START_PIVLAB Starts a fresh PIVlab window for a test.
%   hgui = helper_start_pivlab()       serial analysis
%   hgui = helper_start_pivlab(cores)  cores > 1: the GUI analyses in parallel
%   The window gets a fixed size (screenshots and layouts do not depend on the screen), and
%   batchModeActive tells PIVlab that a script drives it (no questions).
if nargin < 1
    cores = 1;
end
helper_close_pivlab();
PIVlab_GUI(cores);
drawnow;
gui.put('batchModeActive', 1);
hgui = getappdata(0, 'hgui');
set(hgui, 'Units', 'pixels', 'Position', [20 40 1600 1000]);
drawnow;
try
    gui.MainWindow_ResizeFcn(hgui);
catch
end
drawnow;
end
