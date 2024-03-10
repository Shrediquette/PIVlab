function import_load_session_Callback(auto_load_session, auto_load_session_filename)
gui_NameSpace.gui_put('num_handle_calls',0);
sessionpath=gui_NameSpace.gui_retr('sessionpath');
if isempty(sessionpath)
	sessionpath=gui_NameSpace.gui_retr('pathname');
end
if auto_load_session ~= 1
	[FileName,PathName, filterindex] = uigetfile({'*.mat','MATLAB Files (*.mat)'; '*.mat','mat'},'Load PIVlab session',fullfile(sessionpath, 'PIVlab_session.mat'));
	gui_NameSpace.gui_toolsavailable(0,'Busy, loading session...');drawnow
else
	[PathName,FileName,ext] = fileparts(auto_load_session_filename);
	FileName = [FileName ext];
end

if isequal(FileName,0) | isequal(PathName,0)
else
	gui_NameSpace.gui_put('expected_image_size',[])
	clear iptPointerManager
	gui_NameSpace.gui_put('sessionpath',PathName );
	gui_NameSpace.gui_put('derived',[]);
	gui_NameSpace.gui_put('resultslist',[]);
	gui_NameSpace.gui_put('masks_in_frame',[]);
	gui_NameSpace.gui_put('roirect',[]);
	gui_NameSpace.gui_put('velrect',[]);
	gui_NameSpace.gui_put('filename',[]);
	gui_NameSpace.gui_put('filepath',[]);
	hgui=getappdata(0,'hgui');
	warning off all
	try
		%even if a variable doesn't exist, this doesn't throw an error...
		vars=load(fullfile(PathName,FileName),'yposition', 'FileName', 'PathName', 'add_header', 'addfileinfo', 'autoscale_vec', 'caliimg', 'calu', 'calv','calxy', 'cancel', 'clahe_enable', 'clahe_size', 'colormap_choice', 'colormap_steps', 'colormap_interpolation', 'delimiter', 'derived', 'displaywhat', 'distance', 'enable_highpass', 'enable_intenscap', 'epsilon', 'filename', 'filepath', 'highp_size', 'homedir', 'img_not_mask', 'intarea', 'interpol_missing', 'loc_med_thresh', 'loc_median', 'manualdeletion', 'pathname', 'pointscali', 'resultslist', 'roirect', 'sequencer', 'sessionpath', 'stdev_check', 'stdev_thresh', 'stepsize', 'subpix', 'subtr_u', 'subtr_v', 'toggler', 'vectorscale', 'velrect', 'wasdisabled', 'xposition','realdist_string','time_inp_string','streamlinesX','streamlinesY','manmarkersX','manmarkersY','dccmark','fftmark','pass2','pass3','pass4','pass2val','pass3val','pass4val','step2','step3','step4','holdstream','streamlamount','streamlcolor','ismean','wienerwurst','wienerwurstsize','mask_auto_box','Autolimit','minintens','maxintens','CorrQuality_nr','ensemblemark','enhance_disp','video_selection_done','video_frame_selection','video_reader_object','bg_img_A','bg_img_B','x_axis_direction','y_axis_direction','size_of_the_image','points_offsetx','points_offsety','offset_x_true','offset_y_true','bright_filter_thresh','contrast_filter_thresh','do_bright_filter','do_contrast_filter','repeat_last','repeat_last_thresh','do_corr2_filter','corr_filter_thresh','notch_L_thresh','notch_H_thresh','notch_filter','masks_in_frame');
	catch
		disp('Old version compatibility.')
		vars=load(fullfile(PathName,FileName),'yposition', 'FileName', 'PathName', 'add_header', 'addfileinfo', 'autoscale_vec', 'caliimg', 'calu','calv', 'calxy', 'cancel', 'clahe_enable', 'clahe_size', 'colormap_steps','colormap_choice', 'colormap_interpolation', 'delimiter', 'derived', 'displaywhat', 'distance', 'enable_highpass', 'enable_intenscap', 'epsilon', 'filename', 'filepath', 'highp_size', 'homedir', 'img_not_mask', 'intarea', 'interpol_missing', 'loc_med_thresh', 'loc_median', 'manualdeletion', 'pathname', 'pointscali', 'resultslist', 'roirect', 'sequencer', 'sessionpath', 'stdev_check', 'stdev_thresh', 'stepsize', 'subpix', 'subtr_u', 'subtr_v', 'toggler', 'vectorscale', 'velrect', 'wasdisabled', 'xposition','realdist_string','time_inp_string','streamlinesX','streamlinesY','manmarkersX','manmarkersY','imginterpol','dccmark','fftmark','pass2','pass3','pass4','pass2val','pass3val','pass4val','step2','step3','step4','holdstream','streamlamount','streamlcolor','ismean','wienerwurst','wienerwurstsize');
	end
	names=fieldnames(vars);
	for i=1:size(names,1)
		setappdata(hgui,names{i},vars.(names{i}))
	end
	gui_NameSpace.gui_put('existing_handles',[]);
	gui_NameSpace.gui_sliderrange(1)
	handles=gui_NameSpace.gui_gethand;

	set(handles.clahe_enable,'value',gui_NameSpace.gui_retr('clahe_enable'));
	set(handles.clahe_size,'string',gui_NameSpace.gui_retr('clahe_size'));
	set(handles.enable_highpass,'value',gui_NameSpace.gui_retr('enable_highpass'));
	set(handles.highp_size,'string',gui_NameSpace.gui_retr('highp_size'));

	set(handles.wienerwurst,'value',gui_NameSpace.gui_retr('wienerwurst'));
	set(handles.wienerwurstsize,'string',gui_NameSpace.gui_retr('wienerwurstsize'));

	%set(handles.enable_clip,'value',retr('enable_clip'));
	%set(handles.clip_thresh,'string',retr('clip_thresh'));
	set(handles.enable_intenscap,'value',gui_NameSpace.gui_retr('enable_intenscap'));
	set(handles.intarea,'string',gui_NameSpace.gui_retr('intarea'));
	set(handles.step,'string',gui_NameSpace.gui_retr('stepsize'));
	set(handles.subpix,'value',gui_NameSpace.gui_retr('subpix'));  %popup
	set(handles.stdev_check,'value',gui_NameSpace.gui_retr('stdev_check'));
	set(handles.stdev_thresh,'string',gui_NameSpace.gui_retr('stdev_thresh'));
	set(handles.loc_median,'value',gui_NameSpace.gui_retr('loc_median'));
	set(handles.loc_med_thresh,'string',gui_NameSpace.gui_retr('loc_med_thresh'));
	set(handles.interpol_missing,'value',gui_NameSpace.gui_retr('interpol_missing'));

	set(handles.vectorscale,'string',gui_NameSpace.gui_retr('vectorscale'));
	set(handles.colormap_choice,'value',gui_NameSpace.gui_retr('colormap_choice')); %popup
	set(handles.colormap_steps,'value',gui_NameSpace.gui_retr('colormap_steps'));
	set(handles.colormap_interpolation,'value',gui_NameSpace.gui_retr('colormap_interpolation'));
	set(handles.addfileinfo,'value',gui_NameSpace.gui_retr('addfileinfo'));
	set(handles.add_header,'value',gui_NameSpace.gui_retr('add_header'));
	set(handles.delimiter,'value',gui_NameSpace.gui_retr('delimiter'));%popup
	set(handles.img_not_mask,'value',gui_NameSpace.gui_retr('img_not_mask'));
	set(handles.autoscale_vec,'value',gui_NameSpace.gui_retr('autoscale_vec'));

	set(handles.dcc, 'value',vars.dccmark);
	set(handles.fftmulti, 'value',vars.fftmark);


	try
		set(handles.ensemble, 'value',vars.ensemblemark);
	catch
		vars.ensemblemark=0;
	end


	if vars.fftmark==1 || vars.ensemblemark ==1
		set (handles.uipanel42,'visible','on')
	else
		set (handles.uipanel42,'visible','off')
	end
	set(handles.checkbox26, 'value',vars.pass2);
	set(handles.checkbox27, 'value',vars.pass3);
	set(handles.checkbox28, 'value',vars.pass4);

	if vars.pass2 == 1
		set(handles.edit50, 'enable','on')
	else
		set(handles.edit50, 'enable','off')
	end
	if vars.pass3 == 1
		set(handles.edit51, 'enable','on')
	else
		set(handles.edit51, 'enable','off')
	end
	if vars.pass4 == 1
		set(handles.edit52, 'enable','on')
	else
		set(handles.edit52, 'enable','off')
	end
	set(handles.edit50, 'string',vars.pass2val);
	set(handles.edit51, 'string',vars.pass3val);
	set(handles.edit52, 'string',vars.pass4val);
	set(handles.text126, 'string',vars.step2);
	set(handles.text127, 'string',vars.step3);
	set(handles.text128, 'string',vars.step4);
	set(handles.holdstream, 'value',vars.holdstream);
	set(handles.streamlamount, 'string',vars.streamlamount);
	set(handles.streamlcolor, 'value',vars.streamlcolor);
	set(handles.streamlwidth, 'value',vars.streamlcolor);

	try
		%neu v1.5:
		set(handles.mask_auto_box,'value',vars.mask_auto_box);
		set(handles.Autolimit,'value',vars.Autolimit);
		set(handles.minintens,'string',vars.minintens);
		set(handles.maxintens,'string',vars.maxintens);
		set(handles.CorrQuality,'Value',vars.CorrQuality_nr);
		%neu v2.37
		set(handles.enhance_images, 'Value',vars.enhance_disp);
	catch
		disp('Old version compatibility,')
	end
	try %neu v2.42
		set(handles.interpol_missing2,'value',gui_NameSpace.gui_retr('interpol_missing'));
	catch
	end

	try %neu 2.42
		set (handles.x_axis_direction,'value',vars.x_axis_direction);
		set (handles.y_axis_direction,'value',vars.y_axis_direction);

		set(handles.contrast_filter_thresh,'string',vars.contrast_filter_thresh);
		set(handles.bright_filter_thresh,'string',vars.bright_filter_thresh);
		set(handles.do_bright_filter,'Value',vars.do_bright_filter);
		set(handles.do_contrast_filter,'Value',vars.do_contrast_filter);
	catch
	end

	try
		%neu v2.54
		set(handles.do_corr2_filter,'value',vars.do_corr2_filter);
		set(handles.corr_filter_thresh,'string',vars.corr_filter_thresh);
		set(handles.notch_L_thresh,'string',vars.notch_L_thresh);
		set(handles.notch_H_thresh,'string',vars.notch_H_thresh);
		set(handles.notch_filter,'Value',vars.notch_filter);
	catch
		disp('corr filter / notch settings');
	end

	try
		if vars.velrect(1,3)~=0 && vars.velrect(1,4)~=0
			gui_NameSpace.gui_put('velrect', vars.velrect);
			validate_NameSpace.validate_update_velocity_limits_information
		end
	catch
	end

	try
		set(handles.realdist, 'String',vars.realdist_string);
		set(handles.time_inp, 'String',vars.time_inp_string);

		if isempty(vars.pointscali)==0
			handles=gui_NameSpace.gui_gethand;
			calu=gui_NameSpace.gui_retr('calu');calv=gui_NameSpace.gui_retr('calv');
			calxy=gui_NameSpace.gui_retr('calxy');
			if isfield(vars,'offset_x_true') == 1
				offset_x_true = gui_NameSpace.gui_retr('offset_x_true');
			else
				offset_x_true=0;
			end
			if isfield(vars,'offset_y_true') == 1
				offset_y_true = gui_NameSpace.gui_retr('offset_y_true');
			else
				offset_y_true=0;
			end
			calibrate_NameSpace.calibrate_update_green_calibration_box(calxy, calu, offset_x_true, offset_y_true, handles)
			calibrate_NameSpace.calibrate_pixeldist_changed_Callback()
		end
	catch
		disp('...')
	end

	try
		if ~isempty(vars.bg_img_A)
			set(handles.bg_subtract,'Value',1);
		else
			set(handles.bg_subtract,'Value',0);
		end
	catch
		disp('Could not set bg checkbox')
	end

	%neu v2.52
	try
		set (handles.repeat_last,'Value',vars.repeat_last);
		set(handles.edit52x,'String',vars.repeat_last_thresh);
		piv_NameSpace.piv_repeat_last_Callback
	catch
		disp('repeat_last didnt work4')
	end

	%reset zoom
	set(handles.panon,'Value',0);
	set(handles.zoomon,'Value',0);
	gui_NameSpace.gui_put('xzoomlimit', []);
	gui_NameSpace.gui_put('yzoomlimit', []);
	gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
	try
		if gui_NameSpace.gui_retr('parallel')==1
			modestr=' (parallel)';
		else
			modestr=' (serial)';
		end
		set(getappdata(0,'hgui'), 'Name',['PIVlab ' gui_NameSpace.gui_retr('PIVver')  modestr '   [Path: ' vars.pathname ']']) %for people like me that always forget what dataset they are currently working on...
	catch
	end
	zoom reset
	try
		set (handles.filenamebox, 'string', vars.filename);
	catch
	end
end
gui_NameSpace.gui_toolsavailable(1)
