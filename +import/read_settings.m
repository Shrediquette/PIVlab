function read_settings (FileName,PathName)
gui.put('num_handle_calls',0);
handles=gui.gethand;
try
	load(fullfile(PathName,FileName));

	set(handles.clahe_enable,'value',clahe_enable);
	set(handles.clahe_size,'string',clahe_size);
	set(handles.enable_highpass,'value',enable_highpass);
	set(handles.highp_size,'string',highp_size);
	set(handles.wienerwurst,'value',wienerwurst);
	set(handles.wienerwurstsize,'string',wienerwurstsize);
	%set(handles.enable_clip,'value',enable_clip);
	%set(handles.clip_thresh,'string',clip_thresh);
	set(handles.enable_intenscap,'value',enable_intenscap);
	set(handles.intarea,'string',intarea);
	set(handles.step,'string',stepsize);
	set(handles.subpix,'value',subpix);  %popup
	set(handles.stdev_check,'value',stdev_check);
	set(handles.stdev_thresh,'string',stdev_thresh);
	set(handles.loc_median,'value',loc_median);
	set(handles.loc_med_thresh,'string',loc_med_thresh);
	%set(handles.epsilon,'string',epsilon);
	set(handles.interpol_missing,'value',interpol_missing);
	set(handles.vectorscale,'string',vectorscale);
	set(handles.colormap_choice,'value',colormap_choice); %popup
	set(handles.colormap_steps,'value',colormap_steps);
	set(handles.colormap_interpolation,'value',colormap_interpolation);
	set(handles.addfileinfo,'value',addfileinfo);
	set(handles.add_header,'value',add_header);
	set(handles.delimiter,'value',delimiter);%popup
	set(handles.img_not_mask,'value',img_not_mask);
	set(handles.autoscale_vec,'value',autoscale_vec);

	%set(handles.popupmenu16, 'value',imginterpol);
	set(handles.dcc, 'value',dccmark);
	set(handles.fftmulti, 'value',fftmark);
	set(handles.ensemble, 'value',ensemblemark);
	if fftmark==1 || ensemblemark == 1
		set (handles.uipanel42,'visible','on')
	else
		set (handles.uipanel42,'visible','off')
	end
	set(handles.checkbox26, 'value',pass2);
	set(handles.checkbox27, 'value',pass3);
	set(handles.checkbox28, 'value',pass4);
	if pass2 == 1
		set(handles.edit50, 'enable','on')
	else
		set(handles.edit50, 'enable','off')
	end
	if pass3 == 1
		set(handles.edit51, 'enable','on')
	else
		set(handles.edit51, 'enable','off')
	end
	if pass4 == 1
		set(handles.edit52, 'enable','on')
	else
		set(handles.edit52, 'enable','off')
	end

	set(handles.edit50, 'string',pass2val);
	set(handles.edit51, 'string',pass3val);
	set(handles.edit52, 'string',pass4val);
	set(handles.text126, 'string',step2);
	set(handles.text127, 'string',step3);
	set(handles.text128, 'string',step4);
	set(handles.holdstream, 'value',holdstream);
	set(handles.streamlamount, 'string',streamlamount);
	set(handles.streamlcolor, 'value',streamlcolor);
	set(handles.streamlwidth, 'value',streamlcolor);

	set(handles.realdist, 'string',realdist);
	set(handles.time_inp, 'string',time_inp);

	set(handles.nthvect, 'string',nthvect);
	set(handles.validr,'string',validr);
	set(handles.validg,'string',validg);
	set(handles.validb,'string',validb);
	set(handles.validdr,'string',validdr);
	set(handles.validdg,'string',validdg);
	set(handles.validdb,'string',validdb);
	set(handles.interpr,'string',interpr);
	set(handles.interpg,'string',interpg);
	set(handles.interpb,'string',interpb);
	if exist('offset_x_true','var') == 0
		offset_x_true=0;
	end
	if exist('offset_y_true','var') == 0
		offset_y_true=0;
	end

	try
		gui.put('points_offsetx',points_offsetx);
		gui.put('points_offsety',points_offsety);
		gui.put('size_of_the_image',size_of_the_image);
		set(handles.x_axis_direction,'value',x_axis_direction);
		set(handles.y_axis_direction,'value',y_axis_direction);
	catch %ME
		%disp(ME)
	end
	calu=gui.retr('calu');
	calxy=gui.retr('calxy');
	if (calu==1 || calu==-1) && calxy==1
	else
		calibrate.update_green_calibration_box(calxy, calu, offset_x_true, offset_y_true, handles)
	end
	gui.put('offset_x_true',offset_x_true);
	gui.put('offset_y_true',offset_y_true);
	gui.put('calxy',calxy);
	gui.put('calu',calu);
	gui.put('calv',calv);
	if exist('pointscali','var')
		if ~isempty(pointscali)
			gui.put('pointscali',pointscali);
		end
	end
catch
	disp('something went wrong during settings loading')
end
try
	%neu v1.5:
	%set(handles.Repeated_box,'value',Repeated_box);
	set(handles.mask_auto_box,'value',mask_auto_box);
	set(handles.Autolimit,'value',Autolimit);
	set(handles.minintens,'string',minintens);
	set(handles.maxintens,'string',maxintens);
	%neu v2.0
	set(handles.panelslider,'Value',panelwidth);
	gui.put ('panelwidth',panelwidth);
	%neu v2.11
	set(handles.CorrQuality,'Value',CorrQuality_nr);
	%neu v2.37
	set(handles.enhance_images, 'Value',enhance_disp);
	%neu v2.42
	set(handles.interpol_missing2,'value',interpol_missing);
catch
	disp('Old version compatibility-');
end
try
	%neu v2.41
	set(handles.contrast_filter_thresh,'string',contrast_filter_thresh);
	set(handles.bright_filter_thresh,'string',bright_filter_thresh);
	set(handles.do_bright_filter,'Value',do_bright_filter);
	set(handles.do_contrast_filter,'Value',do_contrast_filter);
catch
	disp('img_filter_settings');
end
try
	%neu v2.54
	set(handles.do_corr2_filter,'value',do_corr2_filter);
	set(handles.corr_filter_thresh,'string',corr_filter_thresh);
	set(handles.notch_L_thresh,'String',notch_L_thresh);
	set(handles.notch_H_thresh,'string',notch_H_thresh);
	set(handles.notch_filter,'Value',notch_filter);
catch
	disp('corr filter / notch settings');
end
%neu v2.52
try
	set (handles.repeat_last,'Value',repeat_last);
	set(handles.edit52x,'String',repeat_last_thresh);
	piv.repeat_last_Callback
catch
	disp('repeat_last didnt work')
end
gui.put('expected_image_size',[])
calibrate.pixeldist_changed_Callback()

