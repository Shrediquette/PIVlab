%% Tests of the automatic OPTOcam detection (2/80 or 20/9), no hardware, no GUI
%
% PIVlab_capture_OPTOcam_model tells the models apart: the 20/9 by the USB vendor ID in its device name,
% the 2/80 by its user ID (set before shipping, not part of the device name).
% PIVlab_capture_OPTOcam_detect lists the connected models (simulated cameras: unittests/mocks_imaq).
% The device names of the 20/9 here are made up, they only contain the vendor ID that is matched.
%
% Run with:
%   runtests('unittests/test_acq_optocam_detect.m')

function tests = test_acq_optocam_detect
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = helper_root();
addpath(root);
addpath(fullfile(root, 'PIVlab_capture_resources', 'OPTOcam'));
testCase.TestData.Mocks = fullfile(root, 'unittests', 'mocks_imaq');
addpath(testCase.TestData.Mocks); % in front of the Image Acquisition Toolbox
end

function teardownOnce(testCase)
imaqreset(); % the simulated cameras (still on the path)
rmpath(testCase.TestData.Mocks);
end

% -------------------------------------------------------------------------

function test_2_80_from_user_id(testCase)
name = 'Camera (40000001)';
verifyEqual(testCase, PIVlab_capture_OPTOcam_model(name, 'OPTOcam 2/80'), '2_80');
verifyEqual(testCase, PIVlab_capture_OPTOcam_model(name, 'optocam 2-80'), '2_80', 'case insensitive');
verifyEqual(testCase, PIVlab_capture_OPTOcam_model(name, 'OPTOCAM280'), '2_80');
verifyEqual(testCase, PIVlab_capture_OPTOcam_model(name, 'OPTOcam_2_80'), '2_80');
verifyEqual(testCase, PIVlab_capture_OPTOcam_model(name, 'OPTOcam'), '', 'OPTOcam without model');
verifyEqual(testCase, PIVlab_capture_OPTOcam_model(name, 'Camera 2/80'), '', 'model without OPTOcam');
verifyEqual(testCase, PIVlab_capture_OPTOcam_model(name, ''), '', 'no user ID set');
verifyEqual(testCase, PIVlab_capture_OPTOcam_model(name), '', 'user ID not read');
verifyEqual(testCase, PIVlab_capture_OPTOcam_model('OPTOcam 2/80 (40000001)'), '', 'only the user ID counts, not the name');
end

function test_20_9_from_name(testCase)
verifyEqual(testCase, PIVlab_capture_OPTOcam_model('mvBlueFOX3 (USB\VID164C&PID5533)'), '20_9');
verifyEqual(testCase, PIVlab_capture_OPTOcam_model('cam (VID164C)', 'OPTOcam 2/80'), '20_9', 'the 20/9 is checked first');
verifyEqual(testCase, PIVlab_capture_OPTOcam_model('Basler acA2000-165um (2161)'), '');
verifyEqual(testCase, PIVlab_capture_OPTOcam_model(''), '');
verifyEqual(testCase, PIVlab_capture_OPTOcam_model([], []), '');
end

function test_detect_connected_models(testCase)
set_devices({});
verifyEqual(testCase, detect(), {});
set_devices({'Camera (40000001)'}, {'OPTOcam 2/80'});
verifyEqual(testCase, detect(), {'2_80'});
set_devices({'Camera (40000001)', 'Camera (40000002)'}, {'OPTOcam 2/80', 'OPTOcam 2/80'});
verifyEqual(testCase, detect(), {'2_80'}, 'stereo: two 2/80 are one model');
set_devices({'Camera (40000001)'}, {''});
verifyEqual(testCase, detect(), {}, 'no user ID set');
set_devices({'cam (VID164C)'});
verifyEqual(testCase, detect(), {'20_9'});
set_devices({'Camera (40000001)', 'cam (VID164C)', 'Basler acA2000-165um (2161)'}, {'OPTOcam 2/80', '', ''});
verifyEqual(testCase, detect(), {'20_9', '2_80'}, 'both models, other cameras ignored');
end

function test_user_id_of_an_open_camera(testCase)
% a camera that PIVlab keeps open is not opened a second time
set_devices({'Camera (40000001)'}, {'OPTOcam 2/80'});
vid = videoinput('gentl', 1, 'Mono8');
verifyEqual(testCase, PIVlab_capture_OPTOcam_user_id('gentl', 1), 'OPTOcam 2/80');
verifyNumElements(testCase, imaqfind, 1, 'no second videoinput');
delete(vid);
verifyEqual(testCase, PIVlab_capture_OPTOcam_user_id('gentl', 1), 'OPTOcam 2/80');
verifyEmpty(testCase, imaqfind, 'the briefly opened camera is closed again');
end

function test_likely_cameras_first(testCase)
% serial number (in brackets at the end of the device name) starting with 4 first; a 20/9 is left out
info = struct('DeviceName', {'Camera (21932848)', 'cam (VID164C)', 'Camera (41932848)', 'Camera', 'Camera (40000002)'});
verifyEqual(testCase, PIVlab_capture_OPTOcam_candidates(info), [3 5 1 4]);
verifyEmpty(testCase, PIVlab_capture_OPTOcam_candidates(struct('DeviceName', {})));
% detection opens only the likely camera when it is a 2/80
set_devices({'Camera (21932848)', 'Camera (41932848)'}, {'', 'OPTOcam 2/80'});
reg = getappdata(0, 'mock_imaq');
reg.open_time = 0.3; % opening a camera takes time
setappdata(0, 'mock_imaq', reg);
tic;
verifyEqual(testCase, detect(), {'2_80'});
verifyLessThan(testCase, toc, 0.55, 'only one camera opened');
end

% -------------------------------------------------------------------------

function models = detect()
[models, imaq_error] = PIVlab_capture_OPTOcam_detect();
assert(imaq_error == 0);
end

function set_devices(names, user_ids)
if nargin < 2
    user_ids = repmat({''}, size(names));
end
mock_imaq_setup(0, 80);
reg = getappdata(0, 'mock_imaq');
reg.devices = struct('name', names, 'serial', repmat({'1'}, size(names)), 'user_id', user_ids);
setappdata(0, 'mock_imaq', reg);
end
