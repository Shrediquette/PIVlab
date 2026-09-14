function low_energy_mode_Callback(~,~,~)
%LOW_ENERGY_MODE_CALLBACK Toggle the low energy / alignment mode.
%   Low energy mode pulses the laser at a fixed 100 Hz with the shortest valid
%   pulse (1 us) for beam alignment. In this mode the laser is decoupled from
%   the camera, so synchronized PIV capture is impossible: the whole "Capture
%   PIV images" panel and the synchronizer inputs are greyed out as a clear
%   signal, while "Toggle Laser" stays enabled so the alignment beam can be
%   fired. The dedicated low energy string is built in
%   acquisition.low_energy_sequence and sent by acquisition.control_simple_sync_serial.

handles = gui.gethand;
low_energy = get(handles.ac_low_energy_mode, 'Value');
gui.put('low_energy_mode', low_energy);

% grey out the whole "Capture PIV images" panel as the signal that
% synchronized capture is not available
capture_kids = findall(handles.uipanelac_capture, '-property', 'Enable');

if low_energy
	set(capture_kids, 'Enable', 'off');
	% the synchronizer inputs no longer apply in low energy mode
	handles.ac_fps.Enable = 'off';
	handles.ac_interpuls.Enable = 'off';
	handles.ac_power.Enable = 'off';
	handles.ac_enable_straddling_figure.Enable = 'off';
	% the timing graph is meaningless without camera timing
	straddling_figure = findobj('tag', 'straddling_figure');
	if ~isempty(straddling_figure)
		close(straddling_figure)
	end
	% if the laser is already running, immediately drop it to the low energy string
	laser_running = gui.retr('laser_running');
	if ~isempty(laser_running) && laser_running == 1
		acquisition.control_simple_sync_serial(1, 0);
	end
else
	% stop the laser FIRST, then restore the controls
	acquisition.control_simple_sync_serial(0, 0);
	gui.put('laser_running', 0);
	set(capture_kids, 'Enable', 'on');
	handles.ac_fps.Enable = 'on';
	handles.ac_interpuls.Enable = 'on';
	handles.ac_power.Enable = 'on';
	handles.ac_enable_straddling_figure.Enable = 'on';
	% restore ac_imgamount to the state dictated by the "Save" checkbox
	acquisition.pivcapture_save_Callback(handles.ac_pivcapture_save);
end
