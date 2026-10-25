classdef mock_imaq_source < matlab.mixin.SetGet
    %MOCK_IMAQ_SOURCE Camera properties of a simulated OPTOcam 2/80 (videoinput.Source in the capture tests).
    %   Only the properties that the PIVlab driver uses; setting any other property is an error (like a
    %   misspelled property of the real camera).
    properties
        DeviceSerialNumber = ''
        DeviceLinkThroughputLimitMode = 'Off'
        DeviceLinkThroughputLimit = 0
        ExposureMode = 'Timed'
        ExposureTime = 10000
        TriggerSource = 'Line1'
        TriggerSelector = 'FrameStart'
        TriggerMode = 'Off'
        LineSelector = 'Line1'
        LineSource = ''
        LineMode = 'Input'
        LineInverter = 'False'
        ReverseX = 'False'
        ReverseY = 'False'
        Gain = 0
        AcquisitionFrameRateEnable = 'False'
        AcquisitionFrameRate = 100
        SensorReadoutTime = 6000      % us: about 160 fps maximum (full sensor)
        BslExposureStartDelay = 100
        DeviceTemperature = 40
        DeviceFirmwareVersion = 'mock/1.0'
        commands = {}                 % executeCommand calls (test statistics)
    end
    methods
        function obj = mock_imaq_source(serial)
            obj.DeviceSerialNumber = serial;
        end
        function executeCommand(obj, command)
            obj.commands{end + 1} = char(command);
        end
    end
end
