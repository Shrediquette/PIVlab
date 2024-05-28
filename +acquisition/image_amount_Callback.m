function image_amount_Callback(~,~,~)
camera_type=gui.gui_retr('camera_type');
if strcmp(camera_type,'pco_panda') || strcmp(camera_type,'chronos') || strcmp(camera_type,'pco_pixelfly')
	%these cameras do not capture into RAM
else
	handles=gui.gui_gethand;
	% assess how many images can be captured to RAM using the image
	% acquisition toolbox (pco doesn't use the toolbox and writes directly
	% to disk
	warning('off','MATLAB:JavaEDTAutoDelegation');
	imaqreset %resetting to get a good estimate of the free RAM

	imageamount=str2double(get(handles.ac_imgamount,'String'));
	ac_ROI_general=gui.gui_retr('ac_ROI_general');
	if isempty(ac_ROI_general)
		max_cam_res=gui.gui_retr('max_cam_res');
		ac_ROI_general=[1 1 max_cam_res(1) max_cam_res(2)];
	end
	value=get(handles.ac_config,'value');
	bitmode=8;
	if value == 6  %basler cameras
		bitmode=8;
	elseif value == 7  %flir cameras
		bitmode=8;
	elseif value == 8  %OPTOcam
		bitmode =gui.gui_retr('OPTOcam_bits');
		if isempty (bitmode)
			bitmode=8;
		end
	elseif value == 9  %OPTRONIS
		bitmode =gui.gui_retr('OPTRONIS_bits');
		if isempty (bitmode)
			bitmode=8;
		end
	end

	max_possible_dbl_images = PIVlab_capture_max_possible_images(ac_ROI_general,[],bitmode);
	if imageamount > max_possible_dbl_images
		if get(handles.ac_pivcapture_save,'Value')==1
			set(handles.ac_imgamount,'BackgroundColor',[1 0.5 0])
			beep
			warning(['RAM most likely not sufficient to capture this amount of double images.' newline 'Please reduce the amount of double images.' newline 'Maximum double images is approx. ' num2str(max_possible_dbl_images)])
		end
	else
		set(handles.ac_imgamount,'BackgroundColor',[1 1 1])
	end
end

