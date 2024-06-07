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
if nan_percent <= 5
	set (handles.amount_nans, 'BackgroundColor',[0 1 0])
elseif nan_percent > 5 && nan_percent <= 25
	set (handles.amount_nans, 'BackgroundColor',[1 1 0])
elseif nan_percent > 25
	set (handles.amount_nans, 'BackgroundColor',[1 0 0])
end

