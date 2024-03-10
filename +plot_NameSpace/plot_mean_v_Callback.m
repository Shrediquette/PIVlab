function plot_mean_v_Callback(~, ~, ~)
handles=gui_NameSpace.gui_gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=gui_NameSpace.gui_retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0 %analysis exists
	if size(resultslist,1)>6 && numel(resultslist{7,currentframe})>0 %filtered exists
		v=resultslist{8,currentframe};
	else
		v=resultslist{4,currentframe};
	end
	calu=gui_NameSpace.gui_retr('calu');calv=gui_NameSpace.gui_retr('calv');
	set(handles.subtr_v, 'string', num2str(mean(v(:)*calv,'omitnan')));
else
	set(handles.subtr_v, 'string', '0');
end
