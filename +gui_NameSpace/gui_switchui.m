function gui_switchui (who)
handles=guihandles(getappdata(0,'hgui')); %#ok<*NASGU>

if get(handles.zoomon,'Value')==1
	set(handles.zoomon,'Value',0);
	gui_NameSpace.gui_zoomon_Callback(handles.zoomon)
end
if get(handles.panon,'Value')==1
	set(handles.panon,'Value',0);
	gui_NameSpace.gui_panon_Callback(handles.panon)
end

turnoff=findobj('-regexp','Tag','multip');
set(turnoff, 'visible', 'off');
turnon=findobj('-regexp','Tag',who);
set(turnon, 'visible', 'on');

if strcmp(who,'multip25') %mask panel is active --> enable mask editing
	set(handles.mask_edit_mode,'Value',1)
	gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'));
else
	set(handles.mask_edit_mode,'Value',2)
end


drawnow;
