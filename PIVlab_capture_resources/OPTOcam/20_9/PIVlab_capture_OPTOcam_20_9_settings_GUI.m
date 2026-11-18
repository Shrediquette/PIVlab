function PIVlab_capture_OPTOcam_20_9_settings_GUI
% Settings window for the OPTOcam 20/9. Exposes bit depth (8/12) and gain
% (0-48 dB numeric), plus a temperature / serial / firmware readout.
%  - gain is a numeric edit field (0-48 dB)
%  - Apply stores OPTOcam_20_9_bits / OPTOcam_20_9_gain locally and refreshes the
%    bit-depth dependent pulse distance limits; it does NOT send SET_CAM_BITS to the
%    synchronizer (the 20/9 timing is calculated on the PC side)
%  - own window tag / appdata handle so it never clashes with the 2/80 window
fh = findobj('tag', 'OPTOcam_20_9_control_window');

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
	OPTOcam_control_window = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','OPTOcam 20/9 settings','Toolbar','none','Units','characters','Position', [mainpos(1)+mainpos(3)-35 mainpos(2)+15+4+4-stereo_rows 35 11+1.5+4+2+stereo_rows],'tag','OPTOcam_20_9_control_window','visible','on','resize','off');
	set (OPTOcam_control_window,'Units','Characters');


	handles = guihandles; %alle handles mit tag laden und ansprechbar machen
	guidata(OPTOcam_control_window,handles)
	setappdata(0,'hOPTOcam_20_9',OPTOcam_control_window);

	parentitem = get(OPTOcam_control_window, 'Position');

	margin=1.5;

	panelheight=12+4+2+stereo_rows;
	handles.mainpanel = uipanel(OPTOcam_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight parentitem(3)-2 panelheight],'title','OPTOcam 20/9 Settings','fontweight','bold');


	%% mainpanel
	parentitem=get(handles.mainpanel, 'Position');
	item=[0 0 0 0];

	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1.5];
	handles.bitdepth_txt = uicontrol(handles.mainpanel,'Style','text','String','Bit depth:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2 1.5];
	handles.bitdepth = uicontrol(handles.mainpanel,'Style','popupmenu','String',{'8','12'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','bitdepth');

	item=[parentitem(3)/2*0 item(2)+item(4)+margin/2 parentitem(3)/2 1.5];
	handles.gain_txt = uicontrol(handles.mainpanel,'Style','text','String','Gain (dB):','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2 1.5];
	handles.gain = uicontrol(handles.mainpanel,'Style','edit','String','0','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','gain','TooltipString','Analog gain in dB (0 to 48).');

	%% read temperature / serial / firmware from an already-open videoinput (if any)
	DeviceTemperature = 'N/A';
	DeviceSerialNumber = 'N/A';
	DeviceFirmwareVersion = 'N/A';
	try
		OPTOcam_videoinput = imaqfind('Type', 'videoinput'); %imaqfind returns a CELL array here
		if ~isempty(OPTOcam_videoinput)
			src = OPTOcam_videoinput{1}.Source;
			DeviceTemperature=num2str(round(src.DeviceTemperature));
			DeviceSerialNumber=src.DeviceSerialNumber;
			DeviceFirmwareVersion=src.DeviceFirmwareVersion;
		end
	catch
	end
	if isempty(DeviceTemperature); DeviceTemperature='N/A'; end
	cam_temperature_string=['Camera temperature: ' DeviceTemperature '°C'];

	item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
	handles.temp_txt = uicontrol(handles.mainpanel,'Style','text','String',cam_temperature_string,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[0 item(2)+item(4) parentitem(3) 1.5];
	handles.serial_txt = uicontrol(handles.mainpanel,'Style','edit','String',['Serial Nr.: ' DeviceSerialNumber],'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[0 item(2)+item(4) parentitem(3) 6];
	handles.firmware_txt = uicontrol(handles.mainpanel,'Style','text','String',['Firmware: ' DeviceFirmwareVersion],'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'FontSize',7);

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

	OPTOcam_bits=gui.camera_setting('OPTOcam_20_9_bits');
	if ~isempty(OPTOcam_bits)
		if OPTOcam_bits == 8
			set(handles.bitdepth,'Value',1);
		elseif OPTOcam_bits==12
			set(handles.bitdepth,'Value',2);
		end
	end

	OPTOcam_gain=gui.camera_setting('OPTOcam_20_9_gain');
	if ~isempty(OPTOcam_gain)
		set(handles.gain,'String',num2str(OPTOcam_gain));
	end

else %Figure handle does already exist --> bring UI to foreground.
	figure(fh)
end


function Apply_settings(~,~,~)
fh = findobj('tag', 'OPTOcam_20_9_control_window');
handles=gethand;

bitchoices=get(handles.bitdepth,'String');
OPTOcam_bits=str2double(bitchoices{get(handles.bitdepth,'value')});
gui.set_camera_setting('OPTOcam_20_9_bits',OPTOcam_bits);

%% pulse distance limits depend on the bit depth (same values as in select_capture_config_Callback)
T209 = PIVlab_capture_OPTOcam_20_9_timing(OPTOcam_bits,1000,0);
put('blind_time',T209.gap);
put('min_allowed_interframe',max(T209.min_interframe_gui,ceil(T209.min_off_time)));
put('max_allowed_interframe',floor(T209.max_interframe));

%% gain: numeric field, clamped to the camera's 0-48 dB range
gainval=str2double(get(handles.gain,'String'));
if isnan(gainval)
	gainval=0;
end
gainval=max(0,min(48,gainval));
set(handles.gain,'String',num2str(gainval)); %reflect any clamping back to the field
gui.set_camera_setting('OPTOcam_20_9_gain',gainval);

%NOTE: unlike the 2/80, we intentionally do NOT send SET_CAM_BITS to the synchronizer here:
%the 20/9 timing is calculated completely on the PC side (PIVlab_capture_OPTOcam_20_9_timing.m).

%% the bit depth changes the RAM needed per image pair: refresh the red/white image amount box
if ~isequal(retr('capturing'),1) %image_amount_Callback calls imaqreset, which would kill a running preview
	acquisition.image_amount_Callback
end

close (fh)


function show_stereo_serials(handles)
serials = gui.camera_setting('OPTOcam_20_9_stereo_serials');
if iscell(serials) && numel(serials) == 2
	set(handles.stereo_cam1_txt,'String',['Camera 1: serial nr. ' serials{1}]);
	set(handles.stereo_cam2_txt,'String',['Camera 2: serial nr. ' serials{2}]);
else
	set(handles.stereo_cam1_txt,'String','Camera 1: lower serial nr.');
	set(handles.stereo_cam2_txt,'String','Camera 2: (set at the first start)');
end

function Swap_cameras(~,~,~)
%camera 1 <-> camera 2 (stereo acquisition). The open cameras are released, so that the next start uses the new order.
serials = gui.camera_setting('OPTOcam_20_9_stereo_serials');
if ~(iscell(serials) && numel(serials) == 2)
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Swap cameras','The cameras are assigned at the first start of the live image or the PIV capture. Please start one of them first.','modal');
	return
end
if isequal(retr('capturing'),1)
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Swap cameras','Please stop the cameras first.','modal');
	return
end
gui.set_camera_setting('OPTOcam_20_9_stereo_serials',serials([2 1]));
tags = {'OPTOcam_20_9_cam1','OPTOcam_20_9_cam2'};
for t = 1:2
	vids = imaqfind('Tag',tags{t}); %a cell array with the real toolbox
	if ~iscell(vids)
		vids = num2cell(vids);
	end
	for k = 1:numel(vids)
		try
			delete(vids{k});
		catch
		end
	end
end
show_stereo_serials(gethand);

function put(name, what)
hgui=getappdata(0,'hgui');
setappdata(hgui, name, what);

function var = retr(name)
hgui=getappdata(0,'hgui');
var=getappdata(hgui, name);

function handles=gethand
hOPTOcam=getappdata(0,'hOPTOcam_20_9');
handles=guihandles(hOPTOcam);
