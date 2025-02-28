function update_velocity_limits_information
velrect=gui.retr('velrect');
handles=gui.gethand;
if gui.retr('darkmode')
	bg_col=[0 80/255 0];
else
	bg_col=[0.5 1 0.5];
end
set (handles.vel_limit_active, 'String', 'Limit active', 'backgroundcolor', bg_col);
umin=velrect(1);
umax=velrect(3)+umin;
vmin=velrect(2);
vmax=velrect(4)+vmin;
if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
	set (handles.limittext, 'String', ['valid u: ' num2str(round(umin*100)/100) ' to ' num2str(round(umax*100)/100) ' [px/frame]' sprintf('\n') 'valid v: ' num2str(round(vmin*100)/100) ' to ' num2str(round(vmax*100)/100) ' [px/frame]']);
else % calibrated
	displacement_only=gui.retr('displacement_only');
	if ~isempty(displacement_only) && displacement_only == 1
		set (handles.limittext, 'String', ['valid u: ' num2str(round(umin*100)/100) ' to ' num2str(round(umax*100)/100) ' [m/frame]' sprintf('\n') 'valid v: ' num2str(round(vmin*100)/100) ' to ' num2str(round(vmax*100)/100) ' [m/frame]']);
	else
		set (handles.limittext, 'String', ['valid u: ' num2str(round(umin*100)/100) ' to ' num2str(round(umax*100)/100) ' [m/s]' sprintf('\n') 'valid v: ' num2str(round(vmin*100)/100) ' to ' num2str(round(vmax*100)/100) ' [m/s]']);
	end
end
set (handles.vel_limit, 'String', 'Select rectangle');