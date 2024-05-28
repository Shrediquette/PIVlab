function add_Callback(~,~,type)
%masken sollten nur im Maskenpanel als ROIs angezeigt werden ud editierbar sein. Ansonsten als Pixeloverlay. Oder als schnell zecihnendes Polygon. bzw. auch gerne als ROI objekt ohne hittest und editable
handles=gui.gethand;
%variable masks_in_frame ist cell mit inhalt mask_positions für jeden frame (nicht doppelt machen...)
filepath=gui.retr('filepath');
if size(filepath,1) > 1 %did the user load images?
	set(handles.mask_edit_mode,'Value',1) %switch to edit mask mode when drawing a new mask.
	%gui.sliderdisp(gui.retr('pivlab_axis'));
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
	if isempty(mask_positions)
		mask_positions=cell(0);
	end
	masknums=size(mask_positions,1);
	if strcmp(type,'freehand')
		roi = images.roi.Freehand;
		roi.Multiclick=0;
	elseif strcmp(type,'assisted')
		roi = images.roi.AssistedFreehand;
		type='freehand';
	elseif strcmp(type,'rectangle')
		roi = images.roi.Rectangle;
	elseif strcmp(type,'polygon')
		roi = images.roi.Polygon;
	elseif strcmp(type,'circle')
		roi = images.roi.Circle;
	end
	recommended_colors=parula(7);
	roi.Color=recommended_colors(mod(size(mask_positions,1),6)+1,:);%rand(1,3);
	roi.FaceAlpha=0.75;
	roi.LabelVisible = 'off';
	roi.UserData=['ROI_object_' type];

	[~,guid] = fileparts(tempname);
	roi.Tag = guid; %unique id for every ROImask object.
	%addlistener(roi,'MovingROI',@ROIevents);
	gui.toolsavailable(0)

	draw(roi);
	addlistener(roi,'ROIMoved',@mask.ROIevents);
	addlistener(roi,'DeletingROI',@mask.ROIevents);
	addlistener(roi,'ROIClicked',@mask.ROIevents);
	gui.toolsavailable(1)
	handles=gui.gethand;
	currentframe=floor(get(handles.fileselector, 'value'));
	masks_in_frame = mask.update_mask_memory(roi,currentframe,masks_in_frame);
	gui.put('masks_in_frame',masks_in_frame);
end

