function update_display(extract_type, xposition, yposition)
if strcmp(extract_type,'extract_poly') %polyline
	extract_poly=drawpolyline(gui.gui_retr('pivlab_axis'),'Position',[xposition yposition]);
	extract_poly.LabelVisible = 'off';
	extract_poly.Tag=extract_type;
	addlistener(extract_poly,'ROIMoved',@extract.extract_poly_ROIevents);
	addlistener(extract_poly,'MovingROI',@extract.extract_poly_ROIevents);
	addlistener(extract_poly,'DeletingROI',@extract.extract_poly_ROIevents);
end
if strcmp(extract_type,'extract_poly_area') %polygon
	extract_poly=drawpolygon(gui.gui_retr('pivlab_axis'),'Position',[xposition yposition]);
	extract_poly.LabelVisible = 'off';
	extract_poly.Tag=extract_type;
	addlistener(extract_poly,'ROIMoved',@extract.extract_poly_ROIevents);
	addlistener(extract_poly,'MovingROI',@extract.extract_poly_ROIevents);
	addlistener(extract_poly,'DeletingROI',@extract.extract_poly_ROIevents);
end
if strcmp(extract_type,'extract_circle') || strcmp(extract_type,'extract_circle_area') %circle
	extract_poly=drawcircle(gui.gui_retr('pivlab_axis'),'Center',xposition,'Radius',yposition);
	extract_poly.LabelVisible = 'off';
	extract_poly.Tag=extract_type;
	addlistener(extract_poly,'ROIMoved',@extract.extract_poly_ROIevents);
	addlistener(extract_poly,'DeletingROI',@extract.extract_poly_ROIevents);
end
if strcmp(extract_type,'extract_rectangle_area')  %rectangle
	extract_poly=drawrectangle(gui.gui_retr('pivlab_axis'),'Position',[xposition(1) yposition(1) xposition(2) yposition(2)]);
	extract_poly.LabelVisible = 'off';
	extract_poly.Tag=extract_type;
	addlistener(extract_poly,'ROIMoved',@extract.extract_poly_ROIevents);
	addlistener(extract_poly,'DeletingROI',@extract.extract_poly_ROIevents);
end
if strcmp(extract_type,'extract_circle_series') || strcmp(extract_type,'extract_circle_series_area') %circle series
	extract_poly=drawcircle(gui.gui_retr('pivlab_axis'),'Center',xposition,'Radius',yposition);
	extract_poly.LabelVisible = 'off';
	extract_poly.Tag=extract_type;
	addlistener(extract_poly,'ROIMoved',@extract.extract_poly_ROIevents);
	addlistener(extract_poly,'DeletingROI',@extract.extract_poly_ROIevents);
	handles=gui.gui_gethand;
	currentframe=floor(get(handles.fileselector, 'value'));
	resultslist=gui.gui_retr('resultslist');
	xposition=extract_poly.Center;
	yposition=extract_poly.Radius;
	try
		x=resultslist{1,currentframe};
	catch
		msgbox('You cannot load coordinates for non-analyzed frames.','Error','error','modal')
	end
	stepsize=ceil((x(1,2)-x(1,1))/1);
	radii=linspace(stepsize,extract_poly.Radius-stepsize,round(((extract_poly.Radius-stepsize)/stepsize)));
	for radius=radii
		extract_poly_series=drawcircle(gui.gui_retr('pivlab_axis'),'Center',xposition,'Radius',radius,'Tag',[extract_type '_displayed_smaller_radii'],'Deletable',0,'FaceAlpha',0,'FaceSelectable',0,'InteractionsAllowed','none');
	end
	x_center=extract_poly.Center(1);
	y_center=extract_poly.Center(2);
	radius=extract_poly.Radius;
	text(x_center,y_center+radius,' start/end','FontSize',7, 'Rotation', 90, 'BackgroundColor',[1 1 1],'tag',[extract_type '_displayed_smaller_radii'])
	text(x_center,y_center+radius+8,'\rightarrow','FontSize',7, 'BackgroundColor',[1 1 1],'tag',[extract_type '_displayed_smaller_radii'])
	text(x_center,y_center-radius-8,'\leftarrow','FontSize',7, 'BackgroundColor',[1 1 1],'tag',[extract_type '_displayed_smaller_radii'])
	text(x_center-radius-8,y_center,'\leftarrow','FontSize',7, 'BackgroundColor',[1 1 1], 'Rotation', 90,'tag',[extract_type '_displayed_smaller_radii'])
	text(x_center+radius+8,y_center,'\rightarrow','FontSize',7, 'BackgroundColor',[1 1 1], 'Rotation', 90,'tag',[extract_type '_displayed_smaller_radii'])
end

