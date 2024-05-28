function converted_mask=combine(mask_size,mask_positions)
mask_size=mask_size(1:2);
editedMask = zeros(mask_size,'uint8');
if ~isempty(mask_positions)
	for i=1:size(mask_positions,1)
		if 	strcmp(mask_positions{i,1},'ROI_object_freehand')	|| strcmp(mask_positions{i,1},'ROI_object_polygon') || strcmp(mask_positions{i,1},'ROI_object_external')
			xi=mask_positions{i,2}(:,1);
			yi=mask_positions{i,2}(:,2);
			editedMask = editedMask + uint8(poly2mask(xi,yi,mask_size(1),mask_size(2)));
		elseif strcmp(mask_positions{i,1},'ROI_object_rectangle')
			bbox=mask_positions{i,2};
			rectangle_coords = zeros(4, 2, 'like', bbox);
			rectangle_coords(1, 1) = bbox(:, 1);
			rectangle_coords(1, 2) = bbox(:, 2);
			rectangle_coords(2, 1) = bbox(:, 1) + bbox(:, 3);
			rectangle_coords(2, 2) = bbox(:, 2);
			rectangle_coords(3, 1) = bbox(:, 1) + bbox(:, 3);
			rectangle_coords(3, 2) = bbox(:, 2) + bbox(:, 4);
			rectangle_coords(4, 1) = bbox(:, 1);
			rectangle_coords(4, 2) = bbox(:, 2) + bbox(:, 4);
			editedMask = editedMask + uint8(poly2mask(rectangle_coords(:,1),rectangle_coords(:,2),mask_size(1),mask_size(2)));
		elseif strcmp(mask_positions{i,1},'ROI_object_circle')
			nsides_that_make_sense = floor(sqrt(2*pi()*mask_positions{i,2}(3)/1));
			pgon = nsidedpoly(nsides_that_make_sense,'Center',mask_positions{i,2}(1:2),'Radius',mask_positions{i,2}(3));
			editedMask = editedMask + uint8(poly2mask(pgon.Vertices(:,1),pgon.Vertices(:,2),mask_size(1),mask_size(2)));
		end
	end
end

delete(findobj('UserData','ROI_object_freehand'));
delete(findobj('UserData','ROI_object_rectangle'));
delete(findobj('UserData','ROI_object_circle'));
delete(findobj('UserData','ROI_object_polygon'));
delete(findobj('UserData','ROI_object_external'));

converted_mask = logical(editedMask); %adds all elements
masks_in_frame = gui.gui_retr('masks_in_frame');
handles=gui.gui_gethand;
current_mask_nr=floor(get(handles.fileselector, 'value'));
masks_in_frame{1,current_mask_nr}={}; %remove existing before combining
blocations = bwboundaries(converted_mask,'holes');
masks_in_frame=mask.mask_px_to_rois(blocations,current_mask_nr,masks_in_frame);%apply mask at the current frame and the following frames.
gui.gui_put('masks_in_frame',masks_in_frame);
gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'));