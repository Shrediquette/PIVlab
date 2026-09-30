function set_capture_overlay_controls(mode)
%Enables / unticks the live overlay controls while a camera is running (same for all cameras).
%Called after gui.toolsavailable(0). After Stop, gui.toolsavailable(1) restores the idle state.
%mode: 'live'        = live image
%      'piv_preview' = PIV capture, save unticked
%      'piv_record'  = PIV capture, save ticked
handles=gui.gethand;
is_live = strcmp(mode,'live');
is_preview = strcmp(mode,'piv_preview');

%Zoom: only in the live image (gui.toolsavailable(0) already switched an active zoom off)
set(handles.zoomon,'enable',onoff(is_live));

%Calibration (live ChArUco detection): only in the live image
if ~is_live
	set(handles.calib_dolivedetect,'Value',0);
end
set(handles.calib_dolivedetect,'enable',onoff(is_live));

%Displacement: only in PIV capture with save unticked
if ~is_preview
	set(handles.ac_realtime_PIV,'Value',0);
end
set(handles.ac_realtime_PIV,'enable',onoff(is_preview));

%Sharpness + grid: in the live image and in PIV capture with save unticked
if ~(is_live || is_preview)
	set(handles.ac_displ_sharp,'Value',0);
	set(handles.ac_displ_grid,'Value',0);
end
set(handles.ac_displ_sharp,'enable',onoff(is_live || is_preview));
set(handles.ac_displ_grid,'enable',onoff(is_live || is_preview));

%The capture loops read appdata, not the checkboxes: bring the appdata in line with the checkboxes
acquisition.display_cam_overlay_Callback(handles.ac_displ_sharp);
acquisition.display_cam_overlay_Callback(handles.ac_displ_grid);
preproc.cam_live_detect_Callback(handles.calib_dolivedetect);

function state = onoff(enabled)
if enabled
	state = 'on';
else
	state = 'off';
end
