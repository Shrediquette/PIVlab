function gui_update_progress(progress_setpoint)
%handles=gui.gui_gethand;
progress_temp1 = get(gui.gui_retr('handle_toolprogress_bg'),'Position');
set(gui.gui_retr('handle_toolprogress_fg'),'Position',[progress_temp1(1) progress_temp1(2) round(progress_temp1(3)/100*progress_setpoint) progress_temp1(4)],'Backgroundcolor',[1-progress_setpoint/100 progress_setpoint/100 0.1]);
if progress_setpoint == 0
	set(gui.gui_retr('handle_toolprogress_bg'),'Backgroundcolor',[0.85 0.85 0.85])
else
	set(gui.gui_retr('handle_toolprogress_bg'),'Backgroundcolor',[1 1 1])
end
drawnow limitrate
