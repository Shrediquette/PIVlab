function setdefaultroi(source,~)
if ~isempty(gui.retr('doing_roi')) && gui.retr('doing_roi')==1
	ac_ROI_general_handle = findobj('tag','new_ROImethod');
	binning=gui.retr('binning');
	max_cam_res =gui.retr('max_cam_res');
	if isempty(binning)
		binning=1;
	end
	selection=1; %automatic centering of ROI
	switch source.Label
		case 'pco.panda 45 Hz'
			des_x=480;
			des_y=340;
		case 'pco.panda 22.5 Hz'
			des_x=720;
			des_y=576;
		case 'pco.panda 15 Hz'
			des_x=1200;
			des_y=896;
		case 'pco.panda 7.5 Hz'
			des_x=2400;
			des_y=1904;
		case 'pco.panda 5 Hz'
			des_x=4000;
			des_y=3000;
		case 'pco.panda 3 Hz'
			des_x=4296;
			des_y=3296;
		case 'pco.panda 1.5 Hz'
			des_x=5120;
			des_y=5120;

		case 'Basler 2048x1088'
			des_x=2048;
			des_y=1088;
		case 'Basler 1280x720'
			des_x=1280;
			des_y=720;
		case 'Basler 1024x1024'
			des_x=1024;
			des_y=1024;
		case 'Basler 640x480'
			des_x=640;
			des_y=480;

		case 'OPTOcam 1936x1216 (8bit: 160 fps, 12bit: 80 fps)'
			des_x=1936;
			des_y=1216;
		case 'OPTOcam 1600x600 (8bit: 320 fps)'
			des_x=1600;
			des_y=600;
		case 'OPTOcam 1600x480 (8bit: 400 fps)'
			des_x=1600;
			des_y=480;

		case 'Cyclone-2-2000-M 1920x1080 (max. 2165 fps)'
			des_x=1920;
			des_y=1080;
		case 'Cyclone-2-2000-M 1792x480 (max. 5000 fps)'
			des_x=1792;
			des_y=480;
		case 'Cyclone-2-2000-M 1024x240 (max. 10000 fps)'
			des_x=1024;
			des_y=240;

		case 'Cyclone-1HS-3500-M 1280x860 (max. 3500 fps)'
			des_x=1280;
			des_y=860;
		case 'Cyclone-1HS-3500-M 1280x320 (max. 9200 fps)'
			des_x=1280;
			des_y=320;
		case 'Cyclone-1HS-3500-M 1280x240 (max. 12200 fps)'
			des_x=1280;
			des_y=240;

		case 'Cyclone-25-150-M 5120x5120 (max. 145 fps)'
			des_x=5120;
			des_y=5120;
		case 'Cyclone-25-150-M 5120x2160 (max. 300 fps)'
			des_x=5120;
			des_y=2160;
		case 'Cyclone-25-150-M 5120x1080 (max. 650 fps)'
			des_x=5120;
			des_y=1080;
		case 'Cyclone-25-150-M 5120x720 (max. 1000 fps)'
			des_x=5120;
			des_y=720;

		case 'Enter ROI'
			prompt = {'x','y','w','h'};
			dlgtitle = 'ROI';
			dims = [1 15];
			current_pos=get(ac_ROI_general_handle,'Position');
			definput = {num2str(current_pos(1)),num2str(current_pos(2)),num2str(current_pos(3)),num2str(current_pos(4))};
			answer = inputdlg(prompt,dlgtitle,dims,definput);
			if ~isempty(answer)
				selection=2; %manual x and y coordinates
				des_x=str2num(answer{3});
				des_y=str2num(answer{4});
				min_x=str2num(answer{1});
				min_y=str2num(answer{2});
				img_size=[des_x des_y];
			else
				des_x=max_cam_res(1);
				des_y=max_cam_res(2);
			end
	end
	if selection==1
		img_size=[des_x/binning des_y/binning]; %must be even, %X Y
		min_x=(max_cam_res(1)/binning-img_size(1))/2+1;
		min_y=(max_cam_res(2)/binning-img_size(2))/2+1;
	end
	set(findobj('tag','new_ROImethod'), 'Position',[min_x,min_y,img_size(1),img_size(2)])
	evt.EventName='ROIMoved';
	evt.CurrentPosition=[min_x,min_y,img_size(1),img_size(2)];
	roi.ROIallevents(ac_ROI_general_handle,evt)
end

