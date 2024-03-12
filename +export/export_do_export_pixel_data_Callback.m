function export_do_export_pixel_data_Callback(~, src, ~)
handles=gui.gui_gethand;
filepath=gui.gui_retr('filepath');
if strmatch(src.Source.Tag,'do_export_pixel_data')
	startframe=str2num(get(handles.firstframe,'string'));
	if startframe <1
		startframe=1;
	elseif startframe>size(filepath,1)/2
		startframe=size(filepath,1)/2;
	end
	set(handles.firstframe,'string',int2str(startframe));
	endframe=str2num(get(handles.lastframe,'string'));
	if endframe <startframe
		endframe=startframe;
	elseif endframe>size(filepath,1)/2
		endframe=size(filepath,1)/2;
	end
	set(handles.lastframe,'string',int2str(endframe));
else
	startframe=floor(get(handles.fileselector, 'value'));
	endframe=startframe;
end
imgsavepath=gui.gui_retr('imgsavepath');
if isempty(imgsavepath)
	imgsavepath=gui.gui_retr('pathname');
end

str=get(handles.export_still_or_animation,'String');
value=get(handles.export_still_or_animation,'Value');
selected_format=str{value};

switch selected_format
	case 'PNG'
		formatstring={ '*.png','uncompressed image(s) (*.png)'};
	case 'JPG'
		formatstring={ '*.jpg','compressed image(s) (*.jpg)'};
	case 'PDF'
		formatstring={ '*.pdf','vector images (*.pdf)'};
	case 'Archival AVI'
		formatstring={ '*.avi','uncompressed animation (*.avi)'};
	case 'MPEG-4'
		formatstring={ '*.mp4','compressed animation (*.mp4)'};
end

[filename, pathname] = uiputfile(formatstring, 'Save images as',fullfile(imgsavepath, 'PIVlab_out'));

if ~isequal(filename,0) && ~isequal(pathname,0)
	gui.gui_put('imgsavepath',pathname );
	[Dir, Name, Ext] = fileparts(filename);

	resolution=str2double(get(handles.resolution_setting,'String'));
	quality=str2double(get(handles.quality_setting,'String'));
	fps=str2double(get(handles.fps_setting,'String'));

	pivlab_axis=gui.gui_retr('pivlab_axis');
	%cant make this invisible, because matlab then doesnt render properly... :-(
	export_figure=figure('Name','Exporting, please wait. Please don''t close or resize this window.','NumberTitle','off','visible','on','units','pixels','Toolbar','none','DockControls','off','WindowState','normal','Color','w','WindowStyle','modal');
	set(export_figure,'units','normalized','outerposition',[0 0 1 1]) %unfortunately, setting figure to fullscreen still reports a non-fullscreen position in matlab...

	if verLessThan('matlab','9.8')  %2020a and up contains exportgraphics
		use_exportfig =1;
	else
		use_exportfig =0;
	end
	%use_exportfig =1;
	%change the aspect ratio of the figure window to match the aspect of the underlying data. Needs to deal with colorbars and axes resizing.
	%{
	%testweise ausgeschaltet
	axes_childs=get(pivlab_axis,'Children');
	pixel_height=size(axes_childs(end).CData,1); %lowest layer is pixel image
	pixel_width=size(axes_childs(end).CData,2);
	data_aspect_ratio=pixel_width/pixel_height;
	last_units=get(export_figure,'Units');
	set(export_figure,'Units','pixels');
	drawnow
	current_figure_size=get(export_figure,'position');
	current_figure_aspect_ratio=current_figure_size(3)/current_figure_size(4);
	if data_aspect_ratio<current_figure_aspect_ratio
		set(export_figure,'position',[current_figure_size(1),current_figure_size(2),current_figure_size(4)*data_aspect_ratio,current_figure_size(4)]);
	else %higher than wide
		set(export_figure,'position',[current_figure_size(1),current_figure_size(2),current_figure_size(3),current_figure_size(4)/data_aspect_ratio]);
	end
	set(export_figure,'Units',last_units);
	%}
	export_axis=axes('parent',export_figure);
	gui.gui_put('export_axis',export_axis);
	pause(0.01)
	try
		%~isempty(findobj(export_figure,'type','figure')) %figure still exists
		for i=startframe:endframe
			set(export_figure,'Name',[num2str(round((i-1)/(endframe-startframe)*100)) ' % Exporting, please wait. Please don''t close or resize this window.']);
			newfilename=[Name sprintf('_%03d',i) Ext];
			set(handles.fileselector, 'value',i)
			gui.gui_sliderdisp(export_axis)
			%set(export_axis,'box','on','LineWidth',1,'Color','k')
			switch selected_format
				case 'PNG'
					if use_exportfig
						exportfig(export_figure,fullfile(pathname,newfilename),'Format','bmp','color','rgb','linemode','scaled','FontMode','scaled','FontSizeMin',16,'Bounds','loose','resolution',resolution)
						export.export_autocrop(fullfile(pathname,newfilename),0);
					else
						exportgraphics(export_axis,fullfile(pathname,newfilename),'ContentType','image','resolution',resolution)
					end
				case 'JPG'
					if use_exportfig
						exportfig(export_figure,fullfile(pathname,newfilename),'Format','bmp','color','rgb','linemode','scaled','FontMode','scaled','FontSizeMin',16,'Bounds','loose','resolution',resolution)
						export.export_autocrop(fullfile(pathname,newfilename),1);
					else
						exportgraphics(export_axis,fullfile(pathname,newfilename),'ContentType','image','resolution',resolution);
					end
				case 'PDF'
					if use_exportfig
						set(export_figure,'Units','inches');
						pos = get(export_figure,'Position');
						set(export_figure,'PaperPositionMode','auto','PaperUnits','inches','PaperPosition',[0,0,pos(3),pos(4)],'PaperSize',[pos(3), pos(4)])
						exportfig(export_figure,fullfile(pathname,newfilename),'Format','pdf','color','CMYK','linemode','scaled','FontMode','scaled','FontSizeMin',16,'Bounds','loose','resolution',resolution)
					else
						exportgraphics(export_axis,fullfile(pathname,newfilename),'ContentType','vector','resolution',resolution);
					end
				case 'Archival AVI'
					pixeldata=getframe(export_figure);
					export_image=frame2im(pixeldata);
					if i==startframe %this makes sure that frame sizes keep the same size
						[export_image,croprect] = export.export_autocrop(export_image,3);
					else
						export_image=export_image(croprect(1):croprect(2),croprect(3):croprect(4),:);
					end
					if i==startframe
						v = VideoWriter(fullfile(pathname,filename),'Uncompressed AVI'); %#ok<TNMLP>
						v.FrameRate=fps;
						open(v);
					end
					writeVideo(v,export_image);
					if i==endframe
						close(v);
					end
				case 'MPEG-4'
					pixeldata=getframe(export_figure);
					export_image=frame2im(pixeldata);
					if i==startframe %this makes sure that frame sizes keep the same size
						[export_image,croprect] = export.export_autocrop(export_image,3);
					else
						export_image=export_image(croprect(1):croprect(2),croprect(3):croprect(4),:);
					end
					if i==startframe
						v = VideoWriter(fullfile(pathname,filename),'MPEG-4'); %#ok<TNMLP>
						v.FrameRate=fps;
						v.Quality=quality;
						open(v);
					end
					writeVideo(v,export_image);
					if i==endframe
						close(v);
					end
			end
		end
	catch ME
		try
			set (export_figure,'WindowStyle','normal')
			close(export_figure)
		catch
		end
		disp(ME.identifier)
		disp(ME.message)
		commandwindow;
	end
	try
		close(export_figure)
	catch
	end
	set(handles.fileselector, 'value',startframe)
	gui.gui_sliderdisp(pivlab_axis)
end

