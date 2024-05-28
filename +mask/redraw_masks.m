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
			roi = drawfreehand('Position', mask_positions{i,2});
			roi.Multiclick=0;
		elseif strcmp(type,'ROI_object_rectangle')
			roi = drawrectangle('Position', mask_positions{i,2});
		elseif strcmp(type,'ROI_object_polygon')
			roi = drawpolygon('Position', mask_positions{i,2});
		elseif strcmp(type,'ROI_object_circle')
			circledata=mask_positions{i,2}; %whyTF does the circle needs to have center and radius.....?!? Why not Position like all other ROIs....?!?
			roi = drawcircle('Center',circledata(1:2),'Radius',circledata(3));
		elseif strcmp(type,'ROI_object_external')
			roi = drawfreehand('Position', mask_positions{i,2});
		end
		roi.UserData=mask_positions{i,1};
		roi.Label=mask_positions{i,4};
		roi.Tag=mask_positions{i,5};
		roi.Color=mask_positions{i,3};
		addlistener(roi,'ROIMoved',@mask.ROIevents);
		addlistener(roi,'DeletingROI',@mask.ROIevents);
		addlistener(roi,'ROIClicked',@mask.ROIevents);
		roi.FaceAlpha=0.5;
		%roi.EdgeAlpha=0.75;
		roi.LineWidth=1;
		roi.LabelVisible = 'off';
	end
end

