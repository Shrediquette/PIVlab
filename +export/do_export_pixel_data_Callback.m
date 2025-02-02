function do_export_pixel_data_Callback(~, src, ~)
handles=gui.gethand;
filepath=gui.retr('filepath');
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
imgsavepath=gui.retr('imgsavepath');
if isempty(imgsavepath)
	imgsavepath=gui.retr('pathname');
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
	case 'Matlab Figure'
		formatstring={ '*.fig','Matlab figures (*.fig)'};
	case 'Archival AVI'
		formatstring={ '*.avi','uncompressed animation (*.avi)'};
	case 'MPEG-4'
		formatstring={ '*.mp4','compressed animation (*.mp4)'};
end
continue_export=1;
if startframe ~=endframe && gui.retr('displaywhat')>1 && get(handles.autoscaler,'Value') == 1 %user wants to export multiple frames and displays derivatives, and hasn't enabled a fixed colormap range
	answer = questdlg('You haven''t set fixed limits to the colormap. This might result in flickering of the colormap. Please select fixed limits of the colormap (disable autoscale). Continue anyway? ', 'Colormap limits are not fixed', 'Yes','No','No');
	if strcmp(answer , 'No')
		continue_export=0;
		gui.switchui('multip08');drawnow;
		old_bg=get(handles.autoscaler,'Backgroundcolor');
		for i=1:10 %highlight the setting that the user needs to change...
			set(handles.autoscaler,'Backgroundcolor',[1 0.2 0.2])
			pause(0.15)
			set(handles.autoscaler,'Backgroundcolor',old_bg)
			pause(0.15)
		end
	end
end

if continue_export==1
	[filename, pathname] = uiputfile(formatstring, 'Save images as',fullfile(imgsavepath, 'PIVlab_out'));
else
	filename=0;pathname=0;
end
if ~isequal(filename,0) && ~isequal(pathname,0)
	gui.put('imgsavepath',pathname );
	[Dir, Name, Ext] = fileparts(filename);

	resolution=str2double(get(handles.resolution_setting,'String'));
	quality=str2double(get(handles.quality_setting,'String'));
	fps=str2double(get(handles.fps_setting,'String'));

	pivlab_axis=gui.retr('pivlab_axis');
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
	gui.put('export_axis',export_axis);
	pause(0.01)
	try
		%~isempty(findobj(export_figure,'type','figure')) %figure still exists
		for i=startframe:endframe
			set(export_figure,'Name',[num2str(round((i-1)/(endframe-startframe)*100)) ' % Exporting, please wait. Please don''t close or resize this window.']);
			newfilename=[Name sprintf('_%03d',i) Ext];
			set(handles.fileselector, 'value',i)
			gui.sliderdisp(export_axis);%hiergehtesschief
			%set(export_axis,'box','on','LineWidth',1,'Color','k')
			switch selected_format
				case 'PNG'
					if use_exportfig
						export.exportfig(export_figure,fullfile(pathname,newfilename),'Format','bmp','color','rgb','linemode','scaled','FontMode','scaled','FontSizeMin',16,'Bounds','loose','resolution',resolution)
						export.autocrop(fullfile(pathname,newfilename),0);
					else
						exportgraphics(export_axis,fullfile(pathname,newfilename),'ContentType','image','resolution',resolution)
					end
				case 'JPG'
					if use_exportfig
						export.exportfig(export_figure,fullfile(pathname,newfilename),'Format','bmp','color','rgb','linemode','scaled','FontMode','scaled','FontSizeMin',16,'Bounds','loose','resolution',resolution)
						export.autocrop(fullfile(pathname,newfilename),1);
					else
						exportgraphics(export_axis,fullfile(pathname,newfilename),'ContentType','image','resolution',resolution);
					end
				case 'PDF'
					if use_exportfig
						set(export_figure,'Units','inches');
						pos = get(export_figure,'Position');
						set(export_figure,'PaperPositionMode','auto','PaperUnits','inches','PaperPosition',[0,0,pos(3),pos(4)],'PaperSize',[pos(3), pos(4)])
						export.exportfig(export_figure,fullfile(pathname,newfilename),'Format','pdf','color','CMYK','linemode','scaled','FontMode','scaled','FontSizeMin',16,'Bounds','loose','resolution',resolution)
					else
						exportgraphics(export_axis,fullfile(pathname,newfilename),'ContentType','vector','resolution',resolution);
					end
				case 'Matlab Figure'
					set(export_figure,'Name',fullfile(pathname,newfilename),'NumberTitle','on','visible','on','units','pixels','Toolbar','figure','DockControls','on','WindowState','normal','Color','w','WindowStyle','normal');
					savefig(export_figure,fullfile(pathname,newfilename),'compact');
				case 'Archival AVI'
					pixeldata=getframe(export_figure);
					export_image=frame2im(pixeldata);
					if i==startframe %this makes sure that frame sizes keep the same size
						[export_image,croprect] = export.autocrop(export_image,3);
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
						[export_image,croprect] = export.autocrop(export_image,3);
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
		if ~isdeployed
			commandwindow;
		end
	end
	try
		close(export_figure)
	catch
	end
	set(handles.fileselector, 'value',startframe)
	gui.sliderdisp(pivlab_axis)
end