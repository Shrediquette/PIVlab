function busy_watchdog(watchdog,~)
%BUSY_WATCHDOG Timer callback that runs while the PIVlab controls are locked by gui.toolsavailable(0).
%   MATLAB runs timer callbacks when it is idle, or when running code calls drawnow / pause / waits for
%   the user. In the second case the running PIVlab code appears in dbstack below 'timercb'.
%   When MATLAB stays idle for 3 s while the controls are locked, the task ended without
%   gui.toolsavailable(1), usually because of an error. Then the status strip offers the button
%   "Unlock controls". gui.toolsavailable(1) deletes this timer.
%   While a camera runs (gui.busy_hint_until_image), the strip and the busy pointer are removed as
%   soon as the camera image is shown.
hgui=getappdata(0,'hgui');
if isempty(hgui) || ~ishandle(hgui)
	stop(watchdog);
	delete(watchdog);
	return
end
busy_figs=gui.busy_figures;
% camera running: no strip and no busy pointer as soon as its image is shown
until_image=gui.retr('busy_until_image');
if ~isempty(until_image) && isvalid(until_image.axis)
	images_now=findobj(until_image.axis,'Type','image');
	if any(~ismember(images_now,until_image.images_before))
		gui.put('busy_until_image',[]);
		for k=1:numel(busy_figs)
			delete(findobj(busy_figs(k),'Tag','busyhint'));
		end
		set(busy_figs,'Pointer','arrow');
	end
end
% elapsed time in the status strips (PIVlab window and second monitor display)
busy_since=gui.retr('busy_since');
if ~isempty(busy_since)
	elapsed=findobj(busy_figs,'Tag','busy_elapsed');
	set(elapsed,'String',gui.busy_elapsed_string(toc(busy_since)));
end
s=dbstack;
timer_level=0;
for k=1:numel(s)
	if strcmp(s(k).name,'timercb')
		timer_level=k;
		break
	end
end
if timer_level==0
	return % call stack not known: no decision possible
end
if timer_level<numel(s)
	watchdog.UserData=0; % PIVlab code is running
	return
end
idle_count=watchdog.UserData+1;
watchdog.UserData=idle_count;
if idle_count==3
	try
		gui.busy_hint('The task stopped, probably with an error (see Command Window).',true);
		set(busy_figs,'Pointer','arrow');
	catch
	end
end
