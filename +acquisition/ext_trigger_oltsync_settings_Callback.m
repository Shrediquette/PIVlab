function ext_trigger_oltsync_settings_Callback (~,~,~)
serpo=gui.retr('serpo');
if ~isempty(serpo)
	if strcmpi(gui.retr('sync_type'),'oltSync')
		oltSync_GUI
	end
end

function oltSync_GUI
fh = findobj('tag', 'oltSync_GUI_window');
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

	oltSync_GUI_window = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','Trigger settings','Toolbar','none','Units','characters','Position', [mainpos(1)+mainpos(3)-35 mainpos(2)+15+4+4 35 10],'tag','oltSync_GUI_window','visible','on','resize','off');
	set (oltSync_GUI_window,'Units','Characters');

	handles = guihandles; %alle handles mit tag laden und ansprechbar machen
	guidata(oltSync_GUI_window,handles)
	setappdata(0,'holtSync_GUI',oltSync_GUI_window);

	parentitem = get(oltSync_GUI_window, 'Position');

	margin=1.5;

	panelheight=9.5;
	handles.mainpanel = uipanel(oltSync_GUI_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight parentitem(3)-2 panelheight],'title','Trigger mode','fontweight','bold');

	%% mainpanel
	parentitem=get(handles.mainpanel, 'Position');
	item=[0 0 0 0];

	item=[item(1) item(2)+item(4) parentitem(3) 1];
	handles.triggermode = uicontrol(handles.mainpanel,'Style','popupmenu','String',{'Internal','External: Shoot while high', 'External: Double shot on rising edge'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','triggermode','Callback',@Apply_settings);

	item=[0 item(2)+item(4)+margin/2 parentitem(3) 6];
	handles.explain = uicontrol(handles.mainpanel,'Style','Text','String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin*0.1 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.1 item(4)],'tag','explain','fontsize',7);

	triggermode=retr('oltSync_triggermode');
	if isempty(triggermode)
		triggermode='internal';
		put('oltSync_triggermode',triggermode)
	end
	if strcmpi(triggermode,'internal')
		set (handles.triggermode,'Value',1)
		set (handles.explain,'String', {'Uses the configured camera and pulse timings, and starts recording when ''Start'' button is clicked, stops when ''image amount'' is reached.'})
	elseif strcmpi(triggermode,'activehigh')
		set (handles.triggermode,'Value',2)
		set (handles.explain,'String', {'Uses the configured camera and pulse timings, arms when ''Start'' button is clicked, records when the trigger input is high, stops when ''image amount'' is reached.'})
	elseif strcmpi(triggermode,'singlerising')
		set (handles.triggermode,'Value',3)
		set (handles.explain,'String', {'Uses the configured camera and pulse timings, arms when ''Start'' button is clicked, records one double image each time trigger goes high, stops when ''image amount'' is reached.'})
	end
else %Figure handle does already exist --> bring UI to foreground.
	figure(fh)
end

function Apply_settings(~,~,~)
handles=gethand;
value=get(handles.triggermode,'Value');
set (handles.explain,'String', {'Uses the configured camera and pulse timings, and starts recording when ''Start'' button is clicked, stops when ''image amount'' is reached.'})
if value==1
	put('oltSync_triggermode','internal')
elseif value==2
	put('oltSync_triggermode','activehigh')
	set (handles.explain,'String', {'Uses the configured camera and pulse timings, arms when ''Start'' button is clicked, records when the trigger input is high, stops when ''image amount'' is reached.'})
elseif value==3
	put('oltSync_triggermode','singlerising')
	set (handles.explain,'String', {'Uses the configured camera and pulse timings, arms when ''Start'' button is clicked, records one double image each time trigger goes high, stops when ''image amount'' is reached.'})
end

function put(name, what)
hgui=getappdata(0,'hgui');
setappdata(hgui, name, what);

function var = retr(name)
hgui=getappdata(0,'hgui');
var=getappdata(hgui, name);

function handles=gethand
holtSync_GUI=getappdata(0,'holtSync_GUI');
handles=guihandles(holtSync_GUI);