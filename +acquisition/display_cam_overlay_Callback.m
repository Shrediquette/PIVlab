function display_cam_overlay_Callback (A,~,~)
if strcmpi (A.Tag, 'ac_displ_sharp')
	gui.put('sharpness_enabled',A.Value);
end
if strcmpi (A.Tag, 'ac_displ_grid')
	gui.put('crosshair_enabled',A.Value);
end
if strcmpi (A.Tag, 'ac_displ_hist')
	gui.put('hist_enabled',A.Value);
end

