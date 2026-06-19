function smooth_mode_Callback(hObject, ~, ~)
% Toggle the temporal-window row depending on the selected data-smoothing mode.
% 1 = None, 2 = 2D, 3 = time (moving average), 4 = 2D + time.
handles=gui.gethand;
m=get(hObject,'Value');
if m==3 || m==4
	vis='on';
else
	vis='off';
end
set(handles.temporal_window,      'Visible', vis);
set(handles.text_temporal_window, 'Visible', vis);

end
