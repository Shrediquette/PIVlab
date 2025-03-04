function RegionOfInterestevents(src,evt)
evname = evt.EventName;
handles=gui.gethand;
switch(evname)
	%case{'MovingROI'}
	%disp(['ROI moving previous position: ' mat2str(evt.PreviousPosition)]);
	%disp(['ROI moving current position: ' mat2str(evt.CurrentPosition)]);
	case{'MovingROI'}
		roirect = src.Position;
		
			%src.Label = ['valid u: ' num2str(roirect(1)) '   y: ' num2str(roirect(2)) '   w: ' num2str(roirect(3)) '   h: ' num2str(roirect(4))];
			gui.put('velrect',roirect);
			validate.update_velocity_limits_information
		

	case{'DeletingROI'}
		
        
		validate.clear_vel_limit_Callback
end

