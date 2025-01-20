function ext_trigger_settings_Callback (~,~,~)
handles=gui.gethand;
serpo=gui.retr('serpo');
if ~isempty(serpo)
	if strcmpi(gui.retr('sync_type'),'xmSync')
		acquisition.control_simple_sync_serial(0,0);
		if get(handles.ac_enable_ext_trigger,'Value')==1 %execute only if checkbox was off before it was clicked.
			old_label=get(handles.ac_enable_ext_trigger,'String');
			set(handles.ac_enable_ext_trigger,'String','Acquiring...','Enable','off')
			drawnow;
			flush(serpo);pause(0.1)
			%configureTerminator(serpo,'CR');
			writeline(serpo,'TrigFreq?');
			pause(1.25);
			warning off
			%configureTerminator(serpo,'CR/LF');
			serial_answer=readline(serpo);
			warning on
			set(handles.ac_enable_ext_trigger,'String',old_label,'Enable','on');
			selectedtriggerdelay=gui.retr('selectedtriggerdelay');
			if isempty(selectedtriggerdelay)
				selectedtriggerdelay=100;
			end
			selectedtriggerskip=gui.retr('selectedtriggerskip');
			if isempty(selectedtriggerskip)
				selectedtriggerdelay=0;
			end
			prompt = {['Detected frequency on trigger input: ' num2str(serial_answer) ' Hz.' sprintf('\n\n') 'Trigger delay in µs (must be > 100):'],'Nr. of trigger signals to skip:'};
			dlgtitle = 'External Trigger Configuration';
			dims = [1 50];
			definput = {num2str(selectedtriggerdelay),num2str(selectedtriggerskip)};
			answer = inputdlg(prompt,dlgtitle,dims,definput);
			if ~isempty(answer)
				gui.put('selectedtriggerdelay',str2double(answer{1}));
				gui.put('selectedtriggerskip',str2double(answer{2}));
			end
		end
	elseif strcmpi(gui.retr('sync_type'),'oltSync')
		if get(handles.ac_enable_ext_trigger,'Value')==1
			oltSync_GUI
		else
			fh = findobj('tag', 'oltSync_GUI_window');
			close (fh)
			triggermode='internal';
			put('oltSync_triggermode',triggermode)
		end
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

	oltSync_GUI_window = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','Trigger settings','Toolbar','none','Units','characters','Position', [mainpos(1)+mainpos(3)-35 mainpos(2)+15+4+4 35 6],'tag','oltSync_GUI_window','visible','on','resize','off');
	set (oltSync_GUI_window,'Units','Characters');


	handles = guihandles; %alle handles mit tag laden und ansprechbar machen
	guidata(oltSync_GUI_window,handles)
	setappdata(0,'holtSync_GUI',oltSync_GUI_window);

	parentitem = get(oltSync_GUI_window, 'Position');

	margin=1.5;

	panelheight=5.5;
	handles.mainpanel = uipanel(oltSync_GUI_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight parentitem(3)-2 panelheight],'title','Trigger mode','fontweight','bold');


	%% mainpanel
	parentitem=get(handles.mainpanel, 'Position');
	item=[0 0 0 0];

	item=[item(1) item(2)+item(4) parentitem(3) 1];

	handles.triggermode = uicontrol(handles.mainpanel,'Style','popupmenu','String',{'Internal','External: Shoot while high', 'External: Double shot on rising edge'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','triggermode');


	item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 2];
	handles.apply_btn = uicontrol(handles.mainpanel,'Style','pushbutton','String','Apply','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@Apply_settings,'tag','apply_btn');

	triggermode=retr('oltSync_triggermode');
	if isempty(triggermode)
		triggermode='internal';
		put('oltSync_triggermode',triggermode)
	end

	if strcmpi(triggermode,'internal')
		set (handles.triggermode,'Value',1)
	elseif strcmpi(triggermode,'activehigh')
		set (handles.triggermode,'Value',2)
	elseif strcmpi(triggermode,'singlerising')
		set (handles.triggermode,'Value',3)
	end


else %Figure handle does already exist --> bring UI to foreground.
	figure(fh)
end

function Apply_settings(~,~,~)
handles=gethand;
mainhandles=gui.gethand;
value=get(handles.triggermode,'Value');
if value==1
	put('oltSync_triggermode','internal')
	set(mainhandles.ac_enable_ext_trigger,'Value',0)
elseif value==2
	put('oltSync_triggermode','activehigh')
	set(mainhandles.ac_enable_ext_trigger,'Value',1)
elseif value==3
	put('oltSync_triggermode','singlerising')
	set(mainhandles.ac_enable_ext_trigger,'Value',1)
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


