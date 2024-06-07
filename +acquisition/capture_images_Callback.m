function capture_images_Callback(~,~,~) %Menu item is called
filepath = fileparts(which('PIVlab_GUI.m'));
gui.switchui('multip24')
acquisition.select_capture_config_Callback

if verLessThan('matlab','9.7') %R2019b
	uiwait(msgbox('Image capture and synchronizer control in PIVlab requires at least MATLAB version 9.7 (R2019b).','modal'))
end
handles=gui.gethand;
if isempty(get(handles.ac_project,'String')) %if user hasnt entered a project path...
	if ~isempty(gui.retr('pathname'))
		set(handles.ac_project,'String',fullfile(gui.retr('pathname'),['PIVlabCapture_' char(datetime('today'))]));
	else
		set(handles.ac_project,'String',fullfile(pwd,['PIVlabCapture_' char(datetime('today'))]));
	end
end
serpo=gui.retr('serpo');
try
	serpo.Port; %is there no other way to determine if serialport is working...?
	alreadyconnected=1;
catch
	alreadyconnected=0;
	delete(serpo)
	gui.put('serpo',[]);
	set(handles.ac_comport,'Value',1);
	set(handles.ac_laserstatus,'String','N/A','BackgroundColor',[1 0 0])
end
if alreadyconnected
	serports=serialportlist('available');
	set(handles.ac_comport,'String',[serpo.Port serports]); %fill dropdown with connected port on top, and other available ports at bottom
	set(handles.ac_connect,'String','Connect');
	set(handles.ac_serialstatus,'Backgroundcolor',[0 1 0]);
else
	try
		serports=serialportlist('available');
	catch
		serports=[];
	end
	if isempty(serports)
		serports='No available serial ports found!';
		set(handles.ac_connect,'String','Refresh');
	else
		set(handles.ac_connect,'String','Connect');
	end
	set(handles.ac_comport,'String',serports);
	set(handles.ac_serialstatus,'Backgroundcolor',[1 0 0]);
end


% Set default image colormap limits
gui.put('ac_lower_clim',0);
gui.put('ac_upper_clim',2^16);
delete(findobj('tag','shortcutlist'));
%Keyboard shortcuts
text(10,10,['Image acquisition keyboard shortcuts' sprintf('\n') 'CTRL SHIFT C : Toggle crosshair' sprintf('\n') 'CTRL SHIFT X : Toggle sharpness measure' sprintf('\n') 'CTRL SHIFT + : Increase display brightness' sprintf('\n') 'CTRL SHIFT - : Decrease display brightness' sprintf('\n') 'CTRL SHIFT K : Toggle between log and lin color scale' sprintf('\n') 'CTRL SHIFT H : Toggle histogram display'],'tag','shortcutlist','Color','black','BackgroundColor','white','VerticalAlignment','top');
try
	if ~alreadyconnected
		if ispref('PIVlab_ad','enable_ad') &&  getpref('PIVlab_ad','enable_ad') ==0
			%do not display ad
		else
			if exist('laser_device_id.mat','file') ~= 2
				hardware_Ad
			end
		end
	end
catch
end
if gui.retr('parallel')==1
	button = questdlg('It is highly recommended to turn off parallel processing during image capture to save RAM.','Shut down parallel pool?','OK','Cancel','OK');
	if strncmp(button,'OK',3)==1
		gui.put('parallel',1); %sets to "parallel on" and then presses the toggle button --> will turn off.
		misc.toggle_parallel_Callback
	end
end

