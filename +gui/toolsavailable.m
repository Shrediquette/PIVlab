function toolsavailable(inpt,busy_msg,waits_for_user)
%0: disable all tools
%1: re-enable tools that were previously also enabled
%busy_msg (optional, with 0): text in a status strip at the bottom of the image display (gui.busy_hint)
%waits_for_user (optional, with 0): true when PIVlab waits for the user, e.g. in a file dialog or (idle)
%   until the user removes an image: no elapsed time and no busy mouse pointer. Otherwise a watchdog
%   offers to unlock the controls when the task ended without gui.toolsavailable(1), e.g. after an
%   error (gui.busy_watchdog).
hgui=getappdata(0,'hgui');
handles=gui.gethand;
pivlab_axis=gui.retr('pivlab_axis');
if inpt==0
	if get(handles.zoomon,'Value')==1
		set(handles.zoomon,'Value',0);
		gui.zoomon_Callback(handles.zoomon)
	end
	if get(handles.panon,'Value')==1
		set(handles.panon,'Value',0);
		gui.panon_Callback(handles.panon)
	end
end

% status strip and watchdog of a previous call are removed (before the controls are collected below)
busy_figs=gui.busy_figures; % PIVlab window and second monitor display
for i=1:numel(busy_figs)
	delete(findobj(busy_figs(i),'Tag','busyhint'));
end
delete(findobj(pivlab_axis,'tag','busyhint'));
watchdog=timerfindall('Tag','PIVlab_busy_watchdog');
if ~isempty(watchdog)
	stop(watchdog);
	delete(watchdog);
end

elementsOfCrime=findobj(hgui, 'type', 'uicontrol');
elementsOfCrime2=findobj(hgui, 'type', 'uimenu');
if inpt==0
	% remember which controls were disabled before (by handle: controls may be created or
	% deleted while PIVlab is busy). Only kept in memory, never saved in a session.
	was_disabled=false(numel(elementsOfCrime),1);
	for i=1:numel(elementsOfCrime)
		was_disabled(i)=strcmp(elementsOfCrime(i).Enable,'off');
	end
	gui.put('disabled_while_busy', elementsOfCrime(was_disabled));
	set(elementsOfCrime, 'enable', 'off');
	set(elementsOfCrime2, 'enable', 'off');
	if ~exist('waits_for_user','var')
		waits_for_user=false;
	end
	if waits_for_user
		gui.put('busy_since',[]); % no elapsed time in the status strip
	else
		gui.put('busy_since',tic);
	end
	if exist('busy_msg','var') && ~isempty(busy_msg)
		gui.busy_hint(busy_msg);
		if ~waits_for_user
			% busy mouse pointer (only with a message: the drawing tools lock the controls without one)
			set(busy_figs,'Pointer','watch');
		end
	end
	if ~waits_for_user
		watchdog=timer('Tag','PIVlab_busy_watchdog','ObjectVisibility','off','ExecutionMode','fixedSpacing', ...
			'Period',1,'BusyMode','drop','UserData',0,'TimerFcn',@gui.busy_watchdog);
		start(watchdog);
	end
else
	gui.put('busy_since',[]);
	for i=1:numel(busy_figs)
		if strcmp(get(busy_figs(i),'Pointer'),'watch')
			set(busy_figs(i),'Pointer','arrow');
		end
	end
	set(elementsOfCrime, 'enable', 'on');
	disabled_while_busy=gui.retr('disabled_while_busy');
	if ~isempty(disabled_while_busy)
		set(disabled_while_busy(isvalid(disabled_while_busy)), 'enable', 'off');
	end
	set(elementsOfCrime2, 'enable', 'on');
end
set(handles.progress, 'enable', 'on');
set(handles.overall, 'enable', 'on');
set(handles.totaltime, 'enable', 'on');
set(handles.messagetext, 'enable', 'on');
