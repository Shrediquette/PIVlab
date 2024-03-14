function gui_key_press(~, event) %General (currently hidden, respectively not documented) keyboard shortcuts in PIVlab
%display currently pressed key name:
%disp(event.Key)
if size(event.Modifier,2)==2 && strcmp(event.Modifier{1},'shift') && strcmp(event.Modifier{2},'control') %ctrl and shift modifiers
	if strcmp(event.Key,'c')
		crosshair_enabled=gui.gui_retr('crosshair_enabled');
		if isempty(crosshair_enabled)
			crosshair_enabled=0;
		end
		gui.gui_put('crosshair_enabled',1-crosshair_enabled);
	elseif strcmp(event.Key,'x')
		sharpness_enabled=gui.gui_retr('sharpness_enabled');
		if isempty(sharpness_enabled)
			sharpness_enabled=0;
		end
		gui.gui_put('sharpness_enabled',1-sharpness_enabled); % only autofocs OR sharpness display must be enabled at a time
	elseif strcmp(event.Key,'hyphen') %minus key
		ac_upper_clim = gui.gui_retr('ac_upper_clim');
		if ac_upper_clim < 2^16
			ac_upper_clim = ac_upper_clim + 5000;
		end
		gui.gui_put('ac_upper_clim',ac_upper_clim);
		gui.gui_put('ac_lower_clim',0);
		caxis([0 ac_upper_clim]) %#ok<*CAXIS>
	elseif strcmp(event.Key,'0') %plus
		ac_upper_clim = gui.gui_retr('ac_upper_clim');
		if ac_upper_clim > 5000
			ac_upper_clim = ac_upper_clim - 5000;
		end
		gui.gui_put('ac_upper_clim',ac_upper_clim);
		gui.gui_put('ac_lower_clim',0);
		caxis([0 ac_upper_clim])
	elseif strcmp(event.Key,'k')
		if strmatch (get(gca,'ColorScale'),'log') %#ok<*MATCH2>
			set(gca,'ColorScale','linear')
		else
			set(gca,'ColorScale','log')
		end
	elseif strcmp(event.Key,'h') %
		hist_enabled=gui.gui_retr('hist_enabled');
		if isempty(hist_enabled)
			hist_enabled=0;
		end
		gui.gui_put('hist_enabled',1-hist_enabled);
	end
end

