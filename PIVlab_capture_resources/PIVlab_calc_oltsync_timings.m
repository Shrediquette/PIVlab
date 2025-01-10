function [timing_table, pin_string, cam_delay, frame_time] = PIVlab_calc_oltsync_timings(camera_type,camera_sub_type,bitrate,framerate,exposure_time,interframe,laser_energy)

%only relevant for pco:
%exposure_time is also known as f1exp_cam
%f1exp_cam is calculated as      floor(pulse_sep*las_percent/100)+1; %+1 because in the snychronizer, the cam expo is started 1 us before the ld pulse
%it has therefore the length of the laser pulse

if strcmp(camera_type,'pco_pixelfly') || strcmp(camera_type,'pco_panda')
	camera_principle='double_shutter';
else
	camera_principle='normal_shutter';
end

if strcmp(camera_type,'OPTOcam')
	if isempty(bitrate)
		bitrate=8;
	end
	if bitrate == 8
		blind_time=44;
		cam_delay=17;
	else
		blind_time=96;
		cam_delay=32;
	end
end

if strcmp(camera_type,'pco_pixelfly')
	blind_time=2;
	cam_delay=3;
end

if strcmp(camera_type,'pco_panda')
	blind_time=2;
	cam_delay=3;
end

if strcmp(camera_type,'chronos')
	blind_time=8;
	cam_delay=4;
end

if strcmp(camera_type,'basler')
	blind_time=130;
	cam_delay=10;
end

if strcmp(camera_type,'flir')
	blind_time=425;
	cam_delay=50;
end

if strcmp(camera_type,'OPTRONIS')
	switch camera_sub_type
		case 'Cyclone-2-2000-M'
			blind_time=8;
			cam_delay=3;
		case 'Cyclone-1HS-3500-M'
			blind_time=8;
			cam_delay=3;
		case 'Cyclone-25-150-M'
			blind_time=27;
			cam_delay=3;
		otherwise
			msgbox('This camera sub type is not known.')
	end
end

if strcmp(camera_principle,'normal_shutter')
	frame_time = 1/framerate*1000^2 * 2; %the frame_time is twice the camera period, because every 2 frames, the whole cycle repeats itself.
	cam_period=frame_time/2 - blind_time; %maximum exposure of camera;
	laser_period=interframe*laser_energy/100; % laser on time of laser pulse

	laserpulse1_on =  cam_period - interframe/2 - laser_period/2 + blind_time + cam_delay;
	laserpulse1_off = cam_period - interframe/2 + laser_period/2 + cam_delay;
	laserpulse2_on =  cam_period + interframe/2 - laser_period/2 + blind_time + cam_delay;
	laserpulse2_off = cam_period + interframe/2 + laser_period/2 + cam_delay;

	pin1_times=[      0             cam_period         frame_time/2      frame_time/2 + cam_period]; %camera
	pin2_times=[laserpulse1_on    laserpulse1_off    laserpulse2_on           laserpulse2_off     ]; %laser

elseif strcmp(camera_principle,'double_shutter')
	frame_time = 1/framerate*1000^2 ; %the frame_time is the camera period, because every frame, the whole cycle repeats itself.
	cam_period=exposure_time+cam_delay; %exposure of the first frame;
	laser_period=interframe*laser_energy/100; % laser on time of laser pulse

	laserpulse1_on =  cam_delay + blind_time/2; %+(interframe - laser_period)/2;
	laserpulse1_off = cam_delay + laser_period - blind_time/2; %+(interframe - laser_period)/2;
	laserpulse2_on =  cam_delay + interframe + blind_time/2;%+(interframe - laser_period)/2;
	laserpulse2_off = cam_delay + interframe + laser_period - blind_time/2;%+(interframe - laser_period)/2;

	pin1_times=[      0             cam_period                   ]; %double shutter camera: only first frame is triggered, second frame is triggered by the camera automatically
	pin2_times=[laserpulse1_on    laserpulse1_off    laserpulse2_on           laserpulse2_off     ]; %laser
end

%% generate timing table from pulse timings
amount_pins = 2; %currently signals only for pin1_times and pin2_times
longest_pulse_train = max([numel(pin1_times) numel(pin2_times)]);
timing_table=cell(amount_pins,longest_pulse_train);  %rows: pins; cols:timings
for i=1:amount_pins
	for j=1:longest_pulse_train
		element_length=eval(['numel(pin' int2str(i) '_times);']);
		if element_length>=j
			eval(['timing_table{i,j}=pin' int2str(i) '_times(j);']);
		end
	end
end

%% generate string with pin timings from timing_table
pin_string = '';
for i=1:amount_pins
	for j=1:longest_pulse_train
		if ~isempty(timing_table{i,j})
			if j~=1
				pin_string = [pin_string ','];
			end
			pin_string = [pin_string int2str(timing_table{i,j})];
		end
	end
	if i~=amount_pins
		pin_string = [pin_string ':'];
	end
end
%send_string=['sequence:' int2str(frame_time) ':0,0:' pin_string]
