function update_progress(progress_setpoint)
if progress_setpoint>100
	progress_setpoint=100;
end
if progress_setpoint<0
	progress_setpoint=0;
end
%handles=gui.gethand;
progress_temp1 = get(gui.retr('handle_toolprogress_bg'),'Position');
set(gui.retr('handle_toolprogress_fg'),'Position',[progress_temp1(1) progress_temp1(2) round(progress_temp1(3)/100*progress_setpoint) progress_temp1(4)],'Backgroundcolor',[1-progress_setpoint/100 progress_setpoint/100 0.1]);
if progress_setpoint == 0
	set(gui.retr('handle_toolprogress_bg'),'Backgroundcolor',[0.85 0.85 0.85])
else
	set(gui.retr('handle_toolprogress_bg'),'Backgroundcolor',[1 1 1])
end
drawnow limitrate
