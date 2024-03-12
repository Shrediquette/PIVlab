function calibrate_Offsetselectionevents(src,evt)
evname = evt.EventName;
handles=gui.gui_gethand;
switch(evname)
	%case{'MovingROI'}
	%disp(['ROI moving previous position: ' mat2str(evt.PreviousPosition)]);
	%disp(['ROI moving current position: ' mat2str(evt.CurrentPosition)]);
	case{'MovingROI'}
		Offset_coords = src.Position;
		points_offsetx=gui.gui_retr('points_offsetx');
		points_offsety=gui.gui_retr('points_offsety');
		if numel(points_offsetx)==0
			old_true_offsetx=0;
		else
			old_true_offsetx=points_offsetx(3);
		end
		if numel(points_offsety)==0
			old_true_offsety=0;
		else
			old_true_offsety=points_offsety(3);
		end

		if ~isempty(points_offsetx)
			src.Label = ['X: ' num2str(round(src.Position(1),1)) ' px = ' num2str(old_true_offsetx) ' mm ; Y: ' num2str(round(src.Position(2),1)) ' px = ' num2str(old_true_offsety) ' mm'];
		end
		gui.gui_put('points_offsetx',[src.Position(1),src.Position(2),old_true_offsetx]);
		gui.gui_put('points_offsety',[src.Position(1),src.Position(2),old_true_offsety]);
		if gui.gui_retr('calu') ~=1
			calibrate.calibrate_calccali
		end
	case{'DeletingROI'}
		delete(findobj('tag', 'offsetroi'))
		gui.gui_put('points_offsetx',[]);
		gui.gui_put('points_offsety',[]);
		calibrate.calibrate_calccali
end

