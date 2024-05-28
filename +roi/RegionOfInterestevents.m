function RegionOfInterestevents(src,evt)
evname = evt.EventName;
handles=gui.gui_gethand;
switch(evname)
	%case{'MovingROI'}
	%disp(['ROI moving previous position: ' mat2str(evt.PreviousPosition)]);
	%disp(['ROI moving current position: ' mat2str(evt.CurrentPosition)]);
	case{'MovingROI'}
		imagesize=gui.gui_retr('expected_image_size');
		roirect = round(src.Position);

		if roirect(1)<1
			roirect(1)=1;
		end
		if roirect(2)<1
			roirect(2)=1;
		end
		if roirect(3)>imagesize(2)-roirect(1)
			roirect(3)=imagesize(2)-roirect(1);
		end
		if roirect(4)>imagesize(1)-roirect(2)
			roirect(4)=imagesize(1)-roirect(2);
		end
		if roirect(3)==0 || roirect(4)==0
			src.Label = ['Click and drag with the mouse to draw a rectangle'];
			src.Position(3)=50;
			src.Position(4)=50;
			pause(1)
			delete(findobj('tag', 'RegionOfInterest'))
			roi_1.roi_clear_roi_Callback
		else
			src.Label = ['x: ' num2str(roirect(1)) '   y: ' num2str(roirect(2)) '   w: ' num2str(roirect(3)) '   h: ' num2str(roirect(4))];
			gui.gui_put('roirect',roirect);
			roi_1.roi_updateROIinfo
		end

	case{'DeletingROI'}
		delete(findobj('tag', 'RegionOfInterest'))
		roi_1.roi_clear_roi_Callback
end

