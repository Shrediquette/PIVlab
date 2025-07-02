function serial_info(~,~,~)
gui.toolsavailable(0,'Busy, please wait...')
try
    S = serialportfind;
    delete(S)
    clear S
catch
end
[status, result] = system('wmic path Win32_SerialPort get Name,DeviceID,Description');
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

        clear s  % Close and release the port
    catch e
        access_status = 'Could not open the COM port (COM port is in use by other app?)';
        answer_status=['Did not receive reply from the laser (laser turned off?)'];
    end
end
msgbox(['Information about the wireless dongle connection:' newline newline driver_status newline access_status newline answer_status],'Dongle status')
gui.toolsavailable(1)
end