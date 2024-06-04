function delmarkers_Callback(~, ~, ~)
gui.put('manmarkersX',[]);
gui.put('manmarkersY',[]);
delete(findobj('tag','manualmarker'));

