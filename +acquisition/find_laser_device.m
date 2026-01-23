function laser_device_id = find_laser_device
gui.put('sync_type',[]); %remove any eexpectation about connected synchronizer
serpo=gui.retr('serpo');
try
    serpo.Port;
    alreadyconnected=1;
catch
    alreadyconnected=0;
end
if alreadyconnected
    if exist('laser_device_id.mat','file') == 2
        old_laser_device_id = load('laser_device_id.mat','id');
        old_laser_device_id = old_laser_device_id.id;
    else
        old_laser_device_id='%';
    end
    string1='WhoAreYou?';
    string2='WhichFirmWare?';
    string3='WarningSignEnable!';
    try
        gui.toolsavailable(0,'Searching for synchronizer...')
        serial_answer='';
        attempts=0;
        while isempty(serial_answer) && attempts <= 2
            flush(serpo)
            pause(0.1)
            writeline(serpo,string1);
            pause(0.3)
            warning off
            serial_answer=readline(serpo);
            pause(0.1)
            attempts=attempts+1;
        end

        disp(['Connected to: ' convertStringsToChars(serial_answer)])
        handles=gui.gethand;
        if contains(serial_answer,'oltSync:') %decide which synchronizer hardware is connected
            gui.put('sync_type','oltSync') %Waldemars Sync
            disp('oltSync detected')
            %set(handles.ac_enable_ext_trigger,'Visible','off')
            set(handles.ac_enable_ext_trigger_oltsync,'Visible','on')
            set(handles.ac_auto_interframe,'Visible','off','enable','off')
        else
            if ~isempty(serial_answer)
                gui.put('sync_type','xmSync') %Williams Sync
                disp('xmSync detected')
                %set(handles.ac_enable_ext_trigger,'Visible','on')
                set(handles.ac_enable_ext_trigger_oltsync,'Visible','off') %not displayed for old synchronizer
            end
        end
        gui.toolsavailable(1)
        warning on
    catch
        disp('Error sending WhoAreYou')
        gui.toolsavailable(1)
    end
    try
        writeline(serpo,string2);
        pause(0.3)
        warning off
        firmware_version=readline(serpo);
        warning on
        if isempty(firmware_version)
            firmware_version='pre feb 22';
        else
            firmware_version=convertStringsToChars(firmware_version);
            if contains(firmware_version,'oltSync:')
                firmware_version = firmware_version(strfind(firmware_version,'oltSync:')+8 : end);
                misc.check_sync_firmware(firmware_version)
            end
        end
        disp(['Firmware: ' firmware_version])

        delete(findobj('tag','laser_info_box'));
        try
            Kinder=get(gca,'Children');
            for k=1:size(Kinder,1)
                if isprop(Kinder(k),'CData')
                    img_size=size(Kinder(k).CData,1);
                    break
                end
            end
            if ~isempty(serial_answer)
                text(10,img_size*0.95,['Connected to:  ' convertStringsToChars(serial_answer) sprintf('\n') 'Firmware:  ' convertStringsToChars(firmware_version)],'tag','laser_info_box','Color','black','BackgroundColor','green','VerticalAlignment','bottom','interpreter','none');
            else
                delete(findobj('tag','laser_info_box'))
            end
        catch
        end
    catch
        disp('Error sending WhichFirmware')
    end
    try
        pause(0.3)
        writeline(serpo,string3); %enable the lighting of the laser warning sign
        pause(0.2)
    catch
        disp('Could not enable Laser warning sign')
    end
    %%debug messages
    %{
disp('---------')
	disp(['Port is: ' serpo.Port])
	disp(['Terminator set to: ' serpo.Terminator])
	disp(['String written: ' string1])
	disp(['String written: ' string2])
	disp(['Answer: ' convertStringsToChars(serial_answer)])
disp('---------')
    %}
    if isempty(serial_answer)
        gui.custom_msgbox('warn',getappdata(0,'hgui'),'No laser found',['No laser found.' sprintf('\n') 'Is the laser turned on?' sprintf('\n') 'Please try again.'],'modal');
    end
    if strncmp(old_laser_device_id,serial_answer,20)==0 %if last laser ID DOES NOT equal current laser ID
        serial_answer_cleaned = convertStringsToChars(serial_answer);
        serial_answer_cleaned(isstrprop(serial_answer_cleaned, 'graphic'));
        if strcmp (gui.retr('sync_type'), 'oltSync')
            serial_answer_cleaned = ['oltSync' extractAfter(serial_answer_cleaned,'oltSync')]; %this should really remove any weird characters in the serial string....
        end
        get_laser_id = inputdlg(['Please enter the ID of your laser / synchronizer.' sprintf('\n') 'It can be found on the sticker on the device.' sprintf('\n') 'Firmware: ' convertStringsToChars(firmware_version)],'First time connection',1,{serial_answer_cleaned});
        if ~isempty(get_laser_id)
            id=get_laser_id{1};
            filepath = fileparts(which('PIVlab_GUI.m'));
            save (fullfile(filepath, 'PIVlab_capture_resources', 'laser_device_id.mat'),'id')
        end
    end
    laser_device_id = load('laser_device_id.mat','id');
    laser_device_id = laser_device_id.id;
else
    acquisition.no_dongle_msgbox
end