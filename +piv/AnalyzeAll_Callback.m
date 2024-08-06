function AnalyzeAll_Callback(~, ~, ~)
handles=gui.gethand;
if get(handles.algorithm_selection,'value')==1 || get(handles.algorithm_selection,'value')==3
	piv.DCC_and_DFT_analyze_all
end
if get(handles.algorithm_selection,'value')==2
	piv.ensemble_piv_analyze_all
end
if get(handles.algorithm_selection,'value')==4 %optical flow
	disp('to be implemented later')
end
