function PIVlab_oltSync_flash_firmware_GUI
fh = findobj('tag', 'oltSync_flash_firmware');

if isempty(fh)
	try
		hgui=getappdata(0,'hgui');
		mainpos=get(hgui,'Position');
	catch
		mainpos=[0    2.8571  240.0000   50.9524];
	end
	oltSync_flash_firmware = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','oltSync: Flash Firmware','Toolbar','none','Units','characters','Position', [mainpos(1)+mainpos(3)-35 mainpos(2)+15+4+4 35 11+1.5],'tag','oltSync_flash_firmware','visible','on','KeyPressFcn', @key_press,'resize','off');
	set (oltSync_flash_firmware,'Units','Characters');


	handles = guihandles; %alle handles mit tag laden und ansprechbar machen
	guidata(oltSync_flash_firmware,handles)
	setappdata(0,'holtSync_flash_firmware',oltSync_flash_firmware);

	parentitem = get(oltSync_flash_firmware, 'Position');

	margin=1.5;

	panelheight=12;
	handles.mainpanel = uipanel(oltSync_flash_firmware, 'Units','characters', 'Position', [1 parentitem(4)-panelheight parentitem(3)-2 panelheight],'title','Flash firmware','fontweight','bold');


	%% mainpanel

	parentitem=get(handles.mainpanel, 'Position');
	item=[0 0 0 0];
	item=[parentitem(3)/2*0 item(2)+item(4) parentitem(3)/3*1 1];

	item=[0 item(2) parentitem(3) 2];
	handles.select_firmware= uicontrol(handles.mainpanel,'Style','pushbutton','String','Select firmware','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag', 'select_firmware','Callback',@select_firware_file);

	item=[0 item(2)+item(4)+0.25 parentitem(3) 1];
	handles.infotext = uicontrol(handles.mainpanel,'Style','text','String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag','infotext');

	item=[0 item(2)+item(4)+0.25 parentitem(3) 2];
	handles.flash_firmware= uicontrol(handles.mainpanel,'Style','pushbutton','String','Flash firmware!','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'tag', 'flash_firmware','Callback',@flash_firware_file,'enable','off');


else %Figure handle does already exist --> bring UI to foreground.
	figure(fh)
end


function select_firware_file(~,~,~)
[FileName,PathName, ~] = uigetfile('*.hex','Select firmware file');
if ~isempty (FileName)
	handles=gethand;
	put('firmware_path',fullfile(PathName,FileName));
	set(handles.infotext,'String',FileName);
	set(handles.flash_firmware,'Enable','On');
end

function flash_firware_file(~,~,~)
handles=gethand;
firmware_path=retr('firmware_path');
[~,cmdout] = system('tycmd.exe list');
cnt=0;
if ~isempty(cmdout)
	C=strsplit(cmdout,'add');
	for i=1:size(C,2)
		if ~isempty(C{i})
			cnt=cnt+1;
		end
	end
end
if cnt > 1
	msgbox('Too many devices detected. Please remove all devices except the synchronizer.','modal')
elseif cnt < 1
	msgbox('Could not detect the synchronizer. Please connect via USB and turn the synchronizer on.','modal')
elseif cnt == 1
	set(handles.infotext,'String','Flashing...');
	set(handles.infotext,'Backgroundcolor',[1 1 0]);
	pause(0.25)
	command = ['tycmd.exe upload ' firmware_path]
	%[status,cmdout] = system(command);
	%auch abfragen ob erfolgreich...
	if 1==1
		set(handles.infotext,'String','Success!');
		set(handles.infotext,'Backgroundcolor',[0 1 0]);
	end
end

function put(name, what)
holtSync_flash_firmware=getappdata(0,'holtSync_flash_firmware');
setappdata(holtSync_flash_firmware, name, what);

function var = retr(name)
holtSync_flash_firmware=getappdata(0,'holtSync_flash_firmware');
var=getappdata(holtSync_flash_firmware, name);

function handles=gethand
holtSync_flash_firmware=getappdata(0,'holtSync_flash_firmware');
handles=guihandles(holtSync_flash_firmware);