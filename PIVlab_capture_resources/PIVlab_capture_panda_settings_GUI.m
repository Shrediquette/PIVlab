function PIVlab_capture_panda_settings_GUI
fh = findobj('tag', 'panda_control_window');
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

	panda_control_window = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','pco.panda/pco.edge settings','Toolbar','none','Units','characters','Position', [mainpos(1)+mainpos(3)-35 mainpos(2)+15+4+4 35 11+1.5],'tag','panda_control_window','visible','on','KeyPressFcn', @key_press,'resize','off');
	set (panda_control_window,'Units','Characters');


	handles = guihandles; %alle handles mit tag laden und ansprechbar machen
	guidata(panda_control_window,handles)
	setappdata(0,'hpandacam',panda_control_window);

	parentitem = get(panda_control_window, 'Position');

	margin=1.5;

	panelheight=12;
	handles.mainpanel = uipanel(panda_control_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight parentitem(3)-2 panelheight],'title','panda and edge Settings','fontweight','bold');


	%% mainpanel
	parentitem=get(handles.mainpanel, 'Position');
	item=[0 0 0 0];

	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1];
	handles.timestamp_txt = uicontrol(handles.mainpanel,'Style','text','String','Time stamp:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2 1.5];
	handles.timestamp = uicontrol(handles.mainpanel,'Style','popupmenu','String',{'none','ASCII','binary','both'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','timestamp');


    item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/2 1];
	handles.filetype_txt = uicontrol(handles.mainpanel,'Style','text','String','File type:','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

	item=[parentitem(3)/2*1 item(2) parentitem(3)/2 1.5];
	handles.filetype = uicontrol(handles.mainpanel,'Style','popupmenu','String',{'Single TIFF','Multi TIFF', 'Computer RAM -> single TIFF files'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','filetype');
    
    item=[parentitem(3)/2 item(2)+item(4)+margin parentitem(3)/2 2];
	handles.apply_btn = uicontrol(handles.mainpanel,'Style','pushbutton','String','Apply','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@Apply_settings,'tag','apply_btn');

else %Figure handle does already exist --> bring UI to foreground.
	figure(fh)
end
handles=gethand;
panda_timestamp=getappdata(hgui,'panda_timestamp');
if isempty (panda_timestamp)
	panda_timestamp='none';
end
if strcmp(panda_timestamp,'none')
	set(handles.timestamp,'value',1);
elseif strcmp(panda_timestamp,'ASCII')
	set(handles.timestamp,'value',2);
elseif strcmp(panda_timestamp,'binary')
	set(handles.timestamp,'value',3);
end

panda_filetype=getappdata(hgui,'panda_filetype');
if isempty (panda_filetype)
	panda_filetype='Single TIFF';
end
if strcmp(panda_filetype,'Single TIFF')
	set(handles.filetype,'value',1);
elseif strcmp(panda_filetype,'Multi TIFF')
	set(handles.filetype,'value',2);
elseif strcmp(panda_filetype,'Computer RAM -> single TIFF files')
	set(handles.filetype,'value',3);    
end



function Apply_settings(~,~,~)
fh = findobj('tag', 'panda_control_window');
handles=gethand;

timestamp=get(handles.timestamp,'String');
put('panda_timestamp',(timestamp{get(handles.timestamp,'value')}));

filetype=get(handles.filetype,'String');
put('panda_filetype',(filetype{get(handles.filetype,'value')}));

pause(0.01)


close (fh)


function put(name, what)
hgui=getappdata(0,'hgui');
setappdata(hgui, name, what);

function var = retr(name)
hgui=getappdata(0,'hgui');
var=getappdata(hgui, name);

function handles=gethand
hpandacam=getappdata(0,'hpandacam');
handles=guihandles(hpandacam);
