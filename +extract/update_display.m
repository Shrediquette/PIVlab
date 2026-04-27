function update_display(extract_type, xposition, yposition, target_axis)
main_axis=gui.retr('pivlab_axis');
if nargin < 4 || isempty(target_axis)
	target_axis=main_axis;
end
is_main_axis=isequal(target_axis,main_axis);
if strcmp(extract_type,'extract_poly') %polyline
	extract_poly=drawpolyline(target_axis,'Position',[xposition yposition]);
	extract_poly.LabelVisible = 'off';
	extract_poly.Tag=extract_type;
	add_roi_listeners(extract_poly,is_main_axis,1);
end
if strcmp(extract_type,'extract_poly_area') %polygon
	extract_poly=drawpolygon(target_axis,'Position',[xposition yposition]);
	extract_poly.LabelVisible = 'off';
	extract_poly.Tag=extract_type;
	add_roi_listeners(extract_poly,is_main_axis,1);
end
if strcmp(extract_type,'extract_circle') || strcmp(extract_type,'extract_circle_area') %circle
	extract_poly=drawcircle(target_axis,'Center',xposition,'Radius',yposition);
	extract_poly.LabelVisible = 'off';
	extract_poly.Tag=extract_type;
	add_roi_listeners(extract_poly,is_main_axis,0);
end
if strcmp(extract_type,'extract_rectangle_area')  %rectangle
	extract_poly=drawrectangle(target_axis,'Position',[xposition(1) yposition(1) xposition(2) yposition(2)]);
	extract_poly.LabelVisible = 'off';
	extract_poly.Tag=extract_type;
	add_roi_listeners(extract_poly,is_main_axis,0);
end
if strcmp(extract_type,'extract_circle_series') || strcmp(extract_type,'extract_circle_series_area') %circle series
	extract_poly=drawcircle(target_axis,'Center',xposition,'Radius',yposition);
	extract_poly.LabelVisible = 'off';
	extract_poly.Tag=extract_type;
	add_roi_listeners(extract_poly,is_main_axis,0);
	handles=gui.gethand;
	currentframe=floor(get(handles.fileselector, 'value'));
	resultslist=gui.retr('resultslist');
	xposition=extract_poly.Center;
	try
		x=resultslist{1,currentframe};
    catch
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','You cannot load coordinates for non-analyzed frames.','modal');
	end
	stepsize=ceil((x(1,2)-x(1,1))/1);
	radii=linspace(stepsize,extract_poly.Radius-stepsize,round(((extract_poly.Radius-stepsize)/stepsize)));
	for radius=radii
		drawcircle(target_axis,'Center',xposition,'Radius',radius,'Tag',[extract_type '_displayed_smaller_radii'],'Deletable',0,'FaceAlpha',0,'FaceSelectable',0,'InteractionsAllowed','none');
	end
	x_center=extract_poly.Center(1);
	y_center=extract_poly.Center(2);
	radius=extract_poly.Radius;
	text(target_axis,x_center,y_center+radius,' start/end','FontSize',7, 'Rotation', 90, 'BackgroundColor',[1 1 1],'tag',[extract_type '_displayed_smaller_radii'])
	text(target_axis,x_center,y_center+radius+8,'\rightarrow','FontSize',7, 'BackgroundColor',[1 1 1],'tag',[extract_type '_displayed_smaller_radii'])
	text(target_axis,x_center,y_center-radius-8,'\leftarrow','FontSize',7, 'BackgroundColor',[1 1 1],'tag',[extract_type '_displayed_smaller_radii'])
	text(target_axis,x_center-radius-8,y_center,'\leftarrow','FontSize',7, 'BackgroundColor',[1 1 1], 'Rotation', 90,'tag',[extract_type '_displayed_smaller_radii'])
	text(target_axis,x_center+radius+8,y_center,'\rightarrow','FontSize',7, 'BackgroundColor',[1 1 1], 'Rotation', 90,'tag',[extract_type '_displayed_smaller_radii'])
end
end

function add_roi_listeners(extract_poly,is_main_axis,listen_moving)
if is_main_axis
	addlistener(extract_poly,'ROIMoved',@extract.poly_ROIevents);
	if listen_moving
		addlistener(extract_poly,'MovingROI',@extract.poly_ROIevents);
	end
	addlistener(extract_poly,'DeletingROI',@extract.poly_ROIevents);
else
	extract_poly.InteractionsAllowed='none';
	extract_poly.Deletable=0;
end
end
