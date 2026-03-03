function test_sync_Callback(~,~,~)
%gui.toolsavailable(0,'Busy, please wait...')
try
    S = serialportfind;
    delete(S)
    clear S
catch
end
cmd = ['powershell -Command "', ...
    'Get-CimInstance Win32_SerialPort | ', ...
    'Select-Object Name,DeviceID,Description | ', ...
    'ConvertTo-Csv -NoTypeInformation"'];

[status, result] = system(cmd);
driver_status='No installed CP210x driver found (driver not installed?)';
access_status = 'Could not open the COM port (COM port is in use by other app?)';
answer_status='Did not receive reply from the laser (turned off?)';

cp210xPattern = '.*CP210x.*\(COM(\d+)\)';
matches = regexp(result, cp210xPattern, 'tokens');

if isempty(matches)
    driver_status='No installed CP210x driver found (driver not installed?)';
else
    % Extract COM port strings
    comPorts = cellfun(@(c) ['COM' c{1}], matches, 'UniformOutput', false);
    driver_status=sprintf('CP210x device found on port: %s', strjoin(comPorts, ', '));
    % Step 2: Try to open the first available CP210x port
    selectedPort = comPorts{1};
    try
        s = serialport(selectedPort, 9600,'Timeout',1); % Use appropriate baud rate here
        configureTerminator(s,'CR/LF');
        flush(s);                           % Optional: clear buffers
        access_status = ['Successfully opened ' comPorts{1}];
        string1='WhoAreYou?';
        serial_answer='';
        attempts=0;
        while isempty(serial_answer) && attempts <= 2
            flush(s)
            pause(0.1)
            writeline(s,string1);
            pause(0.3)
            warning off
            serial_answer=readline(s);
            attempts=attempts+1;
        end
        if ~isempty(serial_answer)
            answer_status=['Received reply from the laser: ' convertStringsToChars(serial_answer)];
        else
            answer_status=['Did not receive reply from the laser after ' num2str(attempts) ' attempts (laser turned off?)'];
        end
    catch e
        access_status = 'Could not open the COM port (COM port is in use by other app?)';
        answer_status=['Did not receive reply from the laser (laser turned off?)'];
    end
end
button=gui.custom_msgbox('quest',getappdata(0,'hgui'),'Synchronizer test',['Information about the wireless dongle connection: '  driver_status ' ; ' access_status ' ; ' answer_status newline 'Activate synchronizer / laser test?'],'modal',{'OK','Cancel'},'Cancel');
if strcmp(button,'OK')
    serout=['TALKINGTO:' convertStringsToChars(serial_answer) ':sequence:10000:0,0:100,105:110,120:120,135:130,150:140,165:'];
    writeline(s,serout);
    pause(0.3)
    warning off
    answer=readline(s);
    if strcmpi(answer,'Sequence:OK')
        serout=['TALKINGTO:' convertStringsToChars(serial_answer) ':start'];
        writeline(s,serout);
    else
        disp('sequence not accepted')
    end
    gui.custom_msgbox('quest',getappdata(0,'hgui'),'Synchronizer test','Stop synchronizer / laser test?','modal',{'OK'},'OK');
    serout=['TALKINGTO:' convertStringsToChars(serial_answer) ':stop'];
    writeline(s,serout);pause(0.25)
    clear s  % Close and release the port
end
%gui.toolsavailable(1)
end