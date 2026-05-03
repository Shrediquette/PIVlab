function toggle_second_monitor_Callback(src, ~)
% Toggle second-monitor display. When active, pivlab_axis is redirected to
% a dedicated figure on the second monitor. When deactivated (or the second
% figure is closed), the original axis is restored.

second_monitor_fig = gui.retr('second_monitor_fig');

if ~isempty(second_monitor_fig) && isvalid(second_monitor_fig)
	% --- Already active: turn off ---
	gui.second_monitor_disable;
else
	% --- Not yet active: turn on ---
	monitors = get(0, 'MonitorPositions');
	if size(monitors, 1) < 2
		gui.custom_msgbox('warn', getappdata(0,'hgui'), 'Single monitor detected', ...
			'No second monitor detected. Connect a second display first.', 'modal');
		return;
	end

	mon2 = monitors(2, :);

	% Default (restore) size: 80% of the monitor, centered.
	% This is what the user sees when clicking "restore" from maximized state.
	default_w = mon2(3) * 0.8;
	default_h = mon2(4) * 0.8;
	default_x = mon2(1) + mon2(3) * 0.1;
	default_y = mon2(2) + mon2(4) * 0.1;

	second_monitor_fig = figure( ...
		'Name',            'PIVlab - second monitor display', ...
		'NumberTitle',     'off', ...
		'MenuBar',         'none', ...
		'ToolBar',         'none', ...
		'Color',           'k', ...
		'CloseRequestFcn', @(~,~) gui.second_monitor_CloseRequestFcn, ...
		'Position',        [default_x default_y default_w default_h]);
	drawnow;  % commit position so MATLAB knows which screen to maximize on
	set(second_monitor_fig, 'WindowState', 'maximized');
	drawnow;  % flush the deferred resize event NOW, while the figure has no axis yet,
	          % so it cannot interfere with the colorbar layout in the first render.

	% OuterPosition [0 0 1 1]: MATLAB can resize the InnerPosition to accommodate
	% the colorbar and its title without clipping.
	% LooseInset [0 0 0 0]: removes MATLAB's default ~3% padding around the axis.
	% Since XColor/YColor are 'none', TightInset is near-zero, so the image
	% fills the figure edge-to-edge (apart from any colorbar).
	second_ax = axes( ...
		'Parent',        second_monitor_fig, ...
		'Units',         'normalized', ...
		'OuterPosition', [0 0 1 1], ...
		'Color',         'k', ...
		'XColor',        'none', ...
		'YColor',        'none');
	set(second_ax, 'LooseInset', [0 0 0 0]);

	% Show logo on main window before redirecting pivlab_axis
	original_ax = gui.retr('pivlab_axis');
	gui.displogo([]);

	% Save state and redirect
	gui.put('original_pivlab_axis', original_ax);
	gui.put('second_monitor_fig',   second_monitor_fig);
	gui.put('second_monitor_axis',  second_ax);
	gui.put('pivlab_axis',          second_ax);

	set(src, 'Checked', 'on');

	% Render current frame to second monitor
	gui.sliderdisp(second_ax);
end
