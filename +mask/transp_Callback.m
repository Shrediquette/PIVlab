function transp_Callback(~, ~, ~)
handles=gui.gethand;
try
	if isempty(str2num(get(handles.masktransp,'String'))) == 1
		set(handles.masktransp,'String','0');
	end
catch
	set(handles.masktransp,'String','0');
end
misc.check_comma(handles.masktransp)
set(handles.masktransp,'String',round(str2num(get(handles.masktransp,'String'))))
if str2num(get(handles.masktransp,'String')) > 100
	set(handles.masktransp,'String','100');
end
if str2num(get(handles.masktransp,'String')) < 0
	set(handles.masktransp,'String','0');
end

