function poly_ROIevents(src,evt)
evname = evt.EventName;
handles=gui.gui_gethand;
switch(evname)
	case{'MovingROI'}
		if strcmp(src.Tag,'extract_poly') || strcmp(src.Tag,'extract_poly_area')
			if size(src.Position,1)<6
				labelstring=[];
				for i = 1:size(src.Position,1)
					labelstring=[labelstring num2str(round(src.Position(i,1))) ',' num2str(round(src.Position(i,2))) ' ; ']; %#ok<AGROW>
				end
				src.Label = labelstring;
				if strcmp (src.LabelVisible,'off')
					src.LabelVisible = 'hover';
				end
			else
				if strcmp (src.LabelVisible,'hover')
					src.LabelVisible = 'off';
				end
			end
		end
	case{'ROIMoved'}
		if strcmp(src.Tag,'extract_poly') || strcmp(src.Tag,'extract_poly_area')
			gui.gui_put('xposition',src.Position(:,1));
			gui.gui_put('yposition',src.Position(:,2));
		end
		if strcmp(src.Tag,'extract_circle') || strcmp(src.Tag,'extract_circle_area')
			gui.gui_put('xposition',src.Center);
			gui.gui_put('yposition',src.Radius);
		end
		if strcmp(src.Tag,'extract_rectangle_area')
			gui.gui_put('xposition',[src.Position(1) src.Position(3)]); %x and width of rectangle
			gui.gui_put('yposition',[src.Position(2) src.Position(4)]); %y and height of rectangle
		end
		if strcmp(src.Tag,'extract_circle_series') ||strcmp(src.Tag,'extract_circle_series_area')
			delete(findobj(gui.gui_retr('pivlab_axis'),'Tag',[src.Tag '_displayed_smaller_radii']))
			delete(findobj(gui.gui_retr('pivlab_axis'),'Tag',[src.Tag '_max_circulation']))
			currentframe=floor(get(handles.fileselector, 'value'));
			pivlab_axis=gui.gui_retr('pivlab_axis');
			resultslist=gui.gui_retr('resultslist');
			x=resultslist{1,currentframe};
			stepsize=ceil((x(1,2)-x(1,1))/1);
			radii=linspace(stepsize,src.Radius-stepsize,round(((src.Radius-stepsize)/stepsize)));
			for radius=radii
				extract_poly_series=drawcircle(gui.gui_retr('pivlab_axis'),'Center',src.Center,'Radius',radius,'Tag',[src.Tag '_displayed_smaller_radii'],'Deletable',0,'FaceAlpha',0,'FaceSelectable',0,'InteractionsAllowed','none');
			end
			x_center=src.Center(1);
			y_center=src.Center(2);
			radius=src.Radius;
			text(pivlab_axis,x_center,y_center+radius,' start/end','FontSize',7, 'Rotation', 90, 'BackgroundColor',[1 1 1],'tag',[src.Tag '_displayed_smaller_radii'])
			text(pivlab_axis,x_center,y_center+radius+8,'\rightarrow','FontSize',7, 'BackgroundColor',[1 1 1],'tag',[src.Tag '_displayed_smaller_radii'])
			text(pivlab_axis,x_center,y_center-radius-8,'\leftarrow','FontSize',7, 'BackgroundColor',[1 1 1],'tag',[src.Tag '_displayed_smaller_radii'])
			text(pivlab_axis,x_center-radius-8,y_center,'\leftarrow','FontSize',7, 'BackgroundColor',[1 1 1], 'Rotation', 90,'tag',[src.Tag '_displayed_smaller_radii'])
			text(pivlab_axis,x_center+radius+8,y_center,'\rightarrow','FontSize',7, 'BackgroundColor',[1 1 1], 'Rotation', 90,'tag',[src.Tag '_displayed_smaller_radii'])
			gui.gui_put('xposition',src.Center);
			gui.gui_put('yposition',src.Radius);
		end
	case{'DeletingROI'}
		if strcmp(src.Tag,'extract_circle_series')
			delete(findobj(gui.gui_retr('pivlab_axis'),'Tag',[src.Tag '_displayed_smaller_radii']))
		end
		delete(findobj(gui.gui_retr('pivlab_axis'),'Tag',src.Tag))
		gui.gui_put('xposition',[]);
		gui.gui_put('yposition',[]);
		gui.gui_put('extract_type',[]);
end

