function clear_user_content
handles=gui.gui_gethand;
gui.gui_put('pathname',[]); %last path
gui.gui_put ('filename',[]); %only for displaying
gui.gui_put ('filepath',[]); %full path and filename for analyses
set (handles.filenamebox, 'string', 'N/A');
gui.gui_put ('resultslist', []); %clears old results
gui.gui_put ('derived',[]);
gui.gui_put('displaywhat',1);%vectors
gui.gui_put('ismean',[]);
gui.gui_put('framemanualdeletion',[]);
gui.gui_put('manualdeletion',[]);
gui.gui_put('streamlinesX',[]);
gui.gui_put('streamlinesY',[]);
set(handles.fileselector, 'value',1);

set(handles.minintens, 'string', 0);
set(handles.maxintens, 'string', 1);

%Clear all things
validate.validate_clear_vel_limit_Callback %clear velocity limits
roi_1.roi_clear_roi_Callback
%clear_mask_Callback:
gui.gui_put('masks_in_frame',[]);

%reset zoom
set(handles.panon,'Value',0);
set(handles.zoomon,'Value',0);
gui.gui_put('xzoomlimit', []);
gui.gui_put('yzoomlimit', []);

gui.gui_sliderrange(1)
gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))
zoom reset

