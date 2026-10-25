function out = imaqhwinfo(adaptor)
%IMAQHWINFO Simulated cameras (capture tests): the devices of getappdata(0,'mock_imaq') on the 'gentl' adaptor.
reg = getappdata(0, 'mock_imaq');
if nargin == 0
    out = struct('InstalledAdaptors', {{'gentl'}});
    return
end
out.AdaptorName = adaptor;
device_info = struct('DeviceName', {}, 'DeviceID', {}, 'SupportedFormats', {});
for k = 1:numel(reg.devices)
    device_info(k).DeviceName = reg.devices(k).name;
    device_info(k).DeviceID = k;
    device_info(k).SupportedFormats = {'Mono8', 'Mono12'};
end
out.DeviceInfo = device_info;
end
