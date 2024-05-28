function subdivide_simplify_Callback (~,caller,~)
pivlab_axis=gui.gui_retr('pivlab_axis');
objects_in_axis=pivlab_axis.Children;
found=0;
for i=1:numel(objects_in_axis)
	if strncmp(objects_in_axis(i).UserData,'ROI_object_',11) %finds all Mask ROI objects, the first found is the one in the foreground
		found=1;
		break
	end
end
if found
	if strcmp(objects_in_axis(i).UserData,'ROI_object_freehand') || strcmp(objects_in_axis(i).UserData,'ROI_object_polygon')|| strcmp(objects_in_axis(i).UserData,'ROI_object_external')
		if strcmp (caller.Source.Tag,'mask_optimize')
			%objects_in_axis(i).Waypoints(:) = true;
			reduce(objects_in_axis(i))
		else
			cx=objects_in_axis(i).Position(:,1);
			cy=objects_in_axis(i).Position(:,2);
			x=linspace(1,numel(cx),numel(cx))';
			if strcmp (caller.Source.Tag,'mask_subdivide')
				if numel(x) < 512 %limit over interpolation.
					multiplier=2;
				else
					multiplier=1;
				end
			elseif strcmp (caller.Source.Tag,'mask_simplify')
				if numel(x) > 3 %limit simplification.
					multiplier=0.75;
				else
					multiplier=1;
				end
			end
			xq=linspace(1,x(end),round(numel(cx)*multiplier))';
			cxq = interp1(x,cx,xq,'spline')	;
			cyq = interp1(x,cy,xq,'spline')	;
			objects_in_axis(i).Position=[cxq cyq];
			if strcmp(objects_in_axis(i).UserData,'ROI_object_freehand')
				objects_in_axis(i).Waypoints(:) = true;
			end
		end
		evt.EventName='ROIMoved';
		mask.mask_ROIevents(objects_in_axis(i),evt); %saves the modified position.
	end
end

