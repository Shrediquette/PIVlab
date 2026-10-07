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
	delete(findobj(pivlab_axis,'tag','busyhint'));
end

if exist('busy_msg','var') && ~isempty(busy_msg)
	%additionally display banner that PIVlab is busy
	if inpt==0
		postix=get(pivlab_axis,'XLim');postiy=get(pivlab_axis,'YLim');
		if verLessThan('matlab','25')
			text(pivlab_axis,postix(2)/2,postiy(2)/2,busy_msg,'HorizontalAlignment','center','VerticalAlignment','middle','color','y','fontsize',32, 'BackgroundColor', [0.25 0.25 0.25],'tag','busyhint','margin',30,'Clipping','on');
		else
			rectangle(pivlab_axis,'Position',[postix(2)/4*1,postiy(2)/4*1,postix(2)/2,postiy(2)/2],'Curvature',0.33,'FaceColor',[0.15 0.15 0.4],'FaceAlpha',0.5,'LineStyle','none','Tag','busyhint')
			text(pivlab_axis,postix(2)/2,postiy(2)/2,busy_msg,'HorizontalAlignment','center','VerticalAlignment','middle','color','y','fontsize',32, 'BackgroundColor', 'none','tag','busyhint','margin',30,'Clipping','on');
		end
	end
end
elementsOfCrime=findobj(hgui, 'type', 'uicontrol');
elementsOfCrime2=findobj(hgui, 'type', 'uimenu');
if inpt==0
	% remember which controls were disabled before (by handle: controls may be created or
	% deleted while PIVlab is busy). Only kept in memory, never saved in a session.
	was_disabled=false(numel(elementsOfCrime),1);
	for i=1:numel(elementsOfCrime)
		was_disabled(i)=strcmp(elementsOfCrime(i).Enable,'off');
	end
	gui.put('disabled_while_busy', elementsOfCrime(was_disabled));
	set(elementsOfCrime, 'enable', 'off');
	set(elementsOfCrime2, 'enable', 'off');
else
	set(elementsOfCrime, 'enable', 'on');
	disabled_while_busy=gui.retr('disabled_while_busy');
	if ~isempty(disabled_while_busy)
		set(disabled_while_busy(isvalid(disabled_while_busy)), 'enable', 'off');
	end
	set(elementsOfCrime2, 'enable', 'on');
end
set(handles.progress, 'enable', 'on');
set(handles.overall, 'enable', 'on');
set(handles.totaltime, 'enable', 'on');
set(handles.messagetext, 'enable', 'on');
