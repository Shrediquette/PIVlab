function RegionOfInterestevents(src,evt)
evname = evt.EventName;
if strcmpi('vel_limit_ROI_freehand',src.Tag)
	switch(evname)
		case{'MovingROI'}
			scatplot=src.Parent.Children.findobj('Type','Scatter');
			xdata=scatplot.XData;
			ydata=scatplot.YData;
			tf = inROI(src,xdata,ydata);
			CData=[1-double(tf) double(tf) double(tf)*0];
			set(scatplot,'CData',CData);
			freehandroirect = src.Position;
			gui.put('velrect_freehand',freehandroirect);
			validate.update_velocity_limits_information
		case{'DeletingROI'}
			validate.clear_vel_limit_Callback(src,'freehand_delete')
	end
elseif strcmpi('vel_limit_ROI',src.Tag)
	switch(evname)
		case{'MovingROI'}
			roirect = src.Position;
			%src.Label = ['valid u: ' num2str(roirect(1)) '   y: ' num2str(roirect(2)) '   w: ' num2str(roirect(3)) '   h: ' num2str(roirect(4))];
			gui.put('velrect',roirect);
			validate.update_velocity_limits_information
		case{'DeletingROI'}
			validate.clear_vel_limit_Callback(src,'rectangle_delete')
	end
end