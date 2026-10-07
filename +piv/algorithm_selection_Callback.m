function algorithm_selection_Callback(hObject, ~, ~)
handles=gui.gethand;
selection=get(hObject,'Value');
batchModeActive=gui.retr('batchModeActive');
if isempty (batchModeActive)
	batchModeActive = 0;
end
if selection ==2 % ensemble: no repeated last pass
	set(handles.repeat_last_enable,'Value',0)
end
gui.update_dependent_controls(handles)
if selection ==4 %wOFV
	delete (findobj('tag','intareadispl'))%do not display visuals about interrogation area
else
	piv.dispinterrog
end
%suggestion to reduce vector display density
current_vector_setting=get(handles.nthvect,'String');
if selection ==4 %wOFV
	if ~strcmp(current_vector_setting,'5') && ~batchModeActive
		ans_w = gui.custom_msgbox('quest',getappdata(0,'hgui'),'Vector display density',['wOFV results in one vector per pixel. Displaying all vectors is not recommended.' newline newline 'Should I reduce the vector display density for you?' newline newline 'You can manually change this by going to Plot -> Modify plot appearance -> plot every nth vector'],'modal',{'Yes','No'},'Yes');
		if strcmp(ans_w,'Yes')
			set(handles.nthvect,'String',5)
		end
	end
else
	if ~strcmp(current_vector_setting,'1') && ~batchModeActive
		ans_w = gui.custom_msgbox('quest',getappdata(0,'hgui'),'Vector display density',['You are currently not plotting every calculated vector.' newline newline 'Should I apply the standard vector display setting for you?' newline newline 'You can manually change this by going to Plot -> Modify plot appearance -> plot every nth vector'],'modal',{'Yes','No'},'Yes');
		if strcmp(ans_w,'Yes')
			set(handles.nthvect,'String',1)
		end
	end
end
