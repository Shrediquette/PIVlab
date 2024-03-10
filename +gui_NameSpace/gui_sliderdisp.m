function gui_sliderdisp(target_axis) %this is the most important function, doing all the displaying
handles=gui_NameSpace.gui_gethand;
toggler=gui_NameSpace.gui_retr('toggler');
selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
filepath=gui_NameSpace.gui_retr('filepath');
capturing=gui_NameSpace.gui_retr('capturing');

if isempty(capturing)
	capturing=0;
end
if capturing==0
	filepath = import_NameSpace.import_Check_if_image_files_exist(filepath, selected);
	currentframe=2*floor(get(handles.fileselector, 'value'))-1;
	%display derivatives if available and desired...
	displaywhat=gui_NameSpace.gui_retr('displaywhat');
	derived=gui_NameSpace.gui_retr('derived');
	if ~isempty(derived) && size(derived,2)>=(currentframe+1)/2 && displaywhat > 1  && numel(derived{displaywhat-1,(currentframe+1)/2})>0 %derived parameters requested and existant
		vectorcolor=[str2double(get(handles.validdr,'string')) str2double(get(handles.validdg,'string')) str2double(get(handles.validdb,'string'))];
	else
		vectorcolor=[str2double(get(handles.validr,'string')) str2double(get(handles.validg,'string')) str2double(get(handles.validb,'string'))];
	end
	delete(findobj('tag', 'derivhint'));
	if size(filepath,1)>0
		if get(handles.zoomon,'Value')==1
			set(handles.zoomon,'Value',0);
			gui_NameSpace.gui_zoomon_Callback(handles.zoomon)
		end
		if get(handles.panon,'Value')==1
			set(handles.panon,'Value',0);
			gui_NameSpace.gui_panon_Callback(handles.panon)
		end
		xzoomlimit=gui_NameSpace.gui_retr('xzoomlimit');
		yzoomlimit=gui_NameSpace.gui_retr('yzoomlimit');
		%profile on
		currentimage = plot_NameSpace.plot_draw_pixel_background_overlay(target_axis,displaywhat, selected, handles, currentframe);
		%profile viewer
		axis (target_axis,'image');
		set(target_axis,'ytick',[])
		set(target_axis,'xtick',[])
		filename=gui_NameSpace.gui_retr('filename');
		gui_NameSpace.gui_set_bg_color_for_mean_imgs(currentframe, handles);
		if gui_NameSpace.gui_retr('video_selection_done') == 0
			set (handles.filenameshow, 'string', ['Frame (' int2str(floor(get(handles.fileselector, 'value'))) '/' int2str(size(filepath,1)/2) '):' sprintf('\n') filename{selected}]);
			set (handles.filenameshow, 'tooltipstring', filepath{selected});
		else %video loaded
			video_frame_selection=gui_NameSpace.gui_retr('video_frame_selection');
			set (handles.filenameshow, 'string', ['Frame (' int2str(floor(get(handles.fileselector, 'value'))) '/' int2str(size(filepath,1)/2) '):' sprintf('\n') filename{selected}]);
			%set (handles.filenameshow, 'string', ['Frame (' int2str(floor(get(handles.fileselector, 'value'))) '/' int2str(numel(video_frame_selection)/2) '):' sprintf('\n') filename]);
			set (handles.filenameshow, 'tooltipstring', filepath{selected});
		end
		if strncmp(get(handles.multip06, 'visible'), 'on',2) || strncmp(get(handles.multip23, 'visible'), 'on',2) %if in data validation panel
			validate_NameSpace.validate_count_discarded_data
		end
		if strncmp(get(handles.multip01, 'visible'), 'on',2)
			set(handles.imsize, 'string', ['Image size: ' int2str(size(currentimage,2)) '*' int2str(size(currentimage,1)) 'px' ])
		end

		roirect=gui_NameSpace.gui_retr('roirect');
		if size(roirect,2)>1
			roi_NameSpace.roi_dispStaticROI(target_axis);
		end

		resultslist=gui_NameSpace.gui_retr('resultslist');
		plot_NameSpace.plot_display_manual_markers(target_axis,handles);
		if size(resultslist,2)>=(currentframe+1)/2 && numel(resultslist{1,(currentframe+1)/2})>0
			[x, y, u, v, typevector] = plot_NameSpace.plot_get_desired_u_and_v(resultslist, currentframe);
			[u, v] = plot_NameSpace.plot_get_highpassed_vectors(handles, u, v);
			[vecskip, vecscale] = plot_NameSpace.plot_scale_vector_display(handles, x, y, u, v);
			[q, q2] = plot_NameSpace.plot_vectors(target_axis,handles, vecskip, x, typevector, y, u, vecscale, v, vectorcolor);
			plot_NameSpace.plot_streamlines(target_axis,u, v, typevector, x, y, handles);

			if target_axis==gui_NameSpace.gui_retr('pivlab_axis')
				img_handle=findobj('type','image');
				set(img_handle, 'ButtonDownFcn', @gui_NameSpace.gui_veclick, 'PickableParts', 'visible');
				set(q, 'ButtonDownFcn', @gui_NameSpace.gui_veclick, 'PickableParts', 'visible');
				set(q2, 'ButtonDownFcn', @gui_NameSpace.gui_veclick, 'PickableParts', 'visible');
			end
			if strncmp(get(handles.multip14, 'visible'), 'on',2) %statistics panel visible
				plot_NameSpace.plot_update_Stats (x,y,u,v);
			end
			if strncmp(get(handles.multip12, 'visible'), 'on',2) || strncmp(get(handles.multip17, 'visible'), 'on',2) %extract poly panel visible
				%draw extraction polygon when frame was changed.
				pivlab_axis=gui_NameSpace.gui_retr('pivlab_axis');
				delete(findobj(pivlab_axis,'tag', 'extractpoint'));
				delete(findobj(pivlab_axis,'tag', 'extractline'));
				delete(findobj(pivlab_axis,'tag', 'circstring'));
				delete(findobj(pivlab_axis,'Tag', 'extract_poly'))
				delete(findobj(pivlab_axis,'Tag', 'extract_poly_area'))

				xposition = gui_NameSpace.gui_retr('xposition');
				yposition = gui_NameSpace.gui_retr('yposition');
				extract_type = gui_NameSpace.gui_retr('extract_type');
				if ~isempty(xposition) && ~isempty(yposition) && ~isempty(extract_type)
					extract_NameSpace.extract_update_display(extract_type, xposition, yposition)
				end
			end
			plot_NameSpace.plot_manually_discarded_vectors(target_axis,handles, x, y);
		end
		mask_NameSpace.mask_redraw_masks
		if isempty(xzoomlimit)==0
			set(target_axis,'xlim',xzoomlimit)
			set(target_axis,'ylim',yzoomlimit)
		end
		set(target_axis,'YlimMode','manual');set(target_axis,'XlimMode','manual') %in r2014b, vectors are not clipped when set to auto... (?!?)
		drawnow;
	end
end
