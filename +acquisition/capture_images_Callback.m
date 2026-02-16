function capture_images_Callback(~,~,~) %Menu item is called
filepath = fileparts(which('PIVlab_GUI.m'));
acquisition.select_capture_config_Callback
gui.switchui('multip24')
if verLessThan('matlab','9.7') %R2019b
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Newer Matlab required','Image capture and synchronizer control in PIVlab requires at least MATLAB version 9.7 (R2019b).', 'modal');
    return
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
    selected_com_port = gui.retr('selected_com_port');
    if ~isempty(selected_com_port) %remember last selected COM port.
        try
            set(handles.ac_comport,'Value',find(strcmpi(serports,selected_com_port)));
        catch
            disp('Last selected COM port not available.')
        end
    end
end

% Set default image colormap limits
gui.put('ac_lower_clim',0);
gui.put('ac_upper_clim',2^16);
delete(findobj('tag','shortcutlist'));
%Keyboard shortcuts
%text(10,10,['Image acquisition keyboard shortcuts' sprintf('\n') 'CTRL SHIFT C : Toggle crosshair' sprintf('\n') 'CTRL SHIFT X : Toggle sharpness measure' sprintf('\n') 'CTRL SHIFT + : Increase display brightness' sprintf('\n') 'CTRL SHIFT - : Decrease display brightness' sprintf('\n') 'CTRL SHIFT K : Toggle between log and lin color scale' sprintf('\n') 'CTRL SHIFT H : Toggle histogram display'],'tag','shortcutlist','Color','black','BackgroundColor','white','VerticalAlignment','top');
if gui.retr('parallel')==1
	button = gui.custom_msgbox('quest',getappdata(0,'hgui'),'Shut down parallel pool?','It is highly recommended to turn off parallel processing during image capture to save RAM.','modal',{'OK','Cancel'},'OK');
	if strncmp(button,'OK',3)==1
		gui.put('parallel',1); %sets to "parallel on" and then presses the toggle button --> will turn off.
		misc.toggle_parallel_Callback
	end
end
try
	if ~alreadyconnected
		if exist('laser_device_id.mat','file') ~= 2 %after a frist connection to a synchronizer, this will not be shown anymore.
			misc.hardware_Ad
		else
			gui.displogo
		end
	end
catch
end

