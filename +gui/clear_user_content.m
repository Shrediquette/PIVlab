function clear_user_content
handles=gui.gethand;
gui.put('pathname',[]); %last path
gui.put ('filename',[]); %only for displaying
gui.put ('filepath',[]); %full path and filename for analyses
set (handles.filenamebox, 'string', 'N/A');
gui.put ('resultslist', []); %clears old results
gui.put ('derived',[]);
gui.put('displaywhat',1);%vectors
gui.put('ismean',[]);
gui.put('framemanualdeletion',[]);
gui.put('manualdeletion',[]);
gui.put('streamlinesX',[]);
gui.put('streamlinesY',[]);
set(handles.fileselector, 'value',1);

set(handles.minintens, 'string', 0);
set(handles.maxintens, 'string', 1);

%Clear all things
validate.clear_vel_limit_Callback %clear velocity limits
roi_1.roi_clear_roi_Callback
%clear_mask_Callback:
gui.put('masks_in_frame',[]);

%reset zoom
set(handles.panon,'Value',0);
set(handles.zoomon,'Value',0);
gui.put('xzoomlimit', []);
gui.put('yzoomlimit', []);

gui.sliderrange(1)
gui.sliderdisp(gui.retr('pivlab_axis'))
zoom reset

