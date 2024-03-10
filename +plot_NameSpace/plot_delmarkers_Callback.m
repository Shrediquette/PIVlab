function plot_delmarkers_Callback(~, ~, ~)
gui_NameSpace.gui_put('manmarkersX',[]);
gui_NameSpace.gui_put('manmarkersY',[]);
delete(findobj('tag','manualmarker'));
