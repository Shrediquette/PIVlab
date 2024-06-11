function masks_in_frame=px_to_rois(blocations,frame,masks_in_frame)
recommended_colors=parula(7);
for ind = 1:numel(blocations)
	if numel(masks_in_frame)<frame
		mask_positions=cell(0);
	else
		mask_positions=masks_in_frame{frame};
	end
	if isempty(mask_positions)
		mask_positions=cell(0);
	end

	% Convert to x,y order.
	pos = blocations{ind};
	pos = fliplr(pos);
	% Create a freehand ROI.
	regionOfInterest = drawfreehand('Position', pos);
	reduce(regionOfInterest,0.005)
	regionOfInterest.Color=recommended_colors(mod(size(mask_positions,1),6)+1,:);%rand(1,3);
	regionOfInterest.FaceAlpha=0.75;
	regionOfInterest.LabelVisible = 'off';
	regionOfInterest.UserData=['ROI_object_' 'external'];

	[~,guid] = fileparts(tempname);
	regionOfInterest.Tag = guid;
	%addlistener(regionOfInterest,'MovingROI',@ROIevents);
	addlistener(regionOfInterest,'ROIMoved',@mask.ROIevents);
	addlistener(regionOfInterest,'DeletingROI',@mask.ROIevents);
	addlistener(regionOfInterest,'ROIClicked',@mask.ROIevents);
	masks_in_frame = mask.update_mask_memory(regionOfInterest,frame,masks_in_frame);
end

