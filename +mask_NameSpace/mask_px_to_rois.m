function masks_in_frame=mask_px_to_rois(blocations,frame,masks_in_frame)
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
	roi = drawfreehand('Position', pos);
	reduce(roi,0.005)
	roi.Color=recommended_colors(mod(size(mask_positions,1),6)+1,:);%rand(1,3);
	roi.FaceAlpha=0.75;
	roi.LabelVisible = 'off';
	roi.UserData=['ROI_object_' 'external'];

	[~,guid] = fileparts(tempname);
	roi.Tag = guid;
	%addlistener(roi,'MovingROI',@ROIevents);
	addlistener(roi,'ROIMoved',@mask_NameSpace.mask_ROIevents);
	addlistener(roi,'DeletingROI',@mask_NameSpace.mask_ROIevents);
	addlistener(roi,'ROIClicked',@mask_NameSpace.mask_ROIevents);
	masks_in_frame = mask_NameSpace.mask_update_mask_memory(roi,frame,masks_in_frame);
end
