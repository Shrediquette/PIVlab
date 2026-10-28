function mock_imaq_setup(n_cameras, trigger_fps)
%MOCK_IMAQ_SETUP Simulated OPTOcam 2/80 cameras for the capture tests (unittests/mocks_imaq on the path).
%   mock_imaq_setup(n_cameras, trigger_fps): n_cameras connected cameras, hardware trigger rate in frames/s.
%   The device listed first has the HIGHER serial number, so that camera 1 of a stereo setup (lower serial
%   number by default) is the second device. Change getappdata(0,'mock_imaq') for other cases:
%   drop{k} = trigger numbers that device k misses, open_time = seconds to open a camera, pair_shift = shift of
%   the B frames (PIV pair), images{k} = image files as frame content, stale{k} = trigger numbers whose frame
%   device k delivers incompletely (rows 10 to the end from the frame 3 frames earlier, like a slow USB link).
imaqreset();
serials = {'40000002', '40000001', '40000003'};
devices = struct('name', {}, 'serial', {});
for k = 1:n_cameras
    devices(k).name = ['Basler a2A1920-160umBAS (' serials{k} ')'];
    devices(k).serial = serials{k};
end
reg.devices = devices;
reg.trigger_fps = trigger_fps;
reg.drop = cell(1, max(n_cameras, 1));
reg.stale = cell(1, max(n_cameras, 1));
reg.open_time = 0;
reg.pair_shift = [1 3]; % [dy dx] px: every even frame (B of a PIV pair) is the template moved by this; [0 0] = static
setappdata(0, 'mock_imaq', reg);
setappdata(0, 'mock_imaq_objects', {});
end
