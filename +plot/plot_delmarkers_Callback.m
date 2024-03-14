function plot_delmarkers_Callback(~, ~, ~)
gui.gui_put('manmarkersX',[]);
gui.gui_put('manmarkersY',[]);
delete(findobj('tag','manualmarker'));

