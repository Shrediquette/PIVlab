function acquisition_device_control_Callback (~,~,~)
try %try to switch of camera angle report
	stop(timerfind)
	delete(timerfind)
	set(getappdata(0,'handle_to_lens_timer_checkbox'),'Value',0)
catch
end
PIVlab_capture_devicectrl_GUI
