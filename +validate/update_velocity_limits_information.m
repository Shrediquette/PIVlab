function update_velocity_limits_information
velrect=gui.gui_retr('velrect');
handles=gui.gui_gethand;
set (handles.vel_limit_active, 'String', 'Limit active', 'backgroundcolor', [0.5 1 0.5]);
umin=velrect(1);
umax=velrect(3)+umin;
vmin=velrect(2);
vmax=velrect(4)+vmin;
if (gui.gui_retr('calu')==1 || gui.gui_retr('calu')==-1) && gui.gui_retr('calxy')==1
	set (handles.limittext, 'String', ['valid u: ' num2str(round(umin*100)/100) ' to ' num2str(round(umax*100)/100) ' [px/frame]' sprintf('\n') 'valid v: ' num2str(round(vmin*100)/100) ' to ' num2str(round(vmax*100)/100) ' [px/frame]']);
else
	set (handles.limittext, 'String', ['valid u: ' num2str(round(umin*100)/100) ' to ' num2str(round(umax*100)/100) ' [m/s]' sprintf('\n') 'valid v: ' num2str(round(vmin*100)/100) ' to ' num2str(round(vmax*100)/100) ' [m/s]']);
end
set (handles.vel_limit, 'String', 'Refine velocity limits');

