function count_discarded_data (~,~,~)
handles=gui.gethand;
resultslist=gui.retr('resultslist');
currentframe=2*floor(get(handles.fileselector, 'value'))-1;
if ~isempty(resultslist)
	if size(resultslist,2) >= ((currentframe+1)/2)
		typevector=resultslist{9,(currentframe+1)/2};
		nan_amount=numel(typevector(typevector==2));
		total_amount=numel(typevector(typevector==1)) + nan_amount;
		nan_percent=nan_amount/total_amount*100;
	else
		nan_percent=0;
	end
else
	nan_percent=0;
end
if isnan(nan_percent)
	nan_percent=0;
end
set (handles.amount_nans,'string',['VDP: ' num2str(round(100-nan_percent,1)) ' %'])
if gui.retr('darkmode')
	r_bg=[0.5 0 0];
	g_bg=[0 0.5 0];
	y_bg=[0.5 0.5 0];
else
	r_bg=[1 0 0];
	g_bg=[0 1 0];
	y_bg=[1 1 0];
end

if nan_percent <= 5
	set (handles.amount_nans, 'BackgroundColor',g_bg)
elseif nan_percent > 5 && nan_percent <= 25
	set (handles.amount_nans, 'BackgroundColor',y_bg)
elseif nan_percent > 25
	set (handles.amount_nans, 'BackgroundColor',r_bg)
end