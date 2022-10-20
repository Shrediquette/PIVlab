function PIVlab_capture_OPTOcam_settings_GUI
fh = findobj('tag', 'OPTOcam_control_window');

if isempty(fh)
	try
		hgui=getappdata(0,'hgui');
		mainpos=get(hgui,'Position');
	catch
		mainpos=[0    2.8571  240.0000   50.9524];
	end
	OPTOcam_control_window = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','OPTOcam settings','Toolbar','none','Units','characters','Position', [mainpos(1)+mainpos(3)-35 mainpos(2)+15+4+4 35 11+1.5],'tag','OPTOcam_control_window','visible','on','KeyPressFcn', @key_press,'resize','off');
	set (OPTOcam_control_window,'Units','Characters');


	handles = guihandles; %alle handles mit tag laden und ansprechbar machen
	guidata(OPTOcam_control_window,handles)
	setappdata(0,'hOPTOcam',OPTOcam_control_window);

	parentitem = get(OPTOcam_control_window, 'Position');

	margin=1.5;

	panelheight=12;
	handles.mainpanel = uipanel(OPTOcam_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight parentitem(3)-2 panelheight],'title','OPTOcam Settings','fontweight','bold');


	%% mainpanel
	parentitem=get(handles.mainpanel, 'Position');
	item=[0 0 0 0];
	
	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1];
	handles.bitdepth_txt = uicontrol(handles.mainpanel,'Style','text','String','Bit depth:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2 1];
	handles.bitdepth = uicontrol(handles.mainpanel,'Style','popupmenu','String',{'8','12'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','bitdepth');

	item=[parentitem(3)/2*0 item(2)+item(4)+margin/2 parentitem(3)/2 1];
	handles.gain_txt = uicontrol(handles.mainpanel,'Style','text','String','Gain:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2 1];
	handles.gain = uicontrol(handles.mainpanel,'Style','popupmenu','String',{'0','10','20','30'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','gain');

	item=[parentitem(3)/2 item(2)+item(4)+margin parentitem(3)/2 2];
	handles.apply_btn = uicontrol(handles.mainpanel,'Style','pushbutton','String','Apply','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@Apply_settings,'tag','apply_btn');

	OPTOcam_bits=retr('OPTOcam_bits');
	if ~isempty(OPTOcam_bits)
		if OPTOcam_bits == 8
			set(handles.bitdepth,'Value',1);
		elseif OPTOcam_bits==12
			set(handles.bitdepth,'Value',2);
		end
	end

	OPTOcam_gain=retr('OPTOcam_gain');
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

put('OPTOcam_bits',str2double(bitchoices{get(handles.bitdepth,'value')}));
pause(0.01)
OPTOcam_bits=retr('OPTOcam_bits');
if OPTOcam_bits==8
	put('min_allowed_interframe',61); %8bit
elseif OPTOcam_bits==12
	put('min_allowed_interframe',128); %12bit
end


gainchoices=get(handles.gain,'String');

put('OPTOcam_gain',str2double(gainchoices{get(handles.gain,'value')}));


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
		flush(serpo)
		writeline(serpo,['TALKINGTO:' laser_device_id ';SET_CAM_BITS:' num2str(OPTOcam_bits)]);
	else
		msgbox('Error: Bit mode can only be set when connected to the laser / synchronizer!','modal')
	uiwait
	end
catch
end
close (fh)


function put(name, what)
hgui=getappdata(0,'hgui');
setappdata(hgui, name, what);

function var = retr(name)
hgui=getappdata(0,'hgui');
var=getappdata(hgui, name);

function handles=gethand
hOPTOcam=getappdata(0,'hOPTOcam');
handles=guihandles(hOPTOcam);
