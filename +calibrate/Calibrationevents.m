function Calibrationevents(src,evt)
evname = evt.EventName;
handles=gui.gethand;
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
		gui.put('pointscali',Cali_coords);
		calibrate.pixeldist_changed_Callback()
		if gui.retr('calu') ~=1
			calibrate.calccali
		end
	case{'DeletingROI'}
		delete(findobj('tag', 'caliline'))
		calibrate.clear_cali_Callback
end

