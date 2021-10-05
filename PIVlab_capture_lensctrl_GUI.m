function PIVlab_capture_lensctrl_GUI
[focus,aperture,lighting]=get_lens_status;
lens_control_window = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','Lens control','Toolbar','none','Units','characters','Position',[3 5 35 15],'tag','lens_control_window','visible','on','KeyPressFcn', @key_press,'resize','off');
set (lens_control_window,'Units','Characters');




handles = guihandles; %alle handles mit tag laden und ansprechbar machen
guidata(lens_control_window,handles)
setappdata(0,'hlens',lens_control_window);

parentitem = get(lens_control_window, 'Position');

margin=1.5;

panelheight=5;
handles.aperturepanel = uipanel(lens_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight parentitem(3)-2 panelheight],'title','Aperture control','fontweight','bold');
handles.focuspanel = uipanel(lens_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight*2 parentitem(3)-2 panelheight],'title','Focus control','fontweight','bold');
handles.lightpanel = uipanel(lens_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight*3 parentitem(3)-2 panelheight],'title','Light control','fontweight','bold');

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


function focus_set (~,~,inpt)
[focus,aperture,lighting]=get_lens_status;
if strmatch(inpt,'auto')
	if retr('capturing')==1
		autofocus_enabled=retr('autofocus_enabled');
		if isempty(autofocus_enabled)
			autofocus_enabled=0;
		end
		put('autofocus_enabled',1-autofocus_enabled);
		if retr('autofocus_enabled')==1 % only autofocs OR sharpness display must be enabled at a time
			put('sharpness_enabled',0);
		end
	else
		put('sharpness_enabled',0);
		put('autofocus_enabled',0);
	end
end

if strmatch(inpt,'near')
	if focus>500
		focus=focus-100;
	end
end
if strmatch(inpt,'far')
	if focus<2500
		focus=focus+100;
	end
end
PIVlab_capture_lensctrl (focus, aperture,lighting)
update_edit_fields

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


function put(name, what)
hgui=getappdata(0,'hgui');
setappdata(hgui, name, what);

function var = retr(name)
hgui=getappdata(0,'hgui');
var=getappdata(hgui, name);

function handles=gethand
hlens=getappdata(0,'hlens');
handles=guihandles(hlens);
