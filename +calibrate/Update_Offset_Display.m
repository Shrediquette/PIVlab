function Update_Offset_Display
delete(findobj('tag', 'offsetroi'))
points_offsetx=gui.gui_retr('points_offsetx');
points_offsety=gui.gui_retr('points_offsety');
if numel(points_offsetx)>0 &&  numel(points_offsety)>0
	roi=drawcrosshair(gui.gui_retr('pivlab_axis'),'Position',[points_offsetx(1), points_offsetx(2)]);
	%roi.EdgeAlpha=0.75;
	roi.LabelVisible = 'on';
	roi.Tag = 'offsetroi';
	roi.Color = 'y';
	roi.LineWidth = 1;
	%roi.InteractionsAllowed='none';

	addlistener(roi,'MovingROI',@calibrate.calibrate_Offsetselectionevents);
	addlistener(roi,'DeletingROI',@calibrate.calibrate_Offsetselectionevents);
	dummyevt.EventName = 'MovingROI';
	calibrate.calibrate_Offsetselectionevents(roi,dummyevt); %run the moving event once to update displayed length
end

