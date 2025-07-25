function PIVlab_capture_OPTRONIS_settings_GUI
fh = findobj('tag', 'OPTRONIS_control_window');

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

	OPTRONIS_control_window = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','OPTRONIS settings','Toolbar','none','Units','characters','Position', [mainpos(1)+mainpos(3)-35 mainpos(2)+15+4+4 35 11+1.5+5],'tag','OPTRONIS_control_window','visible','on','KeyPressFcn', @key_press,'resize','off');
	set (OPTRONIS_control_window,'Units','Characters');


	handles = guihandles; %alle handles mit tag laden und ansprechbar machen
	guidata(OPTRONIS_control_window,handles)
	setappdata(0,'hOPTRONIS',OPTRONIS_control_window);

	parentitem = get(OPTRONIS_control_window, 'Position');

	margin=1.5;

	panelheight=12+5;
	handles.mainpanel = uipanel(OPTRONIS_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight parentitem(3)-2 panelheight],'title','OPTRONIS Settings','fontweight','bold');


	%% mainpanel
	parentitem=get(handles.mainpanel, 'Position');
	item=[0 0 0 0];
	
	item=[parentitem(3)/2*0 item(2)+item(4)+margin/4 parentitem(3)/2 2];
	handles.bitdepth_txt = uicontrol(handles.mainpanel,'Style','text','String','Bit depth:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2 2];
	handles.bitdepth = uicontrol(handles.mainpanel,'Style','popupmenu','String',{'8','10'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','bitdepth');

	item=[parentitem(3)/2*0 item(2)+item(4)+margin/4 parentitem(3)/2 2];
	handles.gain_txt = uicontrol(handles.mainpanel,'Style','text','String','Gain:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2 2];
	handles.gain = uicontrol(handles.mainpanel,'Style','popupmenu','String',{'1','2','4'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','gain');

	item=[parentitem(3)/2*0 item(2)+item(4)+margin/4 parentitem(3)/2 2];
	handles.counter_txt = uicontrol(handles.mainpanel,'Style','text','String','Enable image counter','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2 2];
	handles.counter = uicontrol(handles.mainpanel,'Style','popupmenu','String',{'Off','On'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','counter');




    try
	delete(imaqfind); %clears all previous videoinputs
	warning off
	hwinf = imaqhwinfo;
	warning on
	%imaqreset
catch
	
end
info = imaqhwinfo(hwinf.InstalledAdaptors{1});

try
	OPTRONIS_name = info.DeviceInfo.DeviceName;
catch

end


OPTRONIS_vid = videoinput(info.AdaptorName,info.DeviceInfo.DeviceID,'Mono8');
OPTRONIS_settings = get(OPTRONIS_vid);



	try
	
		DeviceTemperature=num2str(round(OPTRONIS_settings.Source.Temperature));
	catch
		DeviceTemperature = 'N/A';
	end
	if isempty(DeviceTemperature)
		DeviceTemperature='N/A';
	end
	cam_temperature_string=['Camera temperature: ' DeviceTemperature '°C'];

	try
		DeviceSerialNumber = OPTRONIS_settings.Source.DeviceSerialNumber;
	catch
		DeviceSerialNumber = 'N/A';
	end

	try
		DeviceFirmwareVersion=OPTRONIS_settings.Source.DeviceFirmwareVersion;
	catch
		DeviceFirmwareVersion2 = 'N/A';
	end

	item=[0 item(2)+item(4)+margin/4 parentitem(3) 1];
    handles.temp_txt = uicontrol(handles.mainpanel,'Style','text','String',cam_temperature_string,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

    item=[0 item(2)+item(4) parentitem(3) 1];
    handles.serial_txt = uicontrol(handles.mainpanel,'Style','text','String',['Serial Nr.: ' DeviceSerialNumber],'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

    item=[0 item(2)+item(4) parentitem(3) 2];
    handles.firmware_txt = uicontrol(handles.mainpanel,'Style','text','String',['Firmware: ' DeviceFirmwareVersion],'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

    item=[parentitem(3)/2 item(2)+item(4)+margin/4 parentitem(3)/2 2];
    handles.apply_btn = uicontrol(handles.mainpanel,'Style','pushbutton','String','Apply','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@Apply_settings,'tag','apply_btn');

	OPTRONIS_bits=retr('OPTRONIS_bits');
	if ~isempty(OPTRONIS_bits)
		if OPTRONIS_bits == 8
			set(handles.bitdepth,'Value',1);
		elseif OPTRONIS_bits==10
			set(handles.bitdepth,'Value',2);
		end
	end

    OPTRONIS_gain=retr('OPTRONIS_gain');
    if isempty(OPTRONIS_gain)
        OPTRONIS_gain=1;
    end

    OPTRONIS_counter=retr('OPTRONIS_counter');
    if isempty(OPTRONIS_counter)
        OPTRONIS_counter=0;
    end

    if ~isempty(OPTRONIS_counter)
        if OPTRONIS_counter == 0
            set(handles.counter,'Value',1);
        elseif OPTRONIS_counter==1
            set(handles.counter,'Value',2);
        end
    end
    put('OPTRONIS_counter',OPTRONIS_counter);


    if ~isempty(OPTRONIS_gain)
        if OPTRONIS_gain == 1
            set(handles.gain,'Value',1);
        elseif OPTRONIS_gain==2
            set(handles.gain,'Value',2);
        elseif OPTRONIS_gain==4
            set(handles.gain,'Value',3);
        end
    end
    put('OPTRONIS_gain',OPTRONIS_gain);

else %Figure handle does already exist --> bring UI to foreground.
	figure(fh)
end

function Apply_settings(~,~,~)
fh = findobj('tag', 'OPTRONIS_control_window');
handles=gethand;

bitchoices=get(handles.bitdepth,'String');

put('OPTRONIS_bits',str2double(bitchoices{get(handles.bitdepth,'value')}));
pause(0.01)
gainchoices=get(handles.gain,'String');
put('OPTRONIS_gain',str2double(gainchoices{get(handles.gain,'value')}));


counterchoices=get(handles.counter,'String');
if strcmpi(counterchoices{get(handles.counter,'value')},'off')
    put('OPTRONIS_counter',0)
elseif strcmpi(counterchoices{get(handles.counter,'value')},'on')
    put('OPTRONIS_counter',1)
end
close (fh)


function put(name, what)
hgui=getappdata(0,'hgui');
setappdata(hgui, name, what);

function var = retr(name)
hgui=getappdata(0,'hgui');
var=getappdata(hgui, name);

function handles=gethand
hOPTRONIS=getappdata(0,'hOPTRONIS');
handles=guihandles(hOPTRONIS);