function toolsavailable(inpt,busy_msg)
%0: disable all tools
%1: re-enable tools that were previously also enabled
hgui=getappdata(0,'hgui');
handles=gui.gethand;
pivlab_axis=gui.retr('pivlab_axis');
if inpt==0
	if get(handles.zoomon,'Value')==1
		set(handles.zoomon,'Value',0);
		gui.zoomon_Callback(handles.zoomon)
	end
	if get(handles.panon,'Value')==1
		set(handles.panon,'Value',0);
		gui.panon_Callback(handles.panon)
	end
end

if inpt==1
	delete(findobj('tag','busyhint'));
end

if exist('busy_msg','var') && ~isempty(busy_msg)
	%additionally display banner that PIVlab is busy
	if inpt==0
		postix=get(pivlab_axis,'XLim');postiy=get(pivlab_axis,'YLim');
		if verLessThan('matlab','25')
			text(postix(2)/2,postiy(2)/2,busy_msg,'HorizontalAlignment','center','VerticalAlignment','middle','color','y','fontsize',32, 'BackgroundColor', [0.25 0.25 0.25],'tag','busyhint','margin',30,'Clipping','on');
		else
			rectangle('Position',[postix(2)/4*1,postiy(2)/4*1,postix(2)/2,postiy(2)/2],'Curvature',0.33,'FaceColor',[0.15 0.15 0.4],'FaceAlpha',0.5,'LineStyle','none','Tag','busyhint')
			text(postix(2)/2,postiy(2)/2,busy_msg,'HorizontalAlignment','center','VerticalAlignment','middle','color','y','fontsize',32, 'BackgroundColor', 'none','tag','busyhint','margin',30,'Clipping','on');
		end
	end
end
elementsOfCrime=findobj(hgui, 'type', 'uicontrol');
elementsOfCrime2=findobj(hgui, 'type', 'uimenu');
statuscell=get (elementsOfCrime, 'enable');
wasdisabled=zeros(size(statuscell),'uint8');

if inpt==0
	set(elementsOfCrime, 'enable', 'off');
	for i=1:size(statuscell,1)
		if strncmp(statuscell{i,1}, 'off',3) ==1
			wasdisabled(i)=1;
		end
	end
	gui.put('wasdisabled', wasdisabled);
	set(elementsOfCrime2, 'enable', 'off');
else
	wasdisabled=gui.retr('wasdisabled');
	set(elementsOfCrime, 'enable', 'on');
	set(elementsOfCrime(wasdisabled==1), 'enable', 'off');
	set(elementsOfCrime2, 'enable', 'on');
end
set(handles.progress, 'enable', 'on');
set(handles.overall, 'enable', 'on');
set(handles.totaltime, 'enable', 'on');
set(handles.messagetext, 'enable', 'on');
