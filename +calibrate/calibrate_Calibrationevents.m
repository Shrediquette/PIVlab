function calibrate_Calibrationevents(src,evt)
evname = evt.EventName;
handles=gui.gui_gethand;
switch(evname)
	%case{'MovingROI'}
	%disp(['ROI moving previous position: ' mat2str(evt.PreviousPosition)]);
	%disp(['ROI moving current position: ' mat2str(evt.CurrentPosition)]);
	case{'MovingROI'}
		Cali_coords = src.Position;
		Cali_length = sqrt((Cali_coords(1,1)-Cali_coords(2,1))^2+(Cali_coords(1,2)-Cali_coords(2,2))^2);

		if Cali_length < 0.1
			src.Label = ['Click and drag with the mouse to draw a line'];
		else
			src.Label = ['Length :' num2str(Cali_length) ' px'];
		end
		gui.gui_put('pointscali',Cali_coords);
		calibrate.calibrate_pixeldist_changed_Callback()
		if gui.gui_retr('calu') ~=1
			calibrate.calibrate_calccali
		end
	case{'DeletingROI'}
		delete(findobj('tag', 'caliline'))
		calibrate.calibrate_clear_cali_Callback
end

