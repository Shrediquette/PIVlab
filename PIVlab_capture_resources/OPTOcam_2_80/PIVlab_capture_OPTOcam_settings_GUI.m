function PIVlab_capture_OPTOcam_settings_GUI
fh = findobj('tag', 'OPTOcam_control_window');

if isempty(fh)
	try
		hgui=getappdata(0,'hgui');
		mainpos=get(hgui,'Position');
	catch
		mainpos=[0    2.8571  240.0000   50.9524];
	end
    if isempty(mainpos)
        mainpos=[0    2.8571  240.0000   50.9524];
    end

	stereo_rows = 0; %stereo acquisition: rows for camera 1 / 2 and the swap button
	if acquisition.capture_cameras > 1
		stereo_rows = 5.5;
	end
	OPTOcam_control_window = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','OPTOcam settings','Toolbar','none','Units','characters','Position', [mainpos(1)+mainpos(3)-35 mainpos(2)+15+4+4-stereo_rows 35 11+1.5+4+2+stereo_rows],'tag','OPTOcam_control_window','visible','on','KeyPressFcn', @key_press,'resize','off');
	set (OPTOcam_control_window,'Units','Characters');


	handles = guihandles; %alle handles mit tag laden und ansprechbar machen
	guidata(OPTOcam_control_window,handles)
	setappdata(0,'hOPTOcam',OPTOcam_control_window);

	parentitem = get(OPTOcam_control_window, 'Position');

	margin=1.5;

	panelheight=12+4+2+stereo_rows;
	handles.mainpanel = uipanel(OPTOcam_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight parentitem(3)-2 panelheight],'title','OPTOcam Settings','fontweight','bold');


	%% mainpanel
	parentitem=get(handles.mainpanel, 'Position');
	item=[0 0 0 0];
	
	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1.5];
	handles.bitdepth_txt = uicontrol(handles.mainpanel,'Style','text','String','Bit depth:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2 1.5];
	handles.bitdepth = uicontrol(handles.mainpanel,'Style','popupmenu','String',{'8','12'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','bitdepth');

	item=[parentitem(3)/2*0 item(2)+item(4)+margin/2 parentitem(3)/2 1.5];
	handles.gain_txt = uicontrol(handles.mainpanel,'Style','text','String','Gain:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2 1.5];
	handles.gain = uicontrol(handles.mainpanel,'Style','popupmenu','String',{'0','10','20','30'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','gain');

	try
		OPTOcam_videoinput = imaqfind('Type', 'videoinput');
		OPTOcam_videoinput=OPTOcam_videoinput{1};
		OPTOcam_videoinput=OPTOcam_videoinput.Source;
		DeviceTemperature=num2str(round(OPTOcam_videoinput.DeviceTemperature));
	catch
		DeviceTemperature = 'N/A';
	end
	if isempty(DeviceTemperature)
		DeviceTemperature='N/A';
	end
	cam_temperature_string=['Camera temperature: ' DeviceTemperature '°C'];

	try
		OPTOcam_videoinput = imaqfind('Type', 'videoinput');
		OPTOcam_videoinput=OPTOcam_videoinput{1};
		OPTOcam_videoinput=OPTOcam_videoinput.Source;
		DeviceSerialNumber=OPTOcam_videoinput.DeviceSerialNumber;
	catch
		DeviceSerialNumber = 'N/A';
	end

	try
		OPTOcam_videoinput = imaqfind('Type', 'videoinput');
		OPTOcam_videoinput=OPTOcam_videoinput{1};
		OPTOcam_videoinput=OPTOcam_videoinput.Source;
		DeviceFirmwareVersion=OPTOcam_videoinput.DeviceFirmwareVersion;
		DeviceFirmwareVersion2=strsplit(DeviceFirmwareVersion,'/');
	catch
		DeviceFirmwareVersion2 = 'N/A';
	end



	item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
	handles.temp_txt = uicontrol(handles.mainpanel,'Style','text','String',cam_temperature_string,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[0 item(2)+item(4) parentitem(3) 1.5];
	handles.serial_txt = uicontrol(handles.mainpanel,'Style','edit','String',['Serial Nr.: ' DeviceSerialNumber],'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

item=[0 item(2)+item(4) parentitem(3) 6];
	handles.firmware_txt = uicontrol(handles.mainpanel,'Style','text','String',['Firmware: ' DeviceFirmwareVersion2],'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'FontSize',7);

	if stereo_rows > 0 %stereo acquisition: which camera is camera 1 (serial numbers)
		item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
		handles.stereo_cam1_txt = uicontrol(handles.mainpanel,'Style','text','String','','Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','stereo_cam1_txt');
		item=[0 item(2)+item(4) parentitem(3) 1.5];
		handles.stereo_cam2_txt = uicontrol(handles.mainpanel,'Style','text','String','','Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','stereo_cam2_txt');
		item=[0 item(2)+item(4) parentitem(3) 2];
		handles.swap_btn = uicontrol(handles.mainpanel,'Style','pushbutton','String','Swap cameras','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@Swap_cameras,'tag','swap_btn','TooltipString','Exchange camera 1 and camera 2 of the stereo setup');
		show_stereo_serials(handles);
	end

	item=[parentitem(3)/2 item(2)+item(4)+margin/2 parentitem(3)/2 2];
	handles.apply_btn = uicontrol(handles.mainpanel,'Style','pushbutton','String','Apply','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@Apply_settings,'tag','apply_btn');

	OPTOcam_bits=gui.camera_setting('OPTOcam_bits');
	if ~isempty(OPTOcam_bits)
		if OPTOcam_bits == 8
			set(handles.bitdepth,'Value',1);
		elseif OPTOcam_bits==12
			set(handles.bitdepth,'Value',2);
		end
	end

	OPTOcam_gain=gui.camera_setting('OPTOcam_gain');
	if ~isempty(OPTOcam_gain)
		if OPTOcam_gain == 0
			set(handles.gain,'Value',1);
		elseif OPTOcam_gain==10
			set(handles.gain,'Value',2);
		elseif OPTOcam_gain==20
			set(handles.gain,'Value',3);
		elseif OPTOcam_gain==30
			set(handles.gain,'Value',4);
		end
	end

else %Figure handle does already exist --> bring UI to foreground.
	figure(fh)
end


function Apply_settings(~,~,~)
fh = findobj('tag', 'OPTOcam_control_window');
handles=gethand;

bitchoices=get(handles.bitdepth,'String');

gui.set_camera_setting('OPTOcam_bits',str2double(bitchoices{get(handles.bitdepth,'value')}));
pause(0.01)
OPTOcam_bits=gui.camera_setting('OPTOcam_bits');
if OPTOcam_bits==8
	put('min_allowed_interframe',62); %8bit
	put('blind_time',44);
elseif OPTOcam_bits==12
	put('min_allowed_interframe',128); %12bit
	put('blind_time',96);
end


gainchoices=get(handles.gain,'String');

gui.set_camera_setting('OPTOcam_gain',str2double(gainchoices{get(handles.gain,'value')}));


hgui = getappdata(0,'hgui');
serpo=getappdata(hgui,'serpo');
laser_device_id=retr('laser_device_id');

try
	serpo.Port; %is there no other way to determine if serialport is working...?
	alreadyconnected=1;
catch
	alreadyconnected=0;
	delete(serpo)
end
try
	if alreadyconnected==1
        pause(0.1)
        flush(serpo);pause(0.1)
        writeline(serpo,['TALKINGTO:' laser_device_id ';SET_CAM_BITS:' num2str(OPTOcam_bits)]);
    else
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Bit mode can only be set when connected to the laser / synchronizer!','modal');
    end
catch
end
%% the bit depth changes the RAM needed per image pair: refresh the red/white image amount box
if ~isequal(retr('capturing'),1) %image_amount_Callback calls imaqreset, which would kill a running preview
	acquisition.image_amount_Callback
end
close (fh)


function show_stereo_serials(handles)
serials = gui.camera_setting('OPTOcam_stereo_serials');
if iscell(serials) && numel(serials) == 2
	set(handles.stereo_cam1_txt,'String',['Camera 1: serial nr. ' serials{1}]);
	set(handles.stereo_cam2_txt,'String',['Camera 2: serial nr. ' serials{2}]);
else
	set(handles.stereo_cam1_txt,'String','Camera 1: lower serial nr.');
	set(handles.stereo_cam2_txt,'String','Camera 2: (set at the first start)');
end

function Swap_cameras(~,~,~)
%camera 1 <-> camera 2 (stereo acquisition). The open cameras are released, so that the next start uses the new order.
serials = gui.camera_setting('OPTOcam_stereo_serials');
if ~(iscell(serials) && numel(serials) == 2)
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Swap cameras','The cameras are assigned at the first start of the live image or the PIV capture. Please start one of them first.','modal');
	return
end
if isequal(retr('capturing'),1)
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Swap cameras','Please stop the cameras first.','modal');
	return
end
gui.set_camera_setting('OPTOcam_stereo_serials',serials([2 1]));
try
	delete(imaqfind('Tag','OPTOcam_cam1'));
	delete(imaqfind('Tag','OPTOcam_cam2'));
catch
end
show_stereo_serials(gethand);

function put(name, what)
hgui=getappdata(0,'hgui');
setappdata(hgui, name, what);

function var = retr(name)
hgui=getappdata(0,'hgui');
var=getappdata(hgui, name);

function handles=gethand
hOPTOcam=getappdata(0,'hOPTOcam');
handles=guihandles(hOPTOcam);
