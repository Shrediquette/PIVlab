function select_capture_config_Callback (~,~,~)
handles=gui.gethand;
value=get(handles.ac_config,'value');
config_string = handles.ac_config.String(value);

old_setting=gui.retr('old_setting');
gui.put ('old_setting',config_string)

gui.put('do_realtime',0);
set(handles.ac_realtime,'Value',0)
if strcmpi(config_string,'Nd:YAG (SimpleSync) + pco.pixelfly usb') || strcmpi(config_string,'Nd:YAG (SimpleSync) + pco.panda 26 DS')
	set(handles.ac_enable_ext_trigger , 'Visible', 'on')
else
	set(handles.ac_enable_ext_trigger , 'Visible', 'off')
	set(handles.ac_enable_ext_trigger , 'value', 0)
end

if strcmpi(config_string,'Nd:YAG (SimpleSync) + pco.pixelfly usb') || strcmpi(config_string,'PIVlab LD-PS + pco.pixelfly usb') % ILA.piv nano / pco pixelfly with evergreen or LD-PS
	gui.put('camera_type','pco_pixelfly'); % Exposure start -> Q1 delay
	gui.put('f1exp',406); % Exposure start -> Q1 delay
	gui.put('f1exp_cam',400); %exposure time setting first frame
	gui.put('master_freq',15);
	gui.put('binning',1);
	avail_freqs={'5' '3' '1.5' '1'};
	gui.put('max_cam_res',[1392,1040]);
	gui.put('min_allowed_interframe',10);
	gui.put('blind_time',1);
	set(handles.ac_fps,'string',avail_freqs);
	%if get(handles.ac_fps,'value') > numel(avail_freqs)
	if ~strcmpi(config_string,old_setting)
		set(handles.ac_fps,'value',numel(avail_freqs))
	end
	%end
end
if strcmpi(config_string,'Nd:YAG (SimpleSync) + pco.panda 26 DS') || strcmpi(config_string,'PIVlab LD-PS + pco.panda 26 DS')% pco panda with evergreen or LD-PS
	gui.put('camera_type','pco_panda');
	gui.put('f1exp',352) % Exposure start -> Q1 delay
	%disp('testing laserdiode')
	%put('f1exp_cam',300)
	%put('master_freq',3);
	gui.put('f1exp_cam',350); %exposure time setting first frame
	if strcmpi(config_string,'Nd:YAG (SimpleSync) + pco.panda 26 DS') % Nd:YAG laser with panda : limited to 15 Hz
		gui.put('master_freq',15); %master frequency driving the Nd:YAG laser
		avail_freqs={'15' '7.5' '5' '3' '1.5' '1'};
	end
	if strcmpi(config_string,'PIVlab LD-PS + pco.panda 26 DS') %LD-PS laser with panda : limited to 50 Hz
		gui.put('master_freq',45); %was 50, but gives inaccurate capture frequencies at lower numbers.
		avail_freqs={'45' '22.5' '15' '7.5' '5' '3' '1.5' '1'};
	end

	gui.put('max_cam_res',[5120,5120]);
	gui.put('min_allowed_interframe',10);
	gui.put('blind_time',1);
	set(handles.ac_fps,'string',avail_freqs);
	%if get(handles.ac_fps,'value') > numel(avail_freqs)
	if ~strcmpi(config_string,old_setting)
		set(handles.ac_fps,'value',numel(avail_freqs))
	end
	%end
end
if strcmpi(config_string,'PIVlab LD-PS + pco.edge 26 DS CLHS')% pco edge 26ds clhs with LD-PS
	gui.put('camera_type','pco_edge26');
	gui.put('f1exp',352) % Exposure start -> Q1 delay
	gui.put('f1exp_cam',350); %exposure time setting first frame
	gui.put('master_freq',45); %
	%disp('I think these are not used in new synchronizer... Are they?')
	avail_freqs={'750' '300' '180' '100' '70' '25'};
	gui.put('max_cam_res',[5120,5120]);
	gui.put('min_allowed_interframe',5);
	gui.put('blind_time',1);
	set(handles.ac_fps,'string',avail_freqs);
	%if get(handles.ac_fps,'value') > numel(avail_freqs)
	if ~strcmpi(config_string,old_setting)
		set(handles.ac_fps,'value',numel(avail_freqs))
	end
	%end
