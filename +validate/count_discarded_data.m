function count_discarded_data (~,~,~)
handles=gui.gethand;
resultslist=gui.retr('resultslist');
currentframe=2*floor(get(handles.fileselector, 'value'))-1;
if ~isempty(resultslist)
	if size(resultslist,2) >= ((currentframe+1)/2)
		typevector=resultslist{9,(currentframe+1)/2};
		nan_amount=numel(typevector(typevector==2));
		firstpeak_valid_amount=numel(typevector(typevector==1));
		secondpeakamount = numel(typevector(typevector==3));
		total_valid_amount=firstpeak_valid_amount+secondpeakamount;
		total_amount=total_valid_amount + nan_amount;
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
set (handles.amount_nans,'string',['Valid detection probability (VDP): ' num2str(round(100-nan_percent,1)) ' %'])
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

% Update vector color legend swatches (both validation panels) to reflect
% the currently active display settings from "Modify plot appearance".
if isfield(handles,'veccolor_valid_swatch') || isfield(handles,'veccolor_valid_swatch2')
	colors_cell = gui.vec_preset_colors();
	displaywhat = gui.retr('displaywhat');
	derived     = gui.retr('derived');
	if ~isempty(derived) && ~isempty(displaywhat) && displaywhat > 1 && ...
			size(derived,2) >= (currentframe+1)/2 && ...
			numel(derived{displaywhat-1,(currentframe+1)/2}) > 0
		validcolor = colors_cell{get(handles.deriv_color,  'Value'), 2};
	else
		validcolor = colors_cell{get(handles.valid_color,  'Value'), 2};
	end
	interpcolor     = colors_cell{get(handles.interp_color,     'Value'), 2};
	secondpeakcolor = colors_cell{get(handles.secondpeak_color, 'Value'), 2};
	if isfield(handles,'veccolor_valid_swatch')
		set(handles.veccolor_valid_swatch,      'BackgroundColor', validcolor);
		set(handles.veccolor_interp_swatch,     'BackgroundColor', interpcolor);
		set(handles.veccolor_secondpeak_swatch, 'BackgroundColor', secondpeakcolor);
	end
	if isfield(handles,'veccolor_valid_swatch2')
		set(handles.veccolor_valid_swatch2,      'BackgroundColor', validcolor);
		set(handles.veccolor_interp_swatch2,     'BackgroundColor', interpcolor);
		set(handles.veccolor_secondpeak_swatch2, 'BackgroundColor', secondpeakcolor);
	end
	%calculate the percentage of 2ndpeak vectors
	secondpeakstring=['Valid vectors (2nd peak): ' num2str(secondpeakamount)];
	totalvalidstring=['Valid vectors (1st peak): ' num2str(firstpeak_valid_amount)];
	rejectedstring=['Rejected / interpolated: ' num2str(nan_amount)];
	handles.secondpeaktxt1.String = secondpeakstring;
	handles.secondpeaktxt2.String = secondpeakstring;
	handles.validtxt1.String = totalvalidstring;
	handles.validtxt2.String = totalvalidstring;
	handles.rejectedtxt1.String = rejectedstring;
	handles.rejectedtxt2.String = rejectedstring;
end