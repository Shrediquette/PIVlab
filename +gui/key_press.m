function key_press(~, event)
%KEY_PRESS Keyboard shortcuts of the PIVlab main window.
% Every shortcut uses Ctrl+Shift. Ctrl alone is taken by the operating system and by Matlab's
% text fields (Ctrl+A select all, Ctrl+C copy, Ctrl+V paste, Ctrl+Z undo), so the earlier
% Ctrl-only menu accelerators did not work while an edit field had the focus. Matlab's uimenu
% 'Accelerator' can only do Ctrl+key, which is why the shortcuts are handled here instead.
% This function is the figure's WindowKeyPressFcn (see PIVlab_GUI), so it also works while a
% control has the focus.
%
% The panel shortcuts run the menu entry or the control of the same name through
% gui.run_shortcut: a shortcut does nothing when that element is hidden (Basic mode, 2D mode)
% or disabled (PIVlab is busy, see gui.toolsavailable).
%
% The display helpers at the end are deliberately NOT documented in the manual.
% The documented list is docs/manual/pages/shortcuts.html - keep the two in sync.
if numel(event.Modifier) ~= 2
	return
end
if ~any(strcmp(event.Modifier,'control')) || ~any(strcmp(event.Modifier,'shift'))
	return
end
switch event.Key
	%% Documented shortcuts: open a panel / run an action
	case 'n'
		gui.run_shortcut('menu_new_session');
	case 'o'
		gui.run_shortcut('stereo_import');
	case 'i'
		gui.run_shortcut('menu_preprocessing');
	case 'e'
		gui.run_shortcut('menu_roi');
	case 'k'
		gui.run_shortcut('menu_masks');
	case 's'
		gui.run_shortcut('menu_pivsettings');
	case 'w'
		gui.run_shortcut('menu_stereopiv');
	case 'a'
		gui.run_shortcut('menu_analyze');
	case 'v'
		gui.run_shortcut('menu_velvalidation');
	case 'f'
		gui.run_shortcut('menu_imgvalidation');
	case 'z'
		gui.run_shortcut('menu_spatialcalib');
	case 'd'
		gui.run_shortcut('menu_derivespatial');
	case 'r'
		gui.run_shortcut('menu_derivetemporal');
	case 'm'
		gui.run_shortcut('menu_plotappearance');
	case 't'
		gui.run_shortcut('menu_markers');
	case 'p'
		gui.run_shortcut('menu_polyline');
	case 'q'
		gui.run_shortcut('menu_area');
	case 'b'
		gui.run_shortcut('menu_statistics');
	case 'g'
		gui.run_shortcut('menu_partgen3d');
	case 'h'
		gui.run_shortcut('menu_gettingstarted');
	case '1'
		activate_stereo_camera(1);
	case '2'
		activate_stereo_camera(2);

	%% Hidden display helpers (not documented, mainly used during image acquisition)
	case 'c'
		crosshair_enabled=gui.retr('crosshair_enabled');
		if isempty(crosshair_enabled)
			crosshair_enabled=0;
		end
		gui.put('crosshair_enabled',1-crosshair_enabled);
	case 'x'
		sharpness_enabled=gui.retr('sharpness_enabled');
		if isempty(sharpness_enabled)
			sharpness_enabled=0;
		end
		gui.put('sharpness_enabled',1-sharpness_enabled); % only autofocs OR sharpness display must be enabled at a time
	case 'hyphen' %minus key
		ac_upper_clim = gui.retr('ac_upper_clim');
		if ac_upper_clim < 2^16
			ac_upper_clim = ac_upper_clim + 5000;
		end
		gui.put('ac_upper_clim',ac_upper_clim);
		gui.put('ac_lower_clim',0);
		caxis([0 ac_upper_clim]) %#ok<*CAXIS>
	case '0' %plus
		ac_upper_clim = gui.retr('ac_upper_clim');
		if ac_upper_clim > 5000
			ac_upper_clim = ac_upper_clim - 5000;
		end
		gui.put('ac_upper_clim',ac_upper_clim);
		gui.put('ac_lower_clim',0);
		caxis([0 ac_upper_clim])
	case 'l' % colour scale of the image display (was Ctrl+Shift+K before Ctrl+Shift+K became "define masks")
		target_axis=gui.retr('pivlab_axis');
		if strcmp(get(target_axis,'ColorScale'),'log')
			set(target_axis,'ColorScale','linear')
		else
			set(target_axis,'ColorScale','log')
		end
end

function activate_stereo_camera(k)
%Stereo-PIV: show and edit camera k. The camera switch of the Tools panel is the mouse way;
%it is only visible and enabled when switching is actually possible.
toggle = findall(getappdata(0,'hgui'),'Tag','stereo_camera_toggle');
if isempty(toggle)
	return
end
if strcmp(get(toggle(1),'Enable'),'off') || strcmp(get(toggle(1),'Visible'),'off')
	return
end
active = gui.retr('stereo_active_camera');
if isequal(active,k)
	return
end
stereo.switch_camera(k);
