function update_derivchoice_list(handles)
% Fills the list of derived parameters (Plot -> Derive parameters) with the units of the current
% calibration. A list item wanted by loaded settings is selected afterwards (gui.apply_pending_popup).
% Stereo-PIV: one more item at the end, the w component (index 14; the magnitude is then 3D).
if nargin < 1
	handles=gui.gethand;
end
if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
	set(handles.derivchoice,'String',{'Vectors in px/frame';'Vorticity in 1/frame';'Magnitude in px/frame';'u component in px/frame';'v component in px/frame';'Divergence in 1/frame';'Q criterion in 1/frame^2';'Shear rate (magnitude of the rate-of-strain tensor) in 1/frame';'Simple strain rate in 1/frame';'Line integral convolution (LIC)' ; 'Vector direction in degrees'; 'Correlation coefficient';'Uncertainty in px/frame'});
	w_item='w component in px/frame';
	set(handles.text35,'String','u in px/frame:')
	set(handles.text36,'String','v in px/frame:')
else %calibrated
	displacement_only=gui.retr('displacement_only');
	if ~isempty(displacement_only) && displacement_only == 1
		set(handles.derivchoice,'String',{'Vectors in m/frame';'Vorticity in 1/frame';'Magnitude in m/frame';'u component in m/frame';'v component in m/frame';'Divergence in 1/frame';'Q criterion in 1/frame^2';'Shear rate (magnitude of the rate-of-strain tensor) in 1/frame';'Simple strain rate in 1/frame';'Line integral convolution (LIC)'; 'Vector direction in degrees'; 'Correlation coefficient';'Uncertainty in m/frame'});
		w_item='w component in m/frame';
		set(handles.text35,'String','u in m/frame:')
		set(handles.text36,'String','v in m/frame:')
	else
		set(handles.derivchoice,'String',{'Vectors in m/s';'Vorticity in 1/s';'Magnitude in m/s';'u component in m/s';'v component in m/s';'Divergence in 1/s';'Q criterion in 1/s^2';'Shear rate (magnitude of the rate-of-strain tensor) in 1/s';'Simple strain rate in 1/s';'Line integral convolution (LIC)'; 'Vector direction in degrees'; 'Correlation coefficient';'Uncertainty in m/s'});
		w_item='w component in m/s';
		set(handles.text35,'String','u in m/s:')
		set(handles.text36,'String','v in m/s:')
	end
end
items=get(handles.derivchoice,'String');
if isequal(gui.retr('stereomode'),1)
	items{end+1,1}=w_item;
	set(handles.derivchoice,'String',items);
end
if get(handles.derivchoice,'Value')>numel(items) %w component chosen, back in 2D mode
	set(handles.derivchoice,'Value',1);
end
gui.apply_pending_popup(handles.derivchoice)
