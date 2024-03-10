function export_save_session_function (PathName,FileName)
hgui=getappdata(0,'hgui');
handles=gui_NameSpace.gui_gethand;
app=getappdata(hgui);
gui_NameSpace.gui_toolsavailable(1)
gui_NameSpace.gui_toolsavailable(0,'Busy, saving session...');drawnow
%disp('hier was aendrn mit savehint')
%text(150,150,'Please wait, saving session. This might take a while.','color','y','fontsize',13, 'BackgroundColor', 'k','tag','savehint')
%Newer versions of Matlab do really funny things when the following vars are not empty...:
app.GUIDEOptions =[];
app.GUIOnScreen  =[];
app.Listeners  =[];
app.SavedVisible  =[];
app.ScribePloteditEnable  =[];
app.UsedByGUIData_m  =[];
app.lastValidTag =[];
iptPointerManager=[];
app.ZoomObject=[]; %Matlab crashes if this is not empty. Weird...
app.ZoomFigureState=[];
app.ZoomOnState=[];
app.PanFigureState=[];
app.uitools_FigureToolManager=[];
app.existing_handles=[];
app.num_handle_calls=[];

try
	iptPointerManager(gcf, 'disable');
catch
end
clear hgui iptPointerManager GUIDEOptions GUIOnScreen Listeners SavedVisible ScribePloteditEnable UsedByGUIData_m ZoomObject existing_handles num_handle_calls
deli={'UsedByGUIData_m', 'uitools_FigureToolManager','PanFigureState','ZoomOnState','ZoomFigureState','ZoomObject','lastValidTag','SavedVisible','Listeners','GUIOnScreen','GUIDEOptions','ScribePloteditEnable','nonexistingfield'};
for i=1:size(deli,2)
	try
		app=rmfield(app,deli{i});
	catch
	end
end
clear deli
%save('-v6', fullfile(PathName,FileName), '-struct', 'app')
%save(fullfile(PathName,FileName), '-struct', 'app') % AKTUELL PUBLIZIERT
warning off
save(fullfile(PathName,FileName), '-struct', 'app','-v7.3')% riesig aber nur das geht...
warning on

clear app %hgui iptPointerManager
clear hgui iptPointerManager GUIDEOptions GUIOnScreen Listeners SavedVisible ScribePloteditEnable UsedByGUIData_m

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
calxy=gui_NameSpace.gui_retr('calxy');
calu=gui_NameSpace.gui_retr('calu');calv=gui_NameSpace.gui_retr('calv');
pointscali=gui_NameSpace.gui_retr('pointscali');

x_axis_direction=get(handles.x_axis_direction,'value');
y_axis_direction=get(handles.y_axis_direction,'value');
size_of_the_image=gui_NameSpace.gui_retr('size_of_the_image');
points_offsetx=gui_NameSpace.gui_retr('points_offsetx');
points_offsety=gui_NameSpace.gui_retr('points_offsety');
offset_x_true=gui_NameSpace.gui_retr('offset_x_true');
offset_y_true=gui_NameSpace.gui_retr('offset_y_true');

realdist_string=get(handles.realdist, 'String');
time_inp_string=get(handles.time_inp, 'String');

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
	disp('repeat_last didnt work3')
end

try
	bg_img_A=gui_NameSpace.gui_retr('bg_img_A');
	bg_img_B=gui_NameSpace.gui_retr('bg_img_B');
catch
	disp('Could not fetch bg imgs')
end

clear handles
clear existing_handles
clear num_handle_calls

%save('-v6', fullfile(PathName,FileName), '-append');
%save(fullfile(PathName,FileName), '-append');
save(fullfile(PathName,FileName), '-append');

%delete(findobj('tag','savehint'));
gui_NameSpace.gui_toolsavailable(1)
drawnow;
