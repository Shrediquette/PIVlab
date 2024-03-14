function piv_AnalyzeAll_Callback(~, ~, ~)
handles=gui.gui_gethand;
if get(handles.ensemble,'value')==0
	piv.piv_DCC_and_DFT_analyze_all
else
	piv.piv_ensemble_piv_analyze_all
end

