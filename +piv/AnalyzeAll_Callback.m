function AnalyzeAll_Callback(~, ~, ~)
handles=gui.gethand;
if get(handles.ensemble,'value')==0
	piv.DCC_and_DFT_analyze_all
else
	piv.ensemble_piv_analyze_all
end

