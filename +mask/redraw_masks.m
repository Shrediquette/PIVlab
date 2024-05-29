function redraw_masks
%redraws all masks that are saved in mask_positions
handles=gui.gethand;

if get(handles.mask_edit_mode,'Value')==1 %Mask mode is "Edit"
	mask_editing_possible=1;
else
	mask_editing_possible=0;
end
currentframe=floor(get(handles.fileselector, 'value'));
masks_in_frame=gui.retr('masks_in_frame');
if isempty(masks_in_frame)
	%masks_in_frame=cell(currentframe,1);
	masks_in_frame=cell(1,currentframe);
end
if numel(masks_in_frame)<currentframe
	mask_positions=cell(0);
else
	mask_positions=masks_in_frame{currentframe};
end
delete(findobj({'UserData','ROI_object_freehand','-or','UserData','ROI_object_rectangle','-or','UserData','ROI_object_circle','-or','UserData','ROI_object_polygon','-or','UserData','ROI_object_external'})); % deletes visible ROIs before redrawing.
masknums=size(mask_positions,1);
if mask_editing_possible==1
	for i=1:masknums
		type=mask_positions(i,1);
		if strcmp(type,'ROI_object_freehand')
			regionOfInterest = drawfreehand('Position', mask_positions{i,2});
			regionOfInterest.Multiclick=0;
		elseif strcmp(type,'ROI_object_rectangle')
			regionOfInterest = drawrectangle('Position', mask_positions{i,2});
		elseif strcmp(type,'ROI_object_polygon')
			regionOfInterest = drawpolygon('Position', mask_positions{i,2});
		elseif strcmp(type,'ROI_object_circle')
			circledata=mask_positions{i,2}; %whyTF does the circle needs to have center and radius.....?!? Why not Position like all other ROIs....?!?
			regionOfInterest = drawcircle('Center',circledata(1:2),'Radius',circledata(3));
		elseif strcmp(type,'ROI_object_external')
			regionOfInterest = drawfreehand('Position', mask_positions{i,2});
		end
		regionOfInterest.UserData=mask_positions{i,1};
		regionOfInterest.Label=mask_positions{i,4};
		regionOfInterest.Tag=mask_positions{i,5};
		regionOfInterest.Color=mask_positions{i,3};
		addlistener(regionOfInterest,'ROIMoved',@mask.ROIevents);
		addlistener(regionOfInterest,'DeletingROI',@mask.ROIevents);
		addlistener(regionOfInterest,'ROIClicked',@mask.ROIevents);
		regionOfInterest.FaceAlpha=0.5;
		%regionOfInterest.EdgeAlpha=0.75;
		regionOfInterest.LineWidth=1;
		regionOfInterest.LabelVisible = 'off';
	end
end

