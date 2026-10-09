function load_session_Callback(auto_load_session, auto_load_session_filename)
% File -> Load session (auto_load_session = 1: load auto_load_session_filename without dialog,
% e.g. in batch mode). Brings PIVlab back to the state when the session was saved: session data,
% all settings and the view. Hardware (camera, serial port) is not connected.
sessionpath=gui.retr('sessionpath');
if isempty(sessionpath)
	sessionpath=gui.retr('pathname');
end
if auto_load_session ~= 1
	[FileName,PathName] = uigetfile({'*.mat','MATLAB Files (*.mat)'; '*.mat','mat'},'Load PIVlab session',fullfile(sessionpath, 'PIVlab_session.mat'));
	if isequal(FileName,0) || isequal(PathName,0)
		return
	end
else
	[PathName,FileName,ext] = fileparts(auto_load_session_filename);
	FileName = [FileName ext];
end
gui.toolsavailable(0,'Busy, loading session...');drawnow
[session, message] = import.read_session_file(fullfile(PathName,FileName));
if isempty(session)
	gui.toolsavailable(1)
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Load session',message,'modal');
	return
end
clear iptPointerManager
gui.put('sessionpath',PathName);
%% session data: exactly these entries, nothing left from the previous session
keys = gui.session_data_keys;
for i=1:numel(keys)
	if isfield(session.data,keys{i})
		gui.put(keys{i},session.data.(keys{i}));
	else
		gui.put(keys{i},[]);
	end
end
if gui.retr('video_selection_done') == 1 % the video reader is not stored: open the video again
	filepath = gui.retr('filepath');
	try
		gui.put('video_reader_object',VideoReader(filepath{1}));
	catch
		disp(['-> Could not open the video file ' filepath{1}])
	end
end
gui.put('existing_handles',[]);
gui.put('num_handle_calls',0);
gui.sliderrange(1)
handles=gui.gethand;
filename = gui.retr('filename');
if ~isempty(filename)
	set(handles.filenamebox,'String',filename);
	set(handles.filenamebox,'Value',1);
end
%% settings (all groups, also the controls whose data is only in sessions)
gui.put('pending_popup_texts',[]);
gui.apply_settings(session.settings, fieldnames(gui.default_settings), true);
%% displays of the data
gui.refresh_data_displays(handles)
%% view
set(handles.panon,'Value',0);
set(handles.zoomon,'Value',0);
gui.apply_view(session.view)
gui.toolsavailable(1)
% Enable states that depend on the data (the busy state restored those from before loading)
gui.sliderrange(0)
if ~isempty(gui.retr('filepath'))
	set(handles.remove_imgs,'Enable','on');
end
gui.update_dependent_controls %Enable / Visible of the controls that depend on settings
gui.sliderdisp(gui.retr('pivlab_axis'))
image_size=gui.retr('expected_image_size'); % shown in the Input data panel (sliderdisp only updates it there)
if numel(image_size)>=2
	set(handles.imsize, 'string', ['Image size: ' int2str(image_size(2)) '*' int2str(image_size(1)) 'px' ])
end
filepath=gui.retr('filepath');
if ~isempty(filepath)
	if gui.retr('parallel')==1
		modestr=' (parallel)';
	else
		modestr=' (serial)';
	end
	if ~isdeployed
		appname='PIVlab';
	else
		appname='PIVlab standalone';
	end
	set(getappdata(0,'hgui'), 'Name',[appname ' ' gui.retr('PIVver')  modestr '   [Path: ' fileparts(filepath{1}) ']']) %for people like me that always forget what dataset they are currently working on...
end
