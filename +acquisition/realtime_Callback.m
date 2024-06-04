function realtime_Callback(~,~,~)
handles=gui.gethand;
if get(handles.ac_realtime,'Value')==1
	gui.put('capturing',0);
	try
		expos=round(str2num(get(handles.ac_expo,'String'))*1000);
	catch
		set(handles.ac_expo,'String','100');
		expos=100000;
	end
	projectpath=get(handles.ac_project,'String');
	capture_ok=acquisition.check_project_path(projectpath,'calibration');
	ac_ROI_general=gui.retr('ac_ROI_general');
	binning=gui.retr('binning');
	if isempty(binning)
		binning=1;
	end
	if isempty(ac_ROI_general)
		max_cam_res=gui.retr('max_cam_res');
		ac_ROI_general=[1,1,max_cam_res(1)/binning,max_cam_res(2)/binning];
	end
	camera_type=gui.retr('camera_type');
	try
		if capture_ok==1
			gui.put('cancel_capture',0);
			gui.put('capturing',1);
			if ~strcmp(camera_type,'chronos') %calib
				[errorcode, caliimg]=PIVlab_capture_pco(1,expos,'Calibration',projectpath,[],0,[],binning,ac_ROI_general,camera_type,0);
			else
				%not supported yet....

			end
		end
		gui.put('capturing',0);
		uiwait(msgbox(['Please select the ROI for real-time PIV.'],'modal'))
		roirect = round(getrect(gca));
		if roirect(1,3)~=0 && roirect(1,4)~=0
			gui.put('ac_ROI_realtime',roirect);
			gui.put('do_realtime',1);
		end
	catch
		gui.put('do_realtime',0);
		set(handles.ac_realtime,'Value',0)
	end
else
	gui.put('do_realtime',0);
end

