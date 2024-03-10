function plot_vectorscale_Callback(~, ~, ~)
handles=gui_NameSpace.gui_gethand;
resultslist=gui_NameSpace.gui_retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
end