end
if strcmpi(config_string,'PIVlab LD-PS + Chronos') % chronos LD-PS
	gui.put('camera_type','chronos');
	gui.put('f1exp',352) % Exposure start -> Q1 delay
	%disp('testing laserdiode')
	%put('f1exp_cam',300)
	%put('master_freq',3);
	gui.put('f1exp_cam',350); %exposure time setting first frame
	gui.put('master_freq',15);
	avail_freqs={'850' '600' '500' '400' '300' '200' '150' '100' '70' '50' '25' '10'};
	gui.put('max_cam_res',[1280,1024]);
	gui.put('min_allowed_interframe',20);
	gui.put('blind_time',6);
	set(handles.ac_fps,'string',avail_freqs);
	%if get(handles.ac_fps,'value') > numel(avail_freqs)
	if ~strcmpi(config_string,old_setting)
		set(handles.ac_fps,'value',numel(avail_freqs))
	end
	%end
end
if strcmpi(config_string,'PIVlab LD-PS + Basler acA2000-165um') % basler
	gui.put('camera_type','basler');
	gui.put('f1exp',352) % Exposure start -> Q1 delay
	%disp('testing laserdiode')
	%put('f1exp_cam',300)
	%put('master_freq',3);
	gui.put('f1exp_cam',350); %exposure time setting first frame
	gui.put('master_freq',15);
	avail_freqs={'168' '100' '75' '60' '50' '25' '10'};
	gui.put('max_cam_res',[2048,1088]);
	gui.put('min_allowed_interframe',150);
	gui.put('blind_time',130);
	set(handles.ac_fps,'string',avail_freqs);
	%if get(handles.ac_fps,'value') > numel(avail_freqs)
	if ~strcmpi(config_string,old_setting)
		set(handles.ac_fps,'value',numel(avail_freqs))
	end
	%end
end
if strcmpi(config_string,'PIVlab LD-PS + FLIR FFY-U3-16S2M') % Flir
	gui.put('camera_type','flir');
	gui.put('f1exp',352) % Exposure start -> Q1 delay
	%disp('testing laserdiode')
	%put('f1exp_cam',300)
	%put('master_freq',3);
	gui.put('f1exp_cam',350); %exposure time setting first frame
	gui.put('master_freq',15);
	avail_freqs={'60' '50' '40' '30' '20' '10'};
	gui.put('max_cam_res',[1440,1080]);
	gui.put('min_allowed_interframe',470);
	gui.put('blind_time',425);
	set(handles.ac_fps,'string',avail_freqs);
	%if get(handles.ac_fps,'value') > numel(avail_freqs)
	if ~strcmpi(config_string,old_setting)
		set(handles.ac_fps,'value',numel(avail_freqs))
	end
	%end
end
if strcmpi(config_string,'PIVlab LD-PS + OPTOcam 2/80') % OPTOcam
	gui.put('camera_type','OPTOcam');
	gui.put('f1exp',352) % Exposure start -> Q1 delay
	gui.put('f1exp_cam',350); %exposure time setting first frame
	gui.put('master_freq',15);
	avail_freqs={'400' '320' '160' '100' '80' '60' '50' '25' '5'}; %low fps removed, camera might skip frames.
	gui.put('max_cam_res',[1936,1216]);
	%default min_interframe is for 8 bits.
	OPTOcam_bits =gui.retr('OPTOcam_bits');
	if isempty (OPTOcam_bits)
		OPTOcam_bits=8;
		gui.put('OPTOcam_bits',8); %8bit
	end

	if OPTOcam_bits==8
		gui.put('min_allowed_interframe',62); %8bit
		gui.put('blind_time',44);
	elseif OPTOcam_bits==12
		gui.put('min_allowed_interframe',128); %12bit
		gui.put('blind_time',96);
	end
	set(handles.ac_fps,'string',avail_freqs);
	%if get(handles.ac_fps,'value') > numel(avail_freqs)
	if ~strcmpi(config_string,old_setting)
		set(handles.ac_fps,'value',numel(avail_freqs))
	end
	%end
