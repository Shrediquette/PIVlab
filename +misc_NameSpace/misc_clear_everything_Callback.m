function misc_clear_everything_Callback(~, ~, ~)
gui_NameSpace.gui_put ('resultslist', []); %clears old results
gui_NameSpace.gui_put ('derived', []);
handles=gui_NameSpace.gui_gethand;
set(handles.progress, 'String','Frame progress: N/A');
set(handles.overall, 'String','Total progress: N/A');
set(handles.totaltime, 'String','Time left: N/A');
set(handles.messagetext, 'String','');
set (handles.amount_nans, 'BackgroundColor',[0.9 0.9 0.9])
set (handles.amount_nans,'string','')
gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
