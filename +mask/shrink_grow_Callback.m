function shrink_grow_Callback (~,caller,~)
pivlab_axis=gui.retr('pivlab_axis');
objects_in_axis=pivlab_axis.Children;
found=0;
for i=1:numel(objects_in_axis)
	if strncmp(objects_in_axis(i).UserData,'ROI_object_',11) %finds all Mask ROI objects, the first found is the one in the foreground
		found=1;
		break
	end
end
if found
	if strcmp (caller.Source.Tag,'mask_shrink')
		buf=-5;
	end
	if strcmp (caller.Source.Tag,'mask_grow')
		buf=+5;
	end
	if strcmp(objects_in_axis(i).UserData,'ROI_object_freehand') || strcmp(objects_in_axis(i).UserData,'ROI_object_polygon') || strcmp(objects_in_axis(i).UserData,'ROI_object_external')
		warning off
		poly_obj=polyshape(objects_in_axis(i).Position);
		warning on

		polyout1 = polybuffer(poly_obj,buf,'JointType','miter','MiterLimit',2);
		try
			objects_in_axis(i).Position=polyout1.Vertices;
		catch ME
			warning('Operation failed, most likely because shape is self-intersecting.')
		end
	elseif strcmp(objects_in_axis(i).UserData,'ROI_object_circle')
		objects_in_axis(i).Radius = objects_in_axis(i).Radius+buf;
	elseif strcmp(objects_in_axis(i).UserData,'ROI_object_rectangle')
		objects_in_axis(i).Position(1)=objects_in_axis(i).Position(1)-buf/2;
		objects_in_axis(i).Position(2)=objects_in_axis(i).Position(2)-buf/2;
		objects_in_axis(i).Position(3)=objects_in_axis(i).Position(3)+buf;
		objects_in_axis(i).Position(4)=objects_in_axis(i).Position(4)+buf;
	end
	evt.EventName='ROIMoved';
	mask.ROIevents(objects_in_axis(i),evt); %saves the modified position.
end

