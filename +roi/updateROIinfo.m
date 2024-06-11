function updateROIinfo
handles=gui.gethand;
roirect=gui.retr('roirect');
set(handles.ROI_Man_x,'String',int2str(roirect(1)));
set(handles.ROI_Man_y,'String',int2str(roirect(2)));
set(handles.ROI_Man_w,'String',int2str(roirect(3)));
set(handles.ROI_Man_h,'String',int2str(roirect(4)));
set(handles.roi_hint, 'String', 'ROI active' , 'backgroundcolor', [0.5 1 0.5]);

