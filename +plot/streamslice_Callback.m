function streamslice_Callback(~, ~, ~)
handles = gui.gethand;
resultslist = gui.retr('resultslist');
currentframe = floor(get(handles.fileselector, 'value'));
if size(resultslist,2) >= currentframe && numel(resultslist{1,currentframe}) > 0
	gui.put('streamlinesX', []);
	gui.put('streamlinesY', []);
	gui.put('streamslice_active', true);
	gui.sliderdisp(gui.retr('pivlab_axis'));
end