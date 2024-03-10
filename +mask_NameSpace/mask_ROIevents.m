function mask_ROIevents(src,evt)
evname = evt.EventName;
handles=gui_NameSpace.gui_gethand;
currentframe=floor(get(handles.fileselector, 'value'));
masks_in_frame=gui_NameSpace.gui_retr('masks_in_frame');
mask_positions=masks_in_frame{currentframe};
switch(evname)
	%case{'MovingROI'}
	%disp(['ROI moving previous position: ' mat2str(evt.PreviousPosition)]);
	%disp(['ROI moving current position: ' mat2str(evt.CurrentPosition)]);
	case{'ROIMoved'}
		if ~isempty(mask_positions)
			[r,~]=find(strcmp(src.Tag,mask_positions(:,5)));
			if ~isempty(r)
				if strcmp(src.UserData,'ROI_object_circle')
					mask_positions{r,2} = [src.Position src.Radius];
				else
					mask_positions{r,2}=src.Position; %update position of the moved ROI
				end
				%assignin('base',"mask_positions",mask_positions)
				masks_in_frame{currentframe}=mask_positions;
				gui_NameSpace.gui_put('masks_in_frame',masks_in_frame)
			end
		end
	case{'DeletingROI'}
		%Find the mask with the unique guid and delete it
		[r,~]=find(strcmp(src.Tag,mask_positions(:,5)));
		mask_positions(r,:)=[];
		masks_in_frame{currentframe}=mask_positions;
		gui_NameSpace.gui_put('masks_in_frame',masks_in_frame)
	case{'ROIClicked'}
		bringToFront(src);
end
