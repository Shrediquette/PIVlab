function masks_in_frame = mask_update_mask_memory(roi,frame,masks_in_frame)

if isempty(masks_in_frame)
	%masks_in_frame=cell(frame,1);
	masks_in_frame=cell(1,frame);%das hier muss
end

if numel(masks_in_frame)<frame
	mask_positions=cell(0);
else
	mask_positions=masks_in_frame{frame};
end
if isempty(mask_positions)
	mask_positions=cell(0);
end

mask_positions{end+1,1}=roi.UserData;
if strcmp(roi.UserData,'ROI_object_circle')
	mask_positions{end,2}=[roi.Center roi.Radius];
else
	mask_positions{end,2}=roi.Position;
end
mask_positions{end,3}=roi.Color;
mask_positions{end,4}=roi.Label;
mask_positions{end,5}=roi.Tag;
masks_in_frame{frame}=mask_positions;

