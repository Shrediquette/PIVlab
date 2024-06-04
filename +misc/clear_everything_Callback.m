function clear_everything_Callback(~, ~, ~)
gui.put ('resultslist', []); %clears old results
gui.put ('derived', []);
handles=gui.gethand;
set(handles.progress, 'String','Frame progress: N/A');
set(handles.overall, 'String','Total progress: N/A');
set(handles.totaltime, 'String','Time left: N/A');
set(handles.messagetext, 'String','');
set (handles.amount_nans, 'BackgroundColor',[0.9 0.9 0.9])
set (handles.amount_nans,'string','')
gui.sliderdisp(gui.retr('pivlab_axis'))

