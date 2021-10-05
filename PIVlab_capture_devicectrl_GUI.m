function PIVlab_capture_devicectrl_GUI

%abgefragt in main GUI werden muss:
%ac_enable_seeding1 0 oder 1

if isempty(retr('ext_dev_01_pwm'))
	put('ext_dev_01_pwm',1)
end
if isempty(retr('ext_dev_02_pwm'))
	put('ext_dev_02_pwm',1)
end
if isempty(retr('ext_dev_03_pwm'))
	put('ext_dev_03_pwm',1)
end

if isempty(retr('ac_enable_seeding1'))
	put('ac_enable_seeding1',0)
end
if isempty(retr('ac_enable_device1'))
	put('ac_enable_device1',0)
end
if isempty(retr('ac_enable_device2'))
	put('ac_enable_device2',0)
end

seeding_control_window = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','Device control','Toolbar','none','Units','characters','Position',[3+35 5 35 15],'tag','lens_control_window','visible','on','KeyPressFcn', @key_press,'resize','off');
set (seeding_control_window,'Units','Characters');




handles = guihandles; %alle handles mit tag laden und ansprechbar machen
guidata(seeding_control_window,handles)
setappdata(0,'hseeding',seeding_control_window);

parentitem = get(seeding_control_window, 'Position');

margin=1.5;

panelheight=5;
handles.seeder1panel = uipanel(seeding_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight parentitem(3)-2 panelheight],'title','Seeder 1','fontweight','bold');
handles.device1panel = uipanel(seeding_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight*2 parentitem(3)-2 panelheight],'title','Device 1','fontweight','bold');
handles.device2panel = uipanel(seeding_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight*3 parentitem(3)-2 panelheight],'title','Device 2','fontweight','bold');

%% Seeder
parentitem=get(handles.seeder1panel, 'Position');
item=[0 0 0 0];
item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2*1 1.5];
handles.seeder_on = uicontrol(handles.seeder1panel,'Style','pushbutton','String','On','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@device_set,1,'on'} ,'TooltipString','Load image data');

item=[parentitem(3)/2*1 item(2) parentitem(3)/2*1 1.5];
handles.seeder_off = uicontrol(handles.seeder1panel,'Style','pushbutton','String','Off','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@device_set,1,'off'} ,'TooltipString','Load image data');

item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1];
handles.seeder_label = uicontrol(handles.seeder1panel,'Style','text','String','PWM [0...1]','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'horizontalalignment','right');

item=[parentitem(3)/2*1 item(2) 7 1];
handles.seeder_edit = uicontrol(handles.seeder1panel,'Style','edit','String',num2str(retr('ext_dev_01_pwm')),'units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@editfield_edit_Callback,1},'tag','seeder_edit');

item=[parentitem(3)/2+7 item(2) 15 1];
handles.seeder_active = uicontrol(handles.seeder1panel,'Style','checkbox','String','active','value',retr('ac_enable_seeding1'),'units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@checkbox_set,1},'tag','seeder_active','Tooltipstring','Enable this device when a PIV capture starts');


%% Device1
parentitem=get(handles.device1panel, 'Position');
item=[0 0 0 0];
item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2*1 1.5];
handles.device1_on = uicontrol(handles.device1panel,'Style','pushbutton','String','On','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@device_set,2,'on'} ,'TooltipString','Load image data');

item=[parentitem(3)/2*1 item(2) parentitem(3)/2*1 1.5];
handles.device1_off = uicontrol(handles.device1panel,'Style','pushbutton','String','Off','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@device_set,2,'off'} ,'TooltipString','Load image data');

item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1];
handles.device1_label = uicontrol(handles.device1panel,'Style','text','String','PWM [0...1]','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'horizontalalignment','right');

item=[parentitem(3)/2*1 item(2) 7 1];
handles.device1_edit = uicontrol(handles.device1panel,'Style','edit','String',num2str(retr('ext_dev_02_pwm')),'units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@editfield_edit_Callback,2},'tag','device1_edit');

item=[parentitem(3)/2+7 item(2) 15 1];
handles.device1_active = uicontrol(handles.device1panel,'Style','checkbox','String','active','value',retr('ac_enable_device1'),'units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@checkbox_set,2},'tag','device1_active','Tooltipstring','Enable this device when a PIV capture starts');



%% Device2
parentitem=get(handles.device2panel, 'Position');
item=[0 0 0 0];
item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2*1 1.5];
handles.device2_on = uicontrol(handles.device2panel,'Style','pushbutton','String','On','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@device_set,3,'on'} ,'TooltipString','Load image data');

item=[parentitem(3)/2*1 item(2) parentitem(3)/2*1 1.5];
handles.device2_off = uicontrol(handles.device2panel,'Style','pushbutton','String','Off','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@device_set,3,'off'} ,'TooltipString','Load image data');

item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1];
handles.device2_label = uicontrol(handles.device2panel,'Style','text','String','PWM [0...1]','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'horizontalalignment','right');

item=[parentitem(3)/2*1 item(2) 7 1];
handles.device2_edit = uicontrol(handles.device2panel,'Style','edit','String',num2str(retr('ext_dev_03_pwm')),'units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@editfield_edit_Callback,3},'tag','device2_edit');

item=[parentitem(3)/2+7 item(2) 15 1];
handles.device2_active = uicontrol(handles.device2panel,'Style','checkbox','String','active','value',retr('ac_enable_device2'),'units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@checkbox_set,3},'tag','device2_active','Tooltipstring','Enable this device when a PIV capture starts');



function checkbox_set(caller,~,device)
if device==1
	if caller.Value == 1
		put('ac_enable_seeding1',1)
	else
		put('ac_enable_seeding1',0)
	end
elseif device==2
	if caller.Value == 1
		put('ac_enable_device1',1)
	else
		put('ac_enable_device1',0)
	end
elseif device==3
	if caller.Value == 1
		put('ac_enable_device2',1)
	else
		put('ac_enable_device2',0)
	end
end

function editfield_edit_Callback(caller,~,device)
pwm=str2double(caller.String);
if device==1
	put('ext_dev_01_pwm',pwm);
	external_device_control(device,retr('ac_seeding1_status'))
elseif device==2
	put('ext_dev_02_pwm',pwm);
	external_device_control(device,retr('ac_device1_status'))
elseif device==3
	put('ext_dev_03_pwm',pwm);
	external_device_control(device,retr('ac_device2_status'))	
end	


function device_set (~,~,device,inpt)
handles=gethand;
if device == 1
	pwm=str2double(get(handles.seeder_edit,'String'));
	put('ext_dev_01_pwm',pwm);
end
if strmatch(inpt,'on')
	external_device_control(device,1)
end
if strmatch(inpt,'off')
	external_device_control(device,0)
end


function external_device_control(device,status)
hgui = getappdata(0,'hgui');
serpo=getappdata(hgui,'serpo');
try
	serpo.Port; %is there no other way to determine if serialport is working...?
	configureTerminator(serpo,'CR/LF');
	alreadyconnected=1;
catch
	alreadyconnected=0;
	delete(serpo)
end

if alreadyconnected==1
	switch device
		case 1
			if status==1
				ext_dev_01_pwm = retr('ext_dev_01_pwm');
				line_to_write=['SEEDER_01:' num2str(ext_dev_01_pwm)]
				put('ac_seeding1_status',1);
			else
				line_to_write='SEEDER_01:0'
				put('ac_seeding1_status',0);
			end
		case 2
			if status==1
				ext_dev_02_pwm = retr('ext_dev_02_pwm');
				line_to_write=['SEEDER_02:' num2str(ext_dev_02_pwm)]
				put('ac_device1_status',1);
			else
				line_to_write='SEEDER_02:0'
				put('ac_device1_status',0);
			end
		case 3
			if status==1
				ext_dev_03_pwm = retr('ext_dev_03_pwm');
				line_to_write=['SEEDER_03:' num2str(ext_dev_03_pwm)]
				put('ac_device2_status',1);
			else
				line_to_write='SEEDER_03:0'
				put('ac_device2_status',0);
			end
	end
	writeline(serpo,line_to_write);
end







%{
function [focus,aperture,lighting]=get_lens_status
focus=retr('focus');
aperture=retr('aperture');
lighting=retr('lighting');
if isempty(focus)
	focus=1500;
end
if isempty(aperture)
	aperture=1500;
end
if isempty(lighting)
	lighting=0;
end

function aperture_set (~,~,inpt)
[focus,aperture,lighting]=get_lens_status;
if strmatch(inpt,'open')
	if aperture<2500
		aperture=aperture+100;
	end
end
if strmatch(inpt,'close')
	if aperture>500
		aperture=aperture-100;
	end
end
PIVlab_capture_lensctrl (focus, aperture,lighting)
update_edit_fields

function aperture_edit_Callback(caller,~)
[focus,aperture,lighting]=get_lens_status;
aperture=str2double(caller.String);
PIVlab_capture_lensctrl (focus, aperture,lighting)

function focus_edit_Callback(caller,~)
[focus,aperture,lighting]=get_lens_status;
focus=str2double(caller.String);
PIVlab_capture_lensctrl (focus, aperture,lighting)

function update_edit_fields(~,~)
[focus,aperture,lighting]=get_lens_status;
handles=gethand;
set(handles.focus_edit ,'String', num2str(focus))
set(handles.aperture_edit ,'String', num2str(aperture))
set(handles.light_edit ,'String', num2str(lighting))


function light_switch (~, ~,inpt)
[focus,aperture,lighting]=get_lens_status;
if strmatch(inpt,'on')
	lighting=1;
end
if strmatch(inpt,'off')
	lighting=0;
end
PIVlab_capture_lensctrl (focus, aperture,lighting)
update_edit_fields

%}
function put(name, what)
hgui=getappdata(0,'hgui');
setappdata(hgui, name, what);

function var = retr(name)
hgui=getappdata(0,'hgui');
var=getappdata(hgui, name);

function handles=gethand
hseeding=getappdata(0,'hseeding');
handles=guihandles(hseeding);
