function clear_everything_Callback(~, ~, ~)
gui.gui_put ('resultslist', []); %clears old results
gui.gui_put ('derived', []);
handles=gui.gui_gethand;
set(handles.progress, 'String','Frame progress: N/A');
set(handles.overall, 'String','Total progress: N/A');
set(handles.totaltime, 'String','Time left: N/A');
set(handles.messagetext, 'String','');
set (handles.amount_nans, 'BackgroundColor',[0.9 0.9 0.9])
set (handles.amount_nans,'string','')
gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))