end
if strcmpi(config_string,'PIVlab LD-PS + OPTRONIS Cyclone') % OPTRONIS
	gui.put('camera_type','OPTRONIS');
	camera_sub_type=gui.retr('camera_sub_type');
	if isempty (camera_sub_type) %this means that hotplugging camera type will not be possible: Camera type will only be detected at first start of PIVlab.
		try
			gui.toolsavailable(0,'Detecting OPTRONIS camera type...')
			[~,camera_sub_type] = PIVlab_capture_OPTRONIS_cam_detect();
			gui.put('camera_sub_type',camera_sub_type);
			postix=get(gca,'XLim');postiy=get(gca,'YLim');text(postix(2)/2,postiy(2)/2,['Detected: ' camera_sub_type],'HorizontalAlignment','center','VerticalAlignment','middle','color','g','fontsize',16, 'BackgroundColor', [0.25 0.25 0.25],'tag','busyhint','margin',10,'Clipping','on');
		catch ME
			gui.toolsavailable(1)
			camera_sub_type=' ';
		end
		gui.toolsavailable(1)
	end
	gui.put('f1exp',352) % Exposure start -> Q1 delay
	gui.put('f1exp_cam',350); %exposure time setting first frame
	gui.put('master_freq',15);

	switch camera_sub_type
		case 'Cyclone-2-2000-M'
			if ~verLessThan('matlab','25')
				avail_freqs={'10000' '5000' '2000' '1750' '1500' '1000' '500' '250' '100' '50'};
			else
				avail_freqs={'2000' '1750' '1500' '1000' '500' '250' '100' '50'};
			end
			gui.put('max_cam_res',[1920,1080]);
			gui.put('min_allowed_interframe',20);
			gui.put('blind_time',3);
		case 'Cyclone-1HS-3500-M'
			if ~verLessThan('matlab','25')
				avail_freqs={'12200' '9200' '3500' '2000' '1750' '1500' '1000' '500' '250' '100' '50'};
			else
				avail_freqs={'3500' '2000' '1750' '1500' '1000' '500' '250' '100' '50'};
			end
			gui.put('max_cam_res',[1280,860]);
			gui.put('min_allowed_interframe',20);
			gui.put('blind_time',3);
		case 'Cyclone-25-150-M'
			if ~verLessThan('matlab','25')
				avail_freqs={'1000' '650' '300' '145' '100' '75' '50' '20'};
			else
				avail_freqs={'145' '100' '75' '50' '20'};
			end
			gui.put('max_cam_res',[5120,5120]);
			gui.put('min_allowed_interframe',40);
			gui.put('blind_time',25);
		otherwise
			gui.custom_msgbox('error',getappdata(0,'hgui'),'No camera found',{'No camera found. Is it connected and powered on?' 'Is the ''Image Acquisition Toolbox Support Package for GenICam Interface'' installed?.'},'modal');
			disp('Camera detection unsuccesful.')
			avail_freqs={'2000' '1750' '1500' '1000' '500' '250' '100' '50'};
			gui.put('max_cam_res',[1920,1080]);
			gui.put('min_allowed_interframe',20);
			gui.put('blind_time',3);
	end
	if str2double(get(handles.ac_expo,'string')) > 49
		set(handles.ac_expo,'string','49'); %at least the cyclone 2-2000-m has a max exposure time of 49.99 ms. So default 50 ms will result in error message.
	end
	set(handles.ac_fps,'string',avail_freqs);
	%if get(handles.ac_fps,'value') > numel(avail_freqs)
	if ~strcmpi(config_string,old_setting)
		set(handles.ac_fps,'value',numel(avail_freqs))
	end
	%end
