function PIVlab_capture_chronos_settings_GUI
fh = findobj('tag', 'chronos_control_window');

if isempty(fh)
	try
		hgui=getappdata(0,'hgui');
		mainpos=get(hgui,'Position');
	catch
		mainpos=[0    2.8571  240.0000   50.9524];
	end
	chronos_control_window = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','Chronos settings','Toolbar','none','Units','characters','Position', [mainpos(1)+mainpos(3)-35 mainpos(2)+15+4+4 35 11+1.5],'tag','chronos_control_window','visible','on','KeyPressFcn', @key_press,'resize','off');
	set (chronos_control_window,'Units','Characters');


	handles = guihandles; %alle handles mit tag laden und ansprechbar machen
	guidata(chronos_control_window,handles)
	setappdata(0,'hchronos',chronos_control_window);

	parentitem = get(chronos_control_window, 'Position');

	margin=1.5;

	panelheight=12;
	handles.mainpanel = uipanel(chronos_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight parentitem(3)-2 panelheight],'title','Chronos Settings','fontweight','bold');


	%% mainpanel
	parentitem=get(handles.mainpanel, 'Position');
	item=[0 0 0 0];
	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/3*1 1];
	handles.ip_txt = uicontrol(handles.mainpanel,'Style','text','String','IP:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);
	item=[parentitem(3)/3*1 item(2) parentitem(3)/3*2 1];
	handles.ip_input = uicontrol(handles.mainpanel,'Style','edit','String','192.168.162.20','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','ip_input');

	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1];
	handles.resx_txt = uicontrol(handles.mainpanel,'Style','text','String','x resolution:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2*1 1];
	handles.resx_input = uicontrol(handles.mainpanel,'Style','edit','String','1280','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag', 'resx_input');

	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1];
	handles.resy_txt = uicontrol(handles.mainpanel,'Style','text','String','y resolution:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2*1 1];
	handles.resy_input = uicontrol(handles.mainpanel,'Style','edit','String','1024','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)] ,'tag', 'resy_input');

	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1];
	handles.bits_txt = uicontrol(handles.mainpanel,'Style','text','String','bit depth:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2*1 1];
	handles.bits_input = uicontrol(handles.mainpanel,'Style','edit','String','12','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)] ,'tag', 'bits_input');

	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1];
	handles.save_txt = uicontrol(handles.mainpanel,'Style','text','String','Save location:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2 1];
	handles.save_location = uicontrol(handles.mainpanel,'Style','popupmenu','String',{'Download','SSD','SD Card'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','save_location');

	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1];
	handles.save_type_txt = uicontrol(handles.mainpanel,'Style','text','String','File type:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2 1];
	handles.save_type = uicontrol(handles.mainpanel,'Style','popupmenu','String',{'TIFF RAW','TIFF','H264'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','save_type');

	item=[parentitem(3)/2*0 item(2)+item(4)+0.5 parentitem(3)/2 2];
	handles.apply_btn = uicontrol(handles.mainpanel,'Style','pushbutton','String','Apply','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@Apply_settings,'tag','apply_btn');

	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2*1 1];
	handles.reboot_btn = uicontrol(handles.mainpanel,'Style','pushbutton','String','Reboot','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@Reboot);

	%item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2*1 1];
	%handles.get_imgs_btn = uicontrol(handles.mainpanel,'Style','pushbutton','String','Get imgs','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@Get_imgs);

else %Figure handle does already exist --> bring UI to foreground.
	figure(fh)
end

save_location=retr('save_location');
if ~isempty(save_location)
	if matches(save_location,'SSD')
		set(handles.save_location,'Value',2);
	elseif matches(save_location,'SD Card')
		set(handles.save_location,'Value',3);
	elseif matches(save_location,'Download')
		set(handles.save_location,'Value',1);
	end
end

save_type=retr('save_type');
if ~isempty(save_type)
	if matches(save_type,'TIFF')
		set(handles.save_type,'Value',2);
	elseif matches(save_type,'H264')
		set(handles.save_type,'Value',3);
	elseif matches(save_type,'TIFF RAW')
		set(handles.save_type,'Value',1);
	end
end


warning off
old_IP=load('PIVlab_settings_default.mat','Chronos_IP');
warning on
if isfield(old_IP,'Chronos_IP')
	cameraIP=old_IP.Chronos_IP;
	
else
cameraIP='192.168.0.0';

end
put('Chronos_IP',cameraIP);
	set(handles.ip_input,'String',cameraIP);







function Apply_settings(~,~,~)

handles=gethand;

put('Chronos_IP',get(handles.ip_input,'String'));
Chronos_IP=get(handles.ip_input,'String');
save('PIVlab_settings_default.mat','Chronos_IP','-append');

selected=get(handles.save_location, 'Value');
values=get(handles.save_location,'String');

put('save_location',values{selected});


selected=get(handles.save_type, 'Value');
values=get(handles.save_type,'String');

put('save_type',values{selected});


cameraIP=retr('Chronos_IP');
cameraURL = ['http://' cameraIP];
options = weboptions('MediaType','application/json','HeaderFields',{'Content-Type' 'application/json'});

set (handles.apply_btn,'String','Wait...');
toolsavailable(0);drawnow;

%{
response = webwrite([cameraURL '/control/p'],struct('disableRingBuffer',1),options);
if response.disableRingBuffer == 1
	disp('Ring buffer disable OK!')
else
	disp('Error: Ring buffer could not be disabled!')
end
%}

resx=str2double(get(handles.resx_input,'String'));
resy=str2double(get(handles.resy_input,'String'));
bitdepth=str2double(get(handles.bits_input,'String'));

put('Chronos_resx',resx);
put('Chronos_resy',resy);
put('Chronos_bits',bitdepth);

dataInside = struct('hRes', resx, 'vRes', resy, 'bitDepth', bitdepth);
dataOutside = struct('resolution', dataInside);
% Change resolution via an HTTP POST request.
try
response = webwrite([cameraURL '/control/p'],dataOutside,options);
if response.resolution.hRes==resx && response.resolution.vRes==resy && response.resolution.bitDepth==bitdepth
	disp('Setting resolution OK!')
	set (handles.apply_btn,'String','OK!');drawnow
else
	disp('Error: Resolution could not be set!')
end
communication_ok=1;
catch
	communication_ok=0;
end
if communication_ok
	%check maximum framerate and maximum exposure for current resolution
	response = webwrite([cameraURL '/control/getResolutionTimingLimits'],struct('hRes',resx,'vRes',resy),options);
	max_exp=response.exposureMax;
	max_fr=1/(response.minFramePeriod/1000/1000/1000);
	response = webwrite([cameraURL '/control/p'],struct('exposureMode','normal','exposurePeriod', floor(max_exp),'frameRate',max_fr),options);
	if strmatch(response.exposureMode,'normal')
		set (handles.apply_btn,'String','Apply');
		toolsavailable(1)
		
	end
else
	msgbox(['Could not connect to ' cameraIP],'Error','error','modal');
	toolsavailable(1)
	set (handles.apply_btn,'String','Apply');
end

function Reboot (~,~,~)
handles=gethand;
put('Chronos_IP',get(handles.ip_input,'String'));
cameraIP=retr('Chronos_IP');
cameraURL = ['http://' cameraIP];
options = weboptions('MediaType','application/json','HeaderFields',{'Content-Type' 'application/json'});
response = webwrite([cameraURL '/control/p'],struct('exposureMode','normal','exposureNormalized', 1.0,'frameRate',1057),options); %enable internal trigger
pause(1)
response = webwrite([cameraURL '/control/reboot'],struct('power',1,'reload',1,'settings',0),options);


function Get_imgs (~,~,~)
handles=gethand;
put('Chronos_IP',get(handles.ip_input,'String'));
cameraIP=retr('Chronos_IP');
cameraURL = ['http://' cameraIP];
options = weboptions('MediaType','application/json','HeaderFields',{'Content-Type' 'application/json'});

response=webread([cameraURL '/control/stopRecording']);
pause(0.5)
response=webread([cameraURL '/control/startPlayback']);
pause(0.1)

chronos_total_avail_frames=webread([cameraURL '/control/p/totalFrames']) % chronos_current_save_frame.playbackPosition

%was will ich denn eigentlich erreichen....?

%PIVlab_capture_chronos_save (cameraIP,chronos_total_avail_frames,ImagePath,frame_nr_display)


%put('cancel_capture',1)
%auslöesen wie viele frames
%button wechselt zu cancel um abzubrechen







function put(name, what)
hgui=getappdata(0,'hgui');
setappdata(hgui, name, what);

function var = retr(name)
hgui=getappdata(0,'hgui');
var=getappdata(hgui, name);

function handles=gethand
hchronos=getappdata(0,'hchronos');
handles=guihandles(hchronos);

function toolsavailable(inpt)
%0: disable all tools
%1: re-enable tools that were previously also enabled
hchronos=getappdata(0,'hchronos');
handles=gethand;


elementsOfCrime=findobj(hchronos, 'type', 'uicontrol');
elementsOfCrime2=findobj(hchronos, 'type', 'uimenu');
statuscell=get (elementsOfCrime, 'enable');
wasdisabled=zeros(size(statuscell),'uint8');

if inpt==0
	set(elementsOfCrime, 'enable', 'off');
	for i=1:size(statuscell,1)
		if strncmp(statuscell{i,1}, 'off',3) ==1
			wasdisabled(i)=1;
		end
	end
	put('wasdisabled', wasdisabled);
	set(elementsOfCrime2, 'enable', 'off');
else
	wasdisabled=retr('wasdisabled');
	set(elementsOfCrime, 'enable', 'on');
	set(elementsOfCrime(wasdisabled==1), 'enable', 'off');
	set(elementsOfCrime2, 'enable', 'on');
end