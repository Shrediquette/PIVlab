function PIVlab_capture_lensctrl_GUI
fh = findobj('tag', 'lens_control_window');
if isempty(fh)
	hgui=getappdata(0,'hgui');
	mainpos=get(hgui,'Position');
	[focus,aperture,lighting]=get_lens_status;
	lens_control_window = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','Lens control','Toolbar','none','Units','characters','Position',[mainpos(1)+mainpos(3)-35 mainpos(2) 35 15+1.5+4],'tag','lens_control_window','visible','on','KeyPressFcn', @key_press,'resize','off','CloseRequestFcn',@CloseRequestFcn);
	set (lens_control_window,'Units','Characters');
	
	handles = guihandles; %alle handles mit tag laden und ansprechbar machen
	guidata(lens_control_window,handles)
	setappdata(0,'hlens',lens_control_window);
	
	parentitem = get(lens_control_window, 'Position');
	
	margin=1.5;
	
	panelheight=5;
	handles.aperturepanel = uipanel(lens_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight-1.5 parentitem(3)-2 panelheight],'title','Aperture control','fontweight','bold','tag','aperturepanel');
	handles.focuspanel = uipanel(lens_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight*2-1.5 parentitem(3)-2 panelheight],'title','Focus control','fontweight','bold','tag','focuspanel');
	handles.lightpanel = uipanel(lens_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight*3-1.5 parentitem(3)-2 panelheight],'title','Light control','fontweight','bold','tag','lightpanel');
	handles.anglepanel = uipanel(lens_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight*3-1.5-4 parentitem(3)-2 4],'title','Camera attitude','fontweight','bold','tag','anglepanel');
	
	%% Load last selected setting & setup Configurations
	warning off
	load ('PIVlab_capture_resources\PIVlab_capture_lensconfig.mat','lens_configurations','selected_lens_config_nr');
	warning on
	if ~exist('selected_lens_config_nr','var')
		selected_lens_config_nr = 2; %set default to zeiss Dimension
	end
	put('selected_lens_config',selected_lens_config_nr) 
	save ('PIVlab_capture_resources\PIVlab_capture_lensconfig.mat','lens_configurations','selected_lens_config_nr');
	% New lens configurations can be added to the table by modifying the variable 'lens_configurations' in the file 'PIVlab_capture_lensconfig.mat :
	% Example: lens_configurations=addvars(lens_configurations,[500;2500;500;2500],'NewVariableNames','Generic lens')
	handles.configu = uicontrol(lens_control_window,'Style','popupmenu', 'String',lens_configurations.Properties.VariableNames,'Value',retr('selected_lens_config'),'Units','characters', 'Fontunits','points','Position',[1 parentitem(4)-1.5 parentitem(3)/3*2 1.5],'Tag','configu','TooltipString','Lens configuration. Sets the limits for the servo motors.','Callback',@configu_Callback);
	parentitem=get(lens_control_window, 'Position');
	item=[parentitem(3)/3*2 0 parentitem(3)/3 1.5];
	handles.lens_status = uicontrol(lens_control_window,'Style','edit','units','characters','HorizontalAlignment','center','position',[item(1)+margin parentitem(4)-1.5 item(3)-margin*1.5 item(4)],'String','N/A','tag', 'lens_status','FontName','FixedWidth','BackgroundColor',[1 0 0],'Foregroundcolor',[0 0 0],'Enable','inactive','Fontweight','bold');
	if selected_lens_config_nr ~=4
		all_features_visible='on';
	else
		all_features_visible='off';
	end
	put ('all_features_visible',all_features_visible);


	%% APERTURE
	parentitem=get(handles.aperturepanel, 'Position');
	item=[0 0 0 0];
	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2*1 1.5];
	handles.aperture_open = uicontrol(handles.aperturepanel,'Style','pushbutton','String','Iris open','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@aperture_set,'open'} ,'TooltipString','Load image data');
	
	item=[parentitem(3)/2*1 item(2) parentitem(3)/2*1 1.5];
	handles.aperture_close = uicontrol(handles.aperturepanel,'Style','pushbutton','String','Iris close','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@aperture_set,'close'} ,'TooltipString','Load image data');
	
	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1];
	handles.aperture_label = uicontrol(handles.aperturepanel,'Style','text','String','Iris [us]','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'horizontalalignment','right');
	
	item=[parentitem(3)/2*1 item(2) parentitem(3)/3 1];
	handles.aperture_edit = uicontrol(handles.aperturepanel,'Style','edit','String',num2str(aperture),'units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@aperture_edit_Callback,'tag','aperture_edit');
	
	%% FOCUS
	parentitem=get(handles.focuspanel, 'Position');
	item=[0 0 0 0];
	item=[0 item(2)+item(4) parentitem(3)/3 1.5];
	handles.focus_close = uicontrol(handles.focuspanel,'Style','pushbutton','String','Near','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@focus_set,'near'} ,'TooltipString','Load image data');
	
	item=[parentitem(3)/3*1 item(2) parentitem(3)/3 1.5];
	handles.focus_auto = uicontrol(handles.focuspanel,'Style','pushbutton','String','Auto','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@focus_set,'auto'} ,'TooltipString','Load image data');
	
	item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1.5];
	handles.focus_far = uicontrol(handles.focuspanel,'Style','pushbutton','String','Far','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@focus_set,'far'} ,'TooltipString','Load image data');
	
	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1];
	handles.focus_label = uicontrol(handles.focuspanel,'Style','text','String','Focus [us]','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'horizontalalignment','right');
	
	item=[parentitem(3)/2*1 item(2) parentitem(3)/3 1];
	handles.focus_edit = uicontrol(handles.focuspanel,'Style','edit','String',num2str(focus),'units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@focus_edit_Callback,'tag','focus_edit');
	setappdata(lens_control_window,'handle_to_focus_edit_field',handles.focus_edit); %needed so other files can edit the contents.
	
	%% LIGHT
	parentitem=get(handles.lightpanel, 'Position');
	item=[0 0 0 0];
	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2*1 1.5];
	handles.light_on = uicontrol(handles.lightpanel,'Style','pushbutton','String','Light on','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@light_switch,'on'} ,'TooltipString','Load image data');
	
	item=[parentitem(3)/2*1 item(2) parentitem(3)/2*1 1.5];
	handles.light_off = uicontrol(handles.lightpanel,'Style','pushbutton','String','Light off','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@light_switch,'off'},'TooltipString','Load image data');
	
	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1];
	handles.light_label = uicontrol(handles.lightpanel,'Style','text','String','Light status','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'horizontalalignment','right');
	item=[parentitem(3)/2*1 item(2) parentitem(3)/3 1];
	handles.light_edit = uicontrol(handles.lightpanel,'Style','edit','String',num2str(lighting),'units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@focus_edit_Callback,'tag','light_edit','enable','off');
	
	configu_Callback(handles.configu,[]) %execute callback and set servo limits
	
	%% Angle feedback
	parentitem=get(handles.anglepanel, 'Position');
	item=[0 0 parentitem(3) 1];
	handles.angle_measure = uicontrol(handles.anglepanel,'Style','checkbox','String','Measure angle','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'horizontalalignment','left','Callback',@angle_measure_Callback,'tag','angle_measure');
	
	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/3 1.5];
	handles.pitch = uicontrol(handles.anglepanel,'Style','text','String','Pitch: 0','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'horizontalalignment','left','tag','pitch');
	
	item=[parentitem(3)/2*1 item(2) parentitem(3)/3 1.5];
	handles.roll = uicontrol(handles.anglepanel,'Style','text','String','Roll: 0','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'horizontalalignment','left','tag','roll');
	limit_displayed_features
	find_devices


else %Figure handle does already exist --> bring UI to foreground.
	figure(fh)
end

function limit_displayed_features
all_features_visible=retr('all_features_visible');
aperturepanel=findobj('Tag','aperturepanel');
lightpanel=findobj('Tag','lightpanel');
anglepanel=findobj('Tag','anglepanel');


set(aperturepanel,'Visible',all_features_visible)
set(lightpanel,'Visible',all_features_visible)
set(anglepanel,'Visible',all_features_visible)


function find_devices
hgui = getappdata(0,'hgui');
serpo=getappdata(hgui,'serpo');
try
	serpo.Port; %is there no other way to determine if serialport is working...?
	%configureTerminator(serpo,'CR/LF');
	alreadyconnected=1;
catch
	alreadyconnected=0;
	delete(serpo)
end
if alreadyconnected==1
	flush(serpo)
	writeline(serpo,'WhatIsTheAngle?');
	warning off
	serial_answer=readline(serpo);
	warning on
	handles=gethand;
	lens_available=strfind(serial_answer,'Measured_Roll:');
	if ~isempty(lens_available) &&  lens_available~=0
		set(handles.lens_status, 'Backgroundcolor',[0 1 0])
		set(handles.lens_status, 'String','OK')
	end
end

function angle_measure_Callback (inpt,~)
if inpt.Value == 1 %on
	t = timer;
	t.Tag='lens_timer';
	t.StartDelay = 0.1;
	t.ExecutionMode = 'fixedRate';
	t.Period = 0.5;
	t.TimerFcn = @lens_timer_tick_fcn;
	start(t)
	setappdata(0,'handle_to_lens_timer_checkbox',inpt);
else
	stop(timerfind)
	delete(timerfind)
end

function lens_timer_tick_fcn(~,~)
hgui = getappdata(0,'hgui');
serpo=getappdata(hgui,'serpo');
try
	serpo.Port; %is there no other way to determine if serialport is working...?
	alreadyconnected=1;
catch
	alreadyconnected=0;
	delete(serpo)
end
if alreadyconnected==1
	flush(serpo)
	writeline(serpo,'WhatIsTheAngle?');
	warning off
	serial_answer=readline(serpo);
	warning on
	handles=gethand;
	if ~isempty (serial_answer) & strfind(serial_answer,'Measured_Roll:')==1
		Roll=serial_answer{1}(strfind(serial_answer,'Measured_Roll:')+14:strfind(serial_answer,char(9))-1);
		Pitch=serial_answer{1}(strfind(serial_answer,'Measured_Pitch:')+15:end);
		Roll=str2double(Roll)/100+retr('Roll_Offset');
		Pitch=str2double(Pitch)/100+retr('Pitch_Offset');
		set(handles.pitch,'String',['P: ' num2str(Pitch)])
		set(handles.roll,'String',['R: ' num2str(Roll)])
	else
		set(handles.pitch,'String','No reply')
		set(handles.roll,'String','No reply')
	end
end

function configu_Callback (inpt,~)
load ('PIVlab_capture_lensconfig.mat','lens_configurations');
focus_servo_lower_limit = lens_configurations{1,inpt.Value};
focus_servo_upper_limit = lens_configurations{2,inpt.Value};
aperture_servo_lower_limit = lens_configurations{3,inpt.Value};
aperture_servo_upper_limit = lens_configurations{4,inpt.Value};
Pitch_Offset = lens_configurations{5,inpt.Value};
Roll_Offset = lens_configurations{6,inpt.Value};

put('focus_servo_lower_limit',focus_servo_lower_limit)
put('focus_servo_upper_limit',focus_servo_upper_limit)
put('aperture_servo_lower_limit',aperture_servo_lower_limit)
put('aperture_servo_upper_limit',aperture_servo_upper_limit)
put('Pitch_Offset',Pitch_Offset)
put('Roll_Offset',Roll_Offset)

put('selected_lens_config',inpt.Value)
selected_lens_config_nr=inpt.Value;
save ('PIVlab_capture_resources\PIVlab_capture_lensconfig.mat','lens_configurations','selected_lens_config_nr');

handles=gethand;
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
set (handles.aperture_edit,'String',num2str(aperture))
set (handles.focus_edit,'String',num2str(focus))
set (handles.light_edit,'String',num2str(lighting))
%focus_edit_Callback(handles.aperture_edit,[])
%pause(0.2)
%aperture_edit_Callback(handles.focus_edit,[])
if selected_lens_config_nr ~=4
	all_features_visible='on';
else
	all_features_visible='off';
end
put ('all_features_visible',all_features_visible);
limit_displayed_features



function focus_set (~,~,inpt)

focus_step=100;
[focus,aperture,lighting]=get_lens_status;
if strmatch(inpt,'auto')
	put('sharpness_enabled',0);
	put('hist_enabled',0);
	if retr('capturing')==1 %camera is recording
		if retr('autofocus_enabled') == 1 %user pressed button while autofocus is running: Stop autofocus.
			put('autofocus_enabled',0); %toggles the autofocus_enabled variable. That is checked in PIVlab_capture_pco after each frame capture
		else
			put('autofocus_enabled',1);
		end
		%move to lower limit
		PIVlab_capture_lensctrl (retr('focus_servo_lower_limit'), retr('aperture'),retr('lighting'))
	else
		put('autofocus_enabled',0);
	end
end

if strmatch(inpt,'far')
	if focus>=retr('focus_servo_lower_limit')+focus_step
		focus=focus-focus_step;
	else
		focus=retr('focus_servo_lower_limit');
	end
	PIVlab_capture_lensctrl (focus, aperture,lighting)
end
if strmatch(inpt,'near')
	if focus<=retr('focus_servo_upper_limit')-focus_step
		focus=focus+focus_step;
	else
		focus=retr('focus_servo_upper_limit');
	end
	PIVlab_capture_lensctrl (focus, aperture,lighting)
end
%put('focus',focus);

update_edit_fields

function [focus,aperture,lighting]=get_lens_status
try %try to switch of camera angle report
	stop(timerfind)
	delete(timerfind)
	set(getappdata(0,'handle_to_lens_timer_checkbox'),'Value',0)
catch
end
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
aperture_step=100;
if strmatch(inpt,'open')
	if aperture>=retr('aperture_servo_lower_limit')+aperture_step
		aperture=aperture-aperture_step;
	else
		aperture=retr('aperture_servo_lower_limit');
	end
end
if strmatch(inpt,'close')
	if aperture<=retr('aperture_servo_upper_limit')-aperture_step
		aperture=aperture+aperture_step;
	else
		aperture=retr('aperture_servo_upper_limit');
	end
end
%put('aperture',aperture);
PIVlab_capture_lensctrl (focus, aperture,lighting)
update_edit_fields


function aperture_edit_Callback(caller,~)
[focus,~,lighting]=get_lens_status;
aperture=str2double(caller.String);
if aperture > retr('aperture_servo_upper_limit')
	aperture =retr('aperture_servo_upper_limit');
end
if aperture < retr('aperture_servo_lower_limit')
	aperture =retr('aperture_servo_lower_limit');
end
caller.String=num2str(aperture);
%put('aperture',aperture);
PIVlab_capture_lensctrl (focus, aperture,lighting)

function focus_edit_Callback(caller,~)
[~,aperture,lighting]=get_lens_status;
focus=str2double(caller.String);
if focus > retr('focus_servo_upper_limit')
	focus =retr('focus_servo_upper_limit');
end
if focus< retr('focus_servo_lower_limit')
	focus =retr('focus_servo_lower_limit');
end
caller.String=num2str(focus);
%put('focus',focus);
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
%put('lighting',lighting);
PIVlab_capture_lensctrl (focus, aperture,lighting)
update_edit_fields


function put(name, what)
hgui=getappdata(0,'hgui');
setappdata(hgui, name, what);

function var = retr(name)
hgui=getappdata(0,'hgui');
var=getappdata(hgui, name);

function handles=gethand
hlens=getappdata(0,'hlens');
handles=guihandles(hlens);

function CloseRequestFcn(hObject, ~, ~)
try
	stop(timerfind)
	delete(timerfind)
catch
end
try
	delete(hObject);
catch
	delete(gcf);
end
put('autofocus_enabled',0);

