function clear_roi_Callback(~, ~, ~)
handles=gui.gethand;
delete(findobj('tag', 'RegionOfInterest'))
delete(findobj('tag', 'roiplot'));
gui.put ('roirect',[]);
if gui.retr('darkmode')
set(handles.roi_hint, 'String', 'ROI inactive', 'backgroundcolor', [35/255 35/255 35/255]);
else
	set(handles.roi_hint, 'String', 'ROI inactive', 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
end
set(handles.ROI_Man_x,'String','');
set(handles.ROI_Man_y,'String','');
set(handles.ROI_Man_w,'String','');
set(handles.ROI_Man_h,'String','');

