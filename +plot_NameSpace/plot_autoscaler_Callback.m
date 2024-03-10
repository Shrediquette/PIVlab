function plot_autoscaler_Callback(~, ~, ~)
handles=gui_NameSpace.gui_gethand;
if get(handles.autoscaler, 'value')==1
	set (handles.mapscale_min, 'enable', 'off')
	set (handles.mapscale_max, 'enable', 'off')
else
	set (handles.mapscale_min, 'enable', 'on')
	set (handles.mapscale_max, 'enable', 'on')
end
