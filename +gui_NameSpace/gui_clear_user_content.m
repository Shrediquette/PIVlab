function gui_clear_user_content
handles=gui_NameSpace.gui_gethand;
gui_NameSpace.gui_put('pathname',[]); %last path
gui_NameSpace.gui_put ('filename',[]); %only for displaying
gui_NameSpace.gui_put ('filepath',[]); %full path and filename for analyses
set (handles.filenamebox, 'string', 'N/A');
gui_NameSpace.gui_put ('resultslist', []); %clears old results
gui_NameSpace.gui_put ('derived',[]);
gui_NameSpace.gui_put('displaywhat',1);%vectors
gui_NameSpace.gui_put('ismean',[]);
gui_NameSpace.gui_put('framemanualdeletion',[]);
gui_NameSpace.gui_put('manualdeletion',[]);
gui_NameSpace.gui_put('streamlinesX',[]);
gui_NameSpace.gui_put('streamlinesY',[]);
set(handles.fileselector, 'value',1);

set(handles.minintens, 'string', 0);
set(handles.maxintens, 'string', 1);

%Clear all things
validate_NameSpace.validate_clear_vel_limit_Callback %clear velocity limits
roi_NameSpace.roi_clear_roi_Callback
%clear_mask_Callback:
gui_NameSpace.gui_put('masks_in_frame',[]);

%reset zoom
set(handles.panon,'Value',0);
set(handles.zoomon,'Value',0);
gui_NameSpace.gui_put('xzoomlimit', []);
gui_NameSpace.gui_put('yzoomlimit', []);

gui_NameSpace.gui_sliderrange(1)
gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
zoom reset
