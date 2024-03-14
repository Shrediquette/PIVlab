function export_save_settings_Callback(~, ~, ~)
handles=gui.gui_gethand;
clahe_enable=get(handles.clahe_enable,'value');
clahe_size=get(handles.clahe_size,'string');
enable_highpass=get(handles.enable_highpass,'value');
highp_size=get(handles.highp_size,'string');
wienerwurst=get(handles.wienerwurst,'value');
wienerwurstsize=get(handles.wienerwurstsize,'string');

%enable_clip=get(handles.enable_clip,'value');
%clip_thresh=get(handles.clip_thresh,'string');
enable_intenscap=get(handles.enable_intenscap,'value');
intarea=get(handles.intarea,'string');
stepsize=get(handles.step,'string');
subpix=get(handles.subpix,'value');  %popup
stdev_check=get(handles.stdev_check,'value');
stdev_thresh=get(handles.stdev_thresh,'string');
loc_median=get(handles.loc_median,'value');
loc_med_thresh=get(handles.loc_med_thresh,'string');
%epsilon=get(handles.epsilon,'string');
interpol_missing=get(handles.interpol_missing,'value');
vectorscale=get(handles.vectorscale,'string');
colormap_choice=get(handles.colormap_choice,'value'); %popup
colormap_steps=get(handles.colormap_steps,'value');
colormap_interpolation=get(handles.colormap_interpolation,'value');
addfileinfo=get(handles.addfileinfo,'value');
add_header=get(handles.add_header,'value');
delimiter=get(handles.delimiter,'value');%popup
img_not_mask=get(handles.img_not_mask,'value');
autoscale_vec=get(handles.autoscale_vec,'value');

%imginterpol=get(handles.popupmenu16, 'value');
dccmark=get(handles.dcc, 'value');
fftmark=get(handles.fftmulti, 'value');
ensemblemark=get(handles.ensemble, 'value');

pass2=get(handles.checkbox26, 'value');

pass3=get(handles.checkbox27, 'value');
pass4=get(handles.checkbox28, 'value');
pass2val=get(handles.edit50, 'string');
pass3val=get(handles.edit51, 'string');
pass4val=get(handles.edit52, 'string');
step2=get(handles.text126, 'string');
step3=get(handles.text127, 'string');
step4=get(handles.text128, 'string');
holdstream=get(handles.holdstream, 'value');
streamlamount=get(handles.streamlamount, 'string');
streamlcolor=get(handles.streamlcolor, 'value');
streamlcolor=get(handles.streamlwidth, 'value');
realdist=get(handles.realdist, 'string');
time_inp=get(handles.time_inp, 'string');

nthvect=get(handles.nthvect, 'string');
validr=get(handles.validr,'string');
validg=get(handles.validg,'string');
validb=get(handles.validb,'string');
validdr=get(handles.validdr,'string');
validdg=get(handles.validdg,'string');
validdb=get(handles.validdb,'string');
interpr=get(handles.interpr,'string');
interpg=get(handles.interpg,'string');
interpb=get(handles.interpb,'string');

calxy=gui.gui_retr('calxy');
calu=gui.gui_retr('calu');calv=gui.gui_retr('calv');

try
	%neu v1.5:
	%Repeated_box=get(handles.Repeated_box,'value');
	mask_auto_box=get(handles.mask_auto_box,'value');
	Autolimit=get(handles.Autolimit,'value');
	minintens=get(handles.minintens,'string');
	maxintens=get(handles.maxintens,'string');
	%neu v2.0:
	panelwidth=get(handles.panelslider,'Value');
	%neu v2.11
	CorrQuality_nr=get(handles.CorrQuality, 'value');
	%neu v2.37
	enhance_disp=get(handles.enhance_images, 'Value');
catch
	disp('Old version compatibility_');
end
try
	%v2.41
	x_axis_direction=get(handles.x_axis_direction,'value');
	y_axis_direction=get(handles.y_axis_direction,'value');
	size_of_the_image=gui.gui_retr('size_of_the_image');
	points_offsetx=gui.gui_retr('points_offsetx');
	points_offsety=gui.gui_retr('points_offsety');
	offset_x_true=gui.gui_retr('offset_x_true');
	offset_y_true=gui.gui_retr('offset_y_true');
	contrast_filter_thresh=get(handles.contrast_filter_thresh,'string');
	bright_filter_thresh=get(handles.bright_filter_thresh,'string');
	do_bright_filter=get(handles.do_bright_filter,'Value');
	do_contrast_filter=get(handles.do_contrast_filter,'Value');
catch
end
try
	%neu v2.54
	do_corr2_filter=get(handles.do_corr2_filter,'value');
	corr_filter_thresh=get(handles.corr_filter_thresh,'string');
	notch_L_thresh=get(handles.notch_L_thresh,'string');
	notch_H_thresh=get(handles.notch_H_thresh,'string');
	notch_filter=get(handles.notch_filter,'Value');
catch
	disp('corr filter / notch settings');
end
%neu v2.52
try
	repeat_last = get (handles.repeat_last,'Value');
	repeat_last_thresh = get(handles.edit52x,'String');
catch
	disp('repeat_last didnt work2')
end

pointscali=gui.gui_retr('pointscali');
if isempty(pointscali)
	clear pointscali
end

if ispc==1
	[FileName,PathName] = uiputfile('*.mat','Save current settings as...',['PIVlab_set_' getenv('USERNAME') '.mat']);
else
	try
		[FileName,PathName] = uiputfile('*.mat','Save current settings as...',['PIVlab_set_' getenv('USER') '.mat']);
	catch
		[FileName,PathName] = uiputfile('*.mat','Save current settings as...','PIVlab_set.mat');
	end
end

clear handles hObject eventdata
if ~isequal(FileName,0)
	save('-v6', fullfile(PathName,FileName))
end

