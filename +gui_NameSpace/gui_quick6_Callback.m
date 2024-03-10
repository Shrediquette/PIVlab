function gui_quick6_Callback (~,~)
handles=gui_NameSpace.gui_gethand;
set(handles.quick6,'Value',0)
calibrate_NameSpace.calibrate_cal_actual_Callback
