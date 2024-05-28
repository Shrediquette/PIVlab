function mean_u_Callback(~, ~, ~)
handles=gui.gui_gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=gui.gui_retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0 %analysis exists
	if size(resultslist,1)>6 && numel(resultslist{7,currentframe})>0 %filtered exists
		u=resultslist{7,currentframe};
	else
		u=resultslist{3,currentframe};
	end
	calu=gui.gui_retr('calu');calv=gui.gui_retr('calv');
	set(handles.subtr_u, 'string', num2str(mean(u(:)*calu,'omitnan')));
else
	set(handles.subtr_u, 'string', '0');
end

