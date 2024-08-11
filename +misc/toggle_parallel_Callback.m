function toggle_parallel_Callback(~, ~, ~)
hgui=getappdata(0,'hgui');
handles=gui.gethand;
load icons.mat
try
	parallel=gui.retr('parallel');
	if parallel==0
		gui.put ('parallel',1);
		gui.toolsavailable(0,'Please wait, opening parallel pool...')
		pause(0.1)
		desired_num_cores=feature('numCores');
		pivparpool('close')
		pivparpool('open',desired_num_cores)
		set(handles.toggle_parallel, 'cdata',parallel_on,'TooltipString','Parallel processing on. Click to turn off.');
	else
		gui.put ('parallel',0);
		gui.toolsavailable(0,'Please wait, closing parallel pool...')
		pivparpool('close')
		set(handles.toggle_parallel, 'cdata',parallel_off,'TooltipString','Parallel processing off. Click to turn on.');
	end
	gui.toolsavailable(1);
catch ME
	gui.put ('parallel',0);
	set(handles.toggle_parallel, 'cdata',parallel_off,'enable','off', 'TooltipString','Parallel processing not avilable.');
	gui.toolsavailable(1);
	disp (ME.message)
end

if gui.retr('parallel')==0
	set (handles.text_parallelpatches,'visible','off')
	set (handles.ofv_parallelpatches,'visible','off')
	set (handles.ofv_parallelpatches,'Value',1)
else
	set (handles.text_parallelpatches,'visible','on')
	set (handles.ofv_parallelpatches,'visible','on')
end