function check = check_result(action)
%CHECK_RESULT 2D check result of the camera that is shown, before the stereo calibration.
%   check = stereo.check_result('collect')   the result data of the GUI as one struct
%   stereo.check_result('apply')             puts gui.retr('stereo_check') (of the camera that was
%                                            just loaded by stereo.switch_camera) back into the GUI
% Before the stereo calibration, ANALYZE in stereo mode is a normal 2D analysis of the camera that is
% shown (stereo.redirect). Its result belongs to that camera: it is kept per camera ('stereo_check',
% stereo.camera_data_keys) and comes back when the camera is shown again. The stereo calibration
% removes it.
keys = {'resultslist', 'derived', 'ismean', 'manualdeletion', 'framemanualdeletion', 'streamlinesX', 'streamlinesY'};
check = struct();
switch action
    case 'collect'
        for i = 1:numel(keys)
            check.(keys{i}) = gui.retr(keys{i});
        end
    case 'apply'
        stored = gui.retr('stereo_check');
        for i = 1:numel(keys)
            if isstruct(stored) && isfield(stored, keys{i})
                gui.put(keys{i}, stored.(keys{i}));
            else
                gui.put(keys{i}, []);
            end
        end
        if isempty(gui.retr('resultslist'))
            gui.put('displaywhat', 1);
        end
end
end
