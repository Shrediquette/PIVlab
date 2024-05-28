function key_press(~, event) %General (currently hidden, respectively not documented) keyboard shortcuts in PIVlab
%display currently pressed key name:
%disp(event.Key)
%disp(event.Character)
if size(event.Modifier,2)==2 && strcmp(event.Modifier{1},'shift') && strcmp(event.Modifier{2},'control') %ctrl and shift modifiers
	if strcmp(event.Key,'c')
		crosshair_enabled=gui.retr('crosshair_enabled');
		if isempty(crosshair_enabled)
			crosshair_enabled=0;
		end
		gui.put('crosshair_enabled',1-crosshair_enabled);
	elseif strcmp(event.Key,'x')
		sharpness_enabled=gui.retr('sharpness_enabled');
		if isempty(sharpness_enabled)
			sharpness_enabled=0;
		end
		gui.put('sharpness_enabled',1-sharpness_enabled); % only autofocs OR sharpness display must be enabled at a time
	elseif strcmp(event.Key,'hyphen') %minus key
		ac_upper_clim = gui.retr('ac_upper_clim');
		if ac_upper_clim < 2^16
			ac_upper_clim = ac_upper_clim + 5000;
		end
		gui.put('ac_upper_clim',ac_upper_clim);
		gui.put('ac_lower_clim',0);
		caxis([0 ac_upper_clim]) %#ok<*CAXIS>
	elseif strcmp(event.Key,'0') %plus
		ac_upper_clim = gui.retr('ac_upper_clim');
		if ac_upper_clim > 5000
			ac_upper_clim = ac_upper_clim - 5000;
		end
		gui.put('ac_upper_clim',ac_upper_clim);
		gui.put('ac_lower_clim',0);
		caxis([0 ac_upper_clim])
	elseif strcmp(event.Key,'k')
		if strmatch (get(gca,'ColorScale'),'log') %#ok<*MATCH2>
			set(gca,'ColorScale','linear')
		else
			set(gca,'ColorScale','log')
		end
	elseif strcmp(event.Key,'h') %
		hist_enabled=gui.retr('hist_enabled');
		if isempty(hist_enabled)
			hist_enabled=0;
		end
		gui.put('hist_enabled',1-hist_enabled);
	end
end
%{
if strcmp(event.Key,'uparrow') %
	old_xlims=get(gca,'xlim');
	centr=get(gcf(),'CurrentPoint');
	new_xlims=old_xlims*0.9
	set(gca,'xlim',new_xlims)

	%zoom(1.1)
	%get mousepointerpos, pan there....

	get(gca,'xlim')
end
if strcmp(event.Key,'downarrow') %
	disp('downdowndown')
	zoom(0.9)
end
%}
