function clear_Callback(~, ~, ~)
handles=gui.gui_gethand;
delete(findobj('tag', 'RegionOfInterest'))
delete(findobj('tag', 'roiplot'));
gui.gui_put ('roirect',[]);
set(handles.roi_hint, 'String', 'ROI inactive', 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
set(handles.ROI_Man_x,'String','');
set(handles.ROI_Man_y,'String','');
set(handles.ROI_Man_w,'String','');
set(handles.ROI_Man_h,'String','');