end
if strcmpi(config_string,'Webcam demo (no synchronizer)')
	webcam_err=0;
	try
		camlist=webcamlist;
        disp(camlist{:})
    catch ME
		webcam_err=1;
        camlist=[];
        disp(ME.message)
        %matlabpath
	end
	if isempty(camlist)
		webcam_err=1;
	end
	if webcam_err~=1
		gui.put('camera_type','webcam');
		gui.put('f1exp',352) %random numbers
		gui.put('f1exp_cam',350); %random numbers
		gui.put('master_freq',15); %random numbers
		avail_freqs={'25'}; %random numbers
		gui.put('max_cam_res',[640,480]); %random numbers
		gui.put('min_allowed_interframe',1000); %random numbers
		gui.put('blind_time',1000); %random numbers
		set(handles.ac_fps,'string',avail_freqs);
		%if get(handles.ac_fps,'value') > numel(avail_freqs)
		if ~strcmpi(config_string,old_setting)
			set(handles.ac_fps,'value',numel(avail_freqs))
        end
    else
        if ~verLessThan('matlab','25')
            message='Tried to access the webcam for demoing PIVlab''s PIV capture features. But the webcam could not be accessed. This function requires the MATLAB Support Package for USB Webcams add-on. It is free and can be downloaded <a href="https://www.mathworks.com/matlabcentral/fileexchange/45182-matlab-support-package-for-usb-webcams">here</a>.';
            uialert(getappdata(0,'hgui'),message,'No webcam','icon','warning','Interpreter','html');
        else
            disp('https://www.mathworks.com/matlabcentral/fileexchange/45182-matlab-support-package-for-usb-webcams')
            gui.custom_msgbox('error',getappdata(0,'hgui'),'No webcam','Could not access webcam. This function requires the free MATLAB Support Package for USB Webcams add-on (the link is now displayed in the command window).','modal');
        end
        set(handles.ac_config,'value',2);
        return
    end
    %disable controls for syncrhonizer
    handles.ac_fps.Enable = 'off';
    handles.ac_interpuls.Enable = 'off';
	handles.ac_power.Enable = 'off';
	handles.ac_enable_straddling_figure.Enable = 'off';
	handles.ac_lasertoggle.Enable = 'off';
	handles.ac_enable_ext_trigger.Enable = 'off';
	handles.ac_calibBinning.Enable = 'off';
	handles.ac_calibROI.Enable = 'off';
	handles.ac_lensctrl.Enable = 'off';
	handles.ac_camera_setup.Enable = 'off';
	handles.ac_expo.Enable = 'off';
	%handles.uipanelac_capture.Enable = 'off';
	handles.ac_connect.Enable = 'off';
	handles.ac_comport.Enable = 'off';

else % not the webcam --> enable all controls
	%disable controls for syncrhonizer
	handles.ac_fps.Enable = 'on';
	handles.ac_interpuls.Enable = 'on';
	handles.ac_power.Enable = 'on';
	handles.ac_enable_straddling_figure.Enable = 'on';
	handles.ac_lasertoggle.Enable = 'on';
	handles.ac_enable_ext_trigger.Enable = 'on';
	handles.ac_calibBinning.Enable = 'on';
	handles.ac_calibROI.Enable = 'on';
	handles.ac_lensctrl.Enable = 'on';
	handles.ac_camera_setup.Enable = 'on';
	handles.ac_expo.Enable = 'on';
	%handles.uipanelac_capture.Enable = 'on';
	handles.ac_connect.Enable = 'on';
	handles.ac_comport.Enable = 'on';
end
acquisition.exposure_Callback
straddling_figure=findobj('tag','straddling_figure');
acquisition.initiate_straddling_graph

