function load_session_Callback(auto_load_session, auto_load_session_filename)
valid_session_file=1;
gui.put('num_handle_calls',0);
sessionpath=gui.retr('sessionpath');
if isempty(sessionpath)
	sessionpath=gui.retr('pathname');
end
if auto_load_session ~= 1
	[FileName,PathName, filterindex] = uigetfile({'*.mat','MATLAB Files (*.mat)'; '*.mat','mat'},'Load PIVlab session',fullfile(sessionpath, 'PIVlab_session.mat'));
	gui.toolsavailable(0,'Busy, loading session...');drawnow
	if ~isequal(FileName,0) & ~isequal(PathName,0)
		load(fullfile(PathName,FileName),'resultslist','wasdisabled','video_selection_done')
		if exist('resultslist','var') && exist('wasdisabled','var') && exist('video_selection_done','var')
			valid_session_file=1;
		else
			valid_session_file=0;
		end
	end
else
	[PathName,FileName,ext] = fileparts(auto_load_session_filename);
	FileName = [FileName ext];
end

if isequal(FileName,0) | isequal(PathName,0)
elseif valid_session_file == 1
	gui.put('expected_image_size',[])
	clear iptPointerManager
	gui.put('sessionpath',PathName );
	gui.put('derived',[]);
	gui.put('resultslist',[]);
	gui.put('masks_in_frame',[]);
	gui.put('roirect',[]);
	gui.put('velrect',[]);
	gui.put('filename',[]);
	gui.put('filepath',[]);
	hgui=getappdata(0,'hgui');
	warning off all


	try
		%even if a variable doesn't exist, this doesn't throw an error...
		vars=load(fullfile(PathName,FileName),'yposition', 'FileName', 'PathName', 'add_header', 'addfileinfo', 'autoscale_vec', 'caliimg', 'calu', 'calv','calxy', 'cancel', 'clahe_enable', 'clahe_size', 'colormap_choice', 'colormap_steps', 'colormap_interpolation', 'delimiter', 'derived', 'displaywhat', 'distance', 'enable_highpass', 'enable_intenscap', 'epsilon', 'filename', 'filepath', 'framenum','framepart', 'highp_size', 'homedir', 'img_not_mask', 'intarea', 'interpol_missing', 'loc_med_thresh', 'loc_median', 'manualdeletion', 'pathname', 'pointscali', 'resultslist', 'roirect', 'sequencer', 'sessionpath', 'stdev_check', 'stdev_thresh', 'stepsize', 'subpix', 'subtr_u', 'subtr_v', 'toggler', 'vectorscale', 'velrect', 'wasdisabled', 'xposition','realdist_string','time_inp_string','streamlinesX','streamlinesY','manmarkersX','manmarkersY','algorithm_selection','pass2','pass3','pass4','pass2val','pass3val','pass4val','step2','step3','step4','holdstream','streamlamount','streamlcolor','ismean','wienerwurst','wienerwurstsize','mask_auto_box','Autolimit','minintens','maxintens','CorrQuality_nr','enhance_disp','video_selection_done','video_frame_selection','video_reader_object','bg_img_A','bg_img_B','x_axis_direction','y_axis_direction','size_of_the_image','points_offsetx','points_offsety','offset_x_true','offset_y_true','bright_filter_thresh','contrast_filter_thresh','do_bright_filter','do_contrast_filter','repeat_last','repeat_last_thresh','do_corr2_filter','corr_filter_thresh','notch_L_thresh','notch_H_thresh','notch_filter','masks_in_frame','pcopanda_dbl_image');
	catch
		disp('Old version compatibility.')
		vars=load(fullfile(PathName,FileName),'yposition', 'FileName', 'PathName', 'add_header', 'addfileinfo', 'autoscale_vec', 'caliimg', 'calu','calv', 'calxy', 'cancel', 'clahe_enable', 'clahe_size', 'colormap_steps','colormap_choice', 'colormap_interpolation', 'delimiter', 'derived', 'displaywhat', 'distance', 'enable_highpass', 'enable_intenscap', 'epsilon', 'filename', 'filepath', 'highp_size', 'homedir', 'img_not_mask', 'intarea', 'interpol_missing', 'loc_med_thresh', 'loc_median', 'manualdeletion', 'pathname', 'pointscali', 'resultslist', 'roirect', 'sequencer', 'sessionpath', 'stdev_check', 'stdev_thresh', 'stepsize', 'subpix', 'subtr_u', 'subtr_v', 'toggler', 'vectorscale', 'velrect', 'wasdisabled', 'xposition','realdist_string','time_inp_string','streamlinesX','streamlinesY','manmarkersX','manmarkersY','imginterpol','algorithm_selection','pass2','pass3','pass4','pass2val','pass3val','pass4val','step2','step3','step4','holdstream','streamlamount','streamlcolor','ismean','wienerwurst','wienerwurstsize');
	end

	if isfield(vars,'wasdisabled')
		Amount_of_existing_ui_elements=numel(findobj(hgui, 'type', 'uicontrol'));
		Amount_of_loaded_ui_elements=numel(vars.wasdisabled);
		display_hint=0;
		if Amount_of_existing_ui_elements ~= Amount_of_loaded_ui_elements
			vars=rmfield(vars,'wasdisabled'); %results in conflict if new ui elements were added in new release.
			display_hint=1;
		end
	else
		display_hint=0;
	end
	names=fieldnames(vars);
	for i=1:size(names,1)
		setappdata(hgui,names{i},vars.(names{i}))
	end
	gui.put('existing_handles',[]);
	gui.sliderrange(1)
	handles=gui.gethand;

	set(handles.clahe_enable,'value',gui.retr('clahe_enable'));
	set(handles.clahe_size,'string',gui.retr('clahe_size'));
	set(handles.enable_highpass,'value',gui.retr('enable_highpass'));
	set(handles.highp_size,'string',gui.retr('highp_size'));

	set(handles.wienerwurst,'value',gui.retr('wienerwurst'));
	set(handles.wienerwurstsize,'string',gui.retr('wienerwurstsize'));

	%set(handles.enable_clip,'value',retr('enable_clip'));
	%set(handles.clip_thresh,'string',retr('clip_thresh'));
	set(handles.enable_intenscap,'value',gui.retr('enable_intenscap'));
	set(handles.intarea,'string',gui.retr('intarea'));
	set(handles.step,'string',gui.retr('stepsize'));
	set(handles.subpix,'value',gui.retr('subpix'));  %popup
	set(handles.stdev_check,'value',gui.retr('stdev_check'));
	set(handles.stdev_thresh,'string',gui.retr('stdev_thresh'));
	set(handles.loc_median,'value',gui.retr('loc_median'));
	set(handles.loc_med_thresh,'string',gui.retr('loc_med_thresh'));
	set(handles.interpol_missing,'value',gui.retr('interpol_missing'));

	set(handles.vectorscale,'string',gui.retr('vectorscale'));
	set(handles.colormap_choice,'value',gui.retr('colormap_choice')); %popup
	set(handles.colormap_steps,'value',gui.retr('colormap_steps'));
	set(handles.colormap_interpolation,'value',gui.retr('colormap_interpolation'));
	set(handles.addfileinfo,'value',gui.retr('addfileinfo'));
	set(handles.add_header,'value',gui.retr('add_header'));
	set(handles.delimiter,'value',gui.retr('delimiter'));%popup
	set(handles.img_not_mask,'value',gui.retr('img_not_mask'));
	set(handles.autoscale_vec,'value',gui.retr('autoscale_vec'));

	try
		set(handles.algorithm_selection, 'value',vars.algorithm_selection);
		piv.algorithm_selection_Callback(handles.algorithm_selection)
	catch
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
		set(handles.interpol_missing2,'value',gui.retr('interpol_missing'));
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
			gui.put('velrect', vars.velrect);
			validate.update_velocity_limits_information
		end
	catch
	end

	try
		set(handles.realdist, 'String',vars.realdist_string);
		set(handles.time_inp, 'String',vars.time_inp_string);
		if str2double(vars.time_inp_string) == 0 %user entered zero as time step --> PIVlab will measure displacements instead of velocities
			gui.put('displacement_only',1)
		else
			gui.put('displacement_only',0)
		end

		if isempty(vars.pointscali)==0
			handles=gui.gethand;
			calu=gui.retr('calu');calv=gui.retr('calv');
			calxy=gui.retr('calxy');
			if isfield(vars,'offset_x_true') == 1
				offset_x_true = gui.retr('offset_x_true');
			else
				offset_x_true=0;
			end
			if isfield(vars,'offset_y_true') == 1
				offset_y_true = gui.retr('offset_y_true');
			else
				offset_y_true=0;
			end
			calibrate.update_green_calibration_box(calxy, calu, offset_x_true, offset_y_true, handles)
			calibrate.pixeldist_changed_Callback()
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
		piv.repeat_last_Callback
	catch
		disp('repeat_last didnt work4')
	end

	% new for multitiff
	if isfield(vars,'video_selection_done') && vars.video_selection_done == 1
		%session was saved with video file selection, dont generate framenum and framepart
	else
		if ~isfield(vars,'framenum') || ~isfield(vars,'framepart') %% old sessions do not have these vars yet
			display_hint=1;
			framenum=[];
			framepart=[];
			cntr=1;
			vars.filepath=import.Check_if_image_files_exist(vars.filepath,1);
			img_height=size(imread(vars.filepath{1}),1); %read one file to detect image height to devide it by two later.
			for i=1:size(vars.filepath,1)
				framenum(i,1)=1;
				framepart(i,1)=1;
				framepart(i,2)=img_height;
			end
			gui.put ('framenum',framenum);
			gui.put ('framepart',framepart);
		end
	end
	%reset zoom
	set(handles.panon,'Value',0);
	set(handles.zoomon,'Value',0);
	gui.put('xzoomlimit', []);
	gui.put('yzoomlimit', []);
	gui.sliderdisp(gui.retr('pivlab_axis'))
	try
		if gui.retr('parallel')==1
			modestr=' (parallel)';
		else
			modestr=' (serial)';
		end

		if ~isdeployed
			appname='PIVlab';
		else
			appname='PIVlab standalone';
		end
		set(getappdata(0,'hgui'), 'Name',[appname ' ' gui.retr('PIVver')  modestr '   [Path: ' vars.pathname ']']) %for people like me that always forget what dataset they are currently working on...
	catch
	end
	zoom reset
	try
		set (handles.filenamebox, 'string', vars.filename);
	catch
	end
end
if valid_session_file==0
	uiwait(msgbox('This is not a valid PIVlab session file.','modal'))
	display_hint=0;
end
gui.toolsavailable(1)
if display_hint==1
	uiwait(msgbox('You loaded a session from an older PIVlab release. This is not recommended and may lead to display problems in the GUI.','modal'))
end

