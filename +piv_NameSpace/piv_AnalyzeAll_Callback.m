function piv_AnalyzeAll_Callback(~, ~, ~)
handles=gui_NameSpace.gui_gethand;
if get(handles.ensemble,'value')==0
	piv_NameSpace.piv_DCC_and_DFT_analyze_all
else
	piv_NameSpace.piv_ensemble_piv_analyze_all
end
