function save_session_function (PathName,FileName)
hgui=getappdata(0,'hgui');
handles=gui.gethand;
app=getappdata(hgui);
gui.toolsavailable(1)
gui.toolsavailable(0,'Busy, saving session...');drawnow
deli={'UsedByGUIData_m' 'existing_handles' 'handle_toolprogress_bg' 'handle_toolprogress_fg' 'pivlab_axis'};
for i=1:numel(deli)
    if isfield(app,deli{i})
        app=rmfield(app,deli{i});
    end
end
clear hgui deli i
warning off
save(fullfile(PathName,FileName), '-struct', 'app','-v7.3')% riesig aber nur das geht...
warning on

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
calxy=gui.retr('calxy');
calu=gui.retr('calu');calv=gui.retr('calv');
pointscali=gui.retr('pointscali');

x_axis_direction=get(handles.x_axis_direction,'value');
y_axis_direction=get(handles.y_axis_direction,'value');
size_of_the_image=gui.retr('size_of_the_image');
points_offsetx=gui.retr('points_offsetx');
points_offsety=gui.retr('points_offsety');
offset_x_true=gui.retr('offset_x_true');
offset_y_true=gui.retr('offset_y_true');

realdist_string=get(handles.realdist, 'String');
time_inp_string=get(handles.time_inp, 'String');

%imginterpol=get(handles.popupmenu16, 'value');
algorithm_selection = get(handles.algorithm_selection,'value');
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

try
	%neu v1.5:
	%Repeated_box=get(handles.Repeated_box,'value');
	mask_auto_box=get(handles.mask_auto_box,'value');
	Autolimit=get(handles.Autolimit,'value');
	minintens=get(handles.minintens,'string');
	maxintens=get(handles.maxintens,'string');
	%neu v2.11
	CorrQuality_nr=get(handles.CorrQuality,'value');
	%neu v2.37
	enhance_disp=get(handles.enhance_images, 'Value');
catch
	disp('Old version compatibility|');
end
try
	contrast_filter_thresh=get(handles.contrast_filter_thresh,'string');
	bright_filter_thresh=get(handles.bright_filter_thresh,'string');
	do_bright_filter=get(handles.do_bright_filter,'Value');
	do_contrast_filter=get(handles.do_contrast_filter,'Value');
catch
end

try
	%neu v2.54
	do_corr2_filter=get(handles.do_corr2_filter,'value'); %#ok<*NASGU>
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
	disp('repeat_last didnt work3')
end

try
	bg_img_A=gui.retr('bg_img_A');
	bg_img_B=gui.retr('bg_img_B');
catch
	disp('Could not fetch bg imgs')
end

%new settings for camera calibration (v3.13)
calib_boardtype=handles.calib_boardtype.Value;
calib_origincolor=handles.calib_origincolor.Value;
calib_rows=handles.calib_rows.String;
calib_columns=handles.calib_columns.String;
calib_checkersize=handles.calib_checkersize.String;
calib_markersize=handles.calib_markersize.String;
calib_dolivedetect=handles.calib_dolivedetect.Value;
calib_fisheye=handles.calib_fisheye.Value;
calib_viewtype=handles.calib_viewtype.Value;
calib_usecalibration=handles.calib_usecalibration.Value;
calib_userectification=handles.calib_userectification.Value;
calib_upscale=handles.calib_upscale.Value;

clear handles
cameraParams=gui.retr('cameraParams');
save(fullfile(PathName,FileName), '-append', '-regexp', '^(?!app$).*');
if ~isempty(cameraParams)
    gui.put('cameraParams', cameraParams); % OMG, Matlab clears this variable randomly when writing a mat file...
end
gui.toolsavailable(1)
drawnow;