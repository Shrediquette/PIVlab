function count_discarded_data (~,~,~)
handles=gui.gethand;
resultslist=gui.retr('resultslist');
currentframe=2*floor(get(handles.fileselector, 'value'))-1;
if ~isempty(resultslist)
	if size(resultslist,2) >= ((currentframe+1)/2)
		typevector=resultslist{9,(currentframe+1)/2};
		nan_amount=numel(typevector(typevector==2));
		total_amount=numel(typevector(typevector==1 | typevector==3)) + nan_amount;
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

% Update vector color legend swatches (both validation panels) to reflect
% the currently active display settings from "Modify plot appearance".
% The valid-vector color depends on whether a derived parameter (vorticity,
% TKE, …) is currently displayed; the interpolated color is always the same.
if isfield(handles,'veccolor_valid_swatch') || isfield(handles,'veccolor_valid_swatch2')
	displaywhat = gui.retr('displaywhat');
	derived     = gui.retr('derived');
	if ~isempty(derived) && ~isempty(displaywhat) && displaywhat > 1 && ...
			size(derived,2) >= (currentframe+1)/2 && ...
			numel(derived{displaywhat-1,(currentframe+1)/2}) > 0
		validcolor = [str2double(get(handles.validdr,'string')) ...
		              str2double(get(handles.validdg,'string')) ...
		              str2double(get(handles.validdb,'string'))];
	else
		validcolor = [str2double(get(handles.validr,'string')) ...
		              str2double(get(handles.validg,'string')) ...
		              str2double(get(handles.validb,'string'))];
	end
	interpcolor = [str2double(get(handles.interpr,'string')) ...
	               str2double(get(handles.interpg,'string')) ...
	               str2double(get(handles.interpb,'string'))];
	if isfield(handles,'veccolor_valid_swatch')
		set(handles.veccolor_valid_swatch,  'BackgroundColor', validcolor);
		set(handles.veccolor_interp_swatch, 'BackgroundColor', interpcolor);
	end
	if isfield(handles,'veccolor_valid_swatch2')
		set(handles.veccolor_valid_swatch2,  'BackgroundColor', validcolor);
		set(handles.veccolor_interp_swatch2, 'BackgroundColor', interpcolor);
	end
end