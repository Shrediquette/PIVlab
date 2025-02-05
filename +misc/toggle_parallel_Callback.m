function toggle_parallel_Callback(~, ~, ~)
hgui=getappdata(0,'hgui');
handles=gui.gethand;
load (fullfile('images','icons.mat'))
if gui.retr('darkmode')
	parallel_on=1-parallel_on+35/255;
	parallel_off=1-parallel_off+35/255;
	parallel_on(parallel_on>1)=1;
	parallel_off(parallel_off>1)=1;
end
try
	parallel=gui.retr('parallel');
	if parallel==0
		gui.put ('parallel',1);
		gui.toolsavailable(0,'Please wait, opening parallel pool...')
		pause(0.1)
		try
			desired_num_cores=maxNumCompThreads('automatic');
		catch
			desired_num_cores=feature('numCores');
		end
		misc.pivparpool('close')
		misc.pivparpool('open',desired_num_cores)
		set(handles.toggle_parallel, 'cdata',parallel_on,'TooltipString','Parallel processing on. Click to turn off.');
	else
		gui.put ('parallel',0);
		gui.toolsavailable(0,'Please wait, closing parallel pool...')
		misc.pivparpool('close')
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
	set (handles.ofv_parallelpatches,'Value',6)
end