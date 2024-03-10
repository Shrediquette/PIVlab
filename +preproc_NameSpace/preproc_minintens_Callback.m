function preproc_minintens_Callback(hObject, ~, ~)
if str2num(get(hObject,'String'))<0
	set(hObject,'String',0);
end

if str2num(get(hObject,'String'))>1
	set(hObject,'String',0);
end
