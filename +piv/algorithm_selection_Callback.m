function algorithm_selection_Callback(hObject, ~, ~)
handles=gui.gethand;
selection=get(hObject,'Value');
if selection ==1 % piv fft multi
	set(handles.uipanel42,'visible','on')
	set(handles.uipanel41,'visible','on')
	set(handles.CorrQuality,'visible','on')
	set(handles.text914,'visible','on')
	set(handles.mask_auto_box,'visible','on')
	%set(handles.AnalyzeAll,'visible','on')
	set(handles.AnalyzeSingle,'visible','on')
	set(handles.Settings_Apply_current,'visible','on')
	set(handles.text14,'visible','on')
	set(handles.subpix,'visible','on')
	set(handles.uipanel_ofv1,'visible','off')
	set(handles.textSuggest,'visible','on')
	set(handles.SuggestSettings,'visible','on')
	if get(handles.checkbox26,'value') ~=0
		set(handles.repeat_last,'Enable','on')
		set(handles.edit52x,'Enable','on')
	end
	piv.dispinterrog
end
if selection ==2 % ensemble
	set(handles.uipanel42,'visible','on')
	set(handles.uipanel41,'visible','on')
	set(handles.CorrQuality,'visible','on')
	set(handles.text914,'visible','on')
	set(handles.mask_auto_box,'visible','on')
	set(handles.repeat_last,'Value',0)
	set(handles.repeat_last,'Enable','off')
	set(handles.edit52x,'Enable','off')
	%set(handles.AnalyzeAll,'visible','off')
	set(handles.AnalyzeSingle,'visible','off')
	set(handles.Settings_Apply_current,'visible','off')
	set(handles.text14,'visible','on')
	set(handles.subpix,'visible','on')
	set(handles.uipanel_ofv1,'visible','off')
	set(handles.textSuggest,'visible','on')
	set(handles.SuggestSettings,'visible','on')
	piv.dispinterrog
end
if selection==3 % DCC
	set(handles.uipanel42,'visible','off')
	set(handles.uipanel41,'visible','on')
	set(handles.CorrQuality,'visible','off')
	set(handles.text914,'visible','off')
	set(handles.mask_auto_box,'visible','off')
	%set(handles.AnalyzeAll,'visible','on')
	set(handles.AnalyzeSingle,'visible','on')
	set(handles.Settings_Apply_current,'visible','on')
	set(handles.text14,'visible','on')
	set(handles.subpix,'visible','on')
	set(handles.uipanel_ofv1,'visible','off')
	set(handles.textSuggest,'visible','on')
	set(handles.SuggestSettings,'visible','on')
	piv.dispinterrog
end
if selection ==4 %wOFV
	set(handles.uipanel_ofv1,'visible','on')
	set(handles.uipanel42,'visible','off')
	set(handles.uipanel41,'visible','off')
	set(handles.CorrQuality,'visible','off')
	set(handles.text914,'visible','off')
	set(handles.mask_auto_box,'visible','off')
	%set(handles.AnalyzeAll,'visible','on')
	set(handles.AnalyzeSingle,'visible','on')
	set(handles.Settings_Apply_current,'visible','on')
	set(handles.text14,'visible','off')
	set(handles.subpix,'visible','off')
	set(handles.textSuggest,'visible','off')
	set(handles.SuggestSettings,'visible','on')
	delete (findobj('tag','intareadispl'))%do not display visuals about interrogation area
end
%suggestion to reduce vector display density
current_vector_setting=get(handles.nthvect,'String');
if selection ==4 %wOFV
	if ~strcmp(current_vector_setting,'5')
		ans_w=questdlg(['wOFV results in one vector per pixel. Displaying all vectors is not recommended.' newline newline 'Should I reduce the vector display density for you?' newline newline 'You can manually change this by going to Plot -> Modify plot appearance -> plot every nth vector'],'Vector display density','Yes','No','Yes');
		if strcmp(ans_w,'Yes')
			set(handles.nthvect,'String',5)
		end
	end
else
	if ~strcmp(current_vector_setting,'1')
		ans_w=questdlg(['You are currently not plotting every calculated vector.' newline newline 'Should I apply the standard vector display setting for you?' newline newline 'You can manually change this by going to Plot -> Modify plot appearance -> plot every nth vector'],'Vector display density','Yes','No','Yes');
		if strcmp(ans_w,'Yes')
			set(handles.nthvect,'String',1)
		end
	end
end