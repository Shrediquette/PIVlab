function acquisition_calibROI_Callback (~,~,~)
handles=gui.gui_gethand;
gui.gui_put('capturing',0);
gui.gui_put('hist_enabled',0);
camera_type=gui.gui_retr('camera_type');
binning=gui.gui_retr('binning');
if isempty(binning)
	binning=1;
end
if strcmp(camera_type,'pco_pixelfly') || strcmp(camera_type,'chronos')  %ROI selection not yet available for pixelfly and chronos
	uiwait(msgbox('ROI selection is not (yet) available for the selected camera type.'))
end

if strcmp(camera_type,'flir')
	uiwait(msgbox('ROI selection for the FLIR camera series will be implemented soon!','modal'))
end

if strcmp(camera_type,'OPTRONIS')
	uiwait(msgbox(['ROI selection for the OPTRONIS camera series will be implemented soon!' newline 'Currently waiting for bug fixes from Mathworks.'],'modal'))
end
if strcmp(camera_type,'pco_panda') || strcmp(camera_type,'basler') || strcmp(camera_type,'OPTOcam') %|| strcmp(camera_type,'OPTRONIS')
	try
		expos=round(str2num(get(handles.ac_expo,'String'))*1000);
	catch
		set(handles.ac_expo,'String','100');
		expos=100000;
	end
	projectpath=get(handles.ac_project,'String');
	capture_ok=acquisition.acquisition_check_project_path(projectpath,'calibration');
	if capture_ok==1
		gui.gui_put('cancel_capture',0);
		gui.gui_put('capturing',1);
		max_cam_res=gui.gui_retr('max_cam_res');
		if strcmp(camera_type,'pco_panda')
			try
				[errorcode, caliimg,~]=PIVlab_capture_pco(1,expos,'Calibration',projectpath,[],0,[],binning,[1,1, max_cam_res(1)/binning,max_cam_res(2)/binning],camera_type,0);
			catch ME
				disp(ME)
				uiwait(msgbox('Camera not connected'))
				gui.gui_displogo
				capture_ok=0;
			end
		elseif strcmp(camera_type,'basler')
			[errorcode, caliimg]=PIVlab_capture_basler_calibration_image(1,expos,[1,1,max_cam_res]);

		elseif strcmp(camera_type,'OPTOcam')
			[errorcode, caliimg]=PIVlab_capture_OPTOcam_calibration_image(1,expos,[1,1,max_cam_res]);
		elseif strcmp(camera_type,'OPTRONIS')
			acquisition.acquisition_control_simple_sync_serial(0,1); %OPTRONIS requires synchronizer signal because free run mode cannot be set from matlab.
			[errorcode, caliimg]=PIVlab_capture_OPTRONIS_calibration_image(1,expos,[1,1,max_cam_res]);
			acquisition.acquisition_control_simple_sync_serial(0,2);
		end
		gui.gui_put('capturing',0);

		if capture_ok==1
			displaysize_x=floor(get(gca,'XLim'));
			displaysize_y=floor(get(gca,'YLim'));
			ac_ROI_general=[];
			warning off
			load('PIVlab_settings_default.mat','ac_ROI_general');
			warning on

			bla=findobj(gca,'type','image');
			current_image_size=size(bla.CData);

			if isempty(ac_ROI_general)
				ac_ROI_general=[0.5,0.5,current_image_size(2)/binning,current_image_size(1)/binning]; %1 Hz default ROI
			end
			gui.gui_put('doing_roi',1)
			stretched_image=adapthisteq(bla.CData);
			bla.CData=stretched_image;
			ac_ROI_general_handle = drawrectangle(gca,'Position',ac_ROI_general,'LabelVisible','hover','Deletable',0,'DrawingArea',[1 1 current_image_size(2) current_image_size(1)],'tag','new_ROImethod','StripeColor','y');
			addlistener(ac_ROI_general_handle,'MovingROI',@roi_1.roi_ROIallevents);
			addlistener(ac_ROI_general_handle,'ROIMoved',@roi_1.roi_ROIallevents);
			evt.EventName='ROIMoved';
			evt.CurrentPosition=ac_ROI_general;
			roi_1.roi_ROIallevents(ac_ROI_general_handle,evt)

			c_menu = uicontextmenu;
			ac_ROI_general_handle.UIContextMenu = c_menu;

			if strcmp(camera_type,'pco_panda')
				m0 = uimenu(c_menu,'Label','pco.panda 45 Hz','Callback',@roi_1.roi_setdefaultroi);
				m1 = uimenu(c_menu,'Label','pco.panda 22.5 Hz','Callback',@roi_1.roi_setdefaultroi);
				m2 = uimenu(c_menu,'Label','pco.panda 15 Hz','Callback',@roi_1.roi_setdefaultroi);
				m3 = uimenu(c_menu,'Label','pco.panda 7.5 Hz','Callback',@roi_1.roi_setdefaultroi);
				m4 = uimenu(c_menu,'Label','pco.panda 5 Hz','Callback',@roi_1.roi_setdefaultroi);
				m5 = uimenu(c_menu,'Label','pco.panda 3 Hz','Callback',@roi_1.roi_setdefaultroi);
				m6 = uimenu(c_menu,'Label','pco.panda 1 Hz','Callback',@roi_1.roi_setdefaultroi);
				m7 = uimenu(c_menu,'Label','Enter ROI','Callback',@roi_1.roi_setdefaultroi);
			end
			if strcmp(camera_type,'basler')
				m0 = uimenu(c_menu,'Label','Basler 2048x1088','Callback',@roi_1.roi_setdefaultroi);
				m1 = uimenu(c_menu,'Label','Basler 1280x720','Callback',@roi_1.roi_setdefaultroi);
				m2 = uimenu(c_menu,'Label','Basler 1024x1024','Callback',@roi_1.roi_setdefaultroi);
				m3 = uimenu(c_menu,'Label','Basler 640x480','Callback',@roi_1.roi_setdefaultroi);
				m4 = uimenu(c_menu,'Label','Enter ROI','Callback',@roi_1.roi_setdefaultroi);
			end
			if strcmp(camera_type,'OPTOcam')
				m0 = uimenu(c_menu,'Label','OPTOcam 1936x1216 (8bit: 160 fps, 12bit: 80 fps)','Callback',@roi_1.roi_setdefaultroi);
				m1 = uimenu(c_menu,'Label','OPTOcam 1600x600 (8bit: 320 fps)','Callback',@roi_1.roi_setdefaultroi);
				m2 = uimenu(c_menu,'Label','OPTOcam 1600x480 (8bit: 400 fps)','Callback',@roi_1.roi_setdefaultroi);
				m3 = uimenu(c_menu,'Label','Enter ROI','Callback',@roi_1.roi_setdefaultroi);
			end

			if strcmp(camera_type,'OPTRONIS')
				%die ganzen ROIs bringen noch keine fps Erhöhung, muss erst
				%im dropdown eine Option hinzugefügt werden...
				camera_sub_type=gui.gui_retr('camera_sub_type');
				switch camera_sub_type
					case 'Cyclone-2-2000-M'
						m0 = uimenu(c_menu,'Label','Cyclone-2-2000-M 1920x1080 (max. 2165 fps)','Callback',@roi_1.roi_setdefaultroi);
						m1 = uimenu(c_menu,'Label','Cyclone-2-2000-M 1792x800 (max. 3100 fps)','Callback',@roi_1.roi_setdefaultroi);
						m2 = uimenu(c_menu,'Label','Cyclone-2-2000-M 1792x480 (max. 5142 fps)','Callback',@roi_1.roi_setdefaultroi);
						m3 = uimenu(c_menu,'Label','Cyclone-2-2000-M 1024x240 (max. 10150 fps)','Callback',@roi_1.roi_setdefaultroi);
						m4 = uimenu(c_menu,'Label','Enter ROI','Callback',@roi_1.roi_setdefaultroi);
					case 'Cyclone-1HS-3500-M'
						m0 = uimenu(c_menu,'Label','Cyclone-1HS-3500-M 1280x860 (max. 3500 fps)','Callback',@roi_1.roi_setdefaultroi);
						m1 = uimenu(c_menu,'Label','Cyclone-1HS-3500-M 1280x640 (max. 4700 fps)','Callback',@roi_1.roi_setdefaultroi);
						m2 = uimenu(c_menu,'Label','Cyclone-1HS-3500-M 1280x320 (max. 9340 fps)','Callback',@roi_1.roi_setdefaultroi);
						m3 = uimenu(c_menu,'Label','Cyclone-1HS-3500-M 1280x240 (max. 12350 fps)','Callback',@roi_1.roi_setdefaultroi);
						m4 = uimenu(c_menu,'Label','Enter ROI','Callback',@roi_1.roi_setdefaultroi);
					case 'Cyclone-25-150-M'
						m0 = uimenu(c_menu,'Label','Cyclone-25-150-M 5120x5120 (max. 150 fps)','Callback',@roi_1.roi_setdefaultroi);
						m1 = uimenu(c_menu,'Label','Cyclone-25-150-M 5120x2160 (max. 350 fps)','Callback',@roi_1.roi_setdefaultroi);
						m2 = uimenu(c_menu,'Label','Cyclone-25-150-M 5120x1080 (max. 695 fps)','Callback',@roi_1.roi_setdefaultroi);
						m3 = uimenu(c_menu,'Label','Cyclone-25-150-M 5120x720 (max. 1025 fps)','Callback',@roi_1.roi_setdefaultroi);
						m4 = uimenu(c_menu,'Label','Enter ROI','Callback',@roi_1.roi_setdefaultroi);
					otherwise

				end
			end

			position = acquisition.acquisition_customWait(ac_ROI_general_handle);

			gui.gui_put('ac_ROI_general_handle',ac_ROI_general_handle);
			gui.gui_put('doing_roi',0)
			position=round(position);

			xmin=position(1);
			ymin=position(2);
			xmax=position(1)+position(3)-1;
			ymax=position(2)+position(4)-1;

			% Round so it fits the requirements of the camera ROI
			xmin=floor(xmin/8)*8+1;
			ymin=floor(ymin/2)*2+1;
			xmax=floor(xmax/8)*8;
			ymax=floor(ymax/2)*2;

			if xmin<1
				xmin=1;
			end
			if ymin<1
				ymin=1;
			end
			if xmax>max_cam_res(1)
				xmax=max_cam_res(1);
			end
			if ymax>max_cam_res(2)
				ymax=max_cam_res(2);
			end
			position(1)=xmin;
			position(2)=ymin;
			position(3)=xmax-xmin+1;
			position(4)=ymax-ymin+1;
			ac_ROI_general=position;
			gui.gui_put('ac_ROI_general',ac_ROI_general);
			save('PIVlab_settings_default.mat','ac_ROI_general','-append');
			delete(ac_ROI_general_handle)
			rectangle('Position',position,'EdgeColor','y','linewidth',2)
			if strcmp(camera_type,'pco_panda')
				%% jetzt nochmal mit finalen einstellungen bild capturen zum messen der framerate...
				%Camera fps
				ac_fps_value=get(handles.ac_fps,'Value');
				ac_fps_str=get(handles.ac_fps,'String');
				cam_fps=str2double(ac_fps_str(ac_fps_value));
				ac_ROI_general=gui.gui_retr('ac_ROI_general');
				[~,~,framerate_max]=PIVlab_capture_pco(1,gui.gui_retr('f1exp_cam'),'Synchronizer',projectpath,cam_fps,0,[],binning,ac_ROI_general,camera_type,1);
				delete(findobj('tag','roitxt'));
				text(50,50,['Max framerate: ' num2str(round(framerate_max,2)) ' Hz'],'tag','roitxt','Color','yellow','FontSize',14,'FontWeight','bold')
			end
			set(handles.ac_realtime,'Value',0);%reset realtime roi
			gui.gui_put('do_realtime',0);
		end
	end
end

