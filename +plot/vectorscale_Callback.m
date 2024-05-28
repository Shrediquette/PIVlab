function vectorscale_Callback(~, ~, ~)
handles=gui.gui_gethand;
resultslist=gui.gui_retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))
end

