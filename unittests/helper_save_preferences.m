function prefs = helper_save_preferences()
%HELPER_SAVE_PREFERENCES Saves and removes the user's PIVlab preferences (gui.set_preference).
%   The tests start like a first start of PIVlab. The preferences are also saved in a file: if a
%   test run is stopped before its end,
%       load(fullfile(tempdir,'PIVlab_preferences_backup.mat')); helper_restore_preferences(prefs)
%   brings them back.
prefs = struct();
if ispref('PIVlab')
    prefs = getpref('PIVlab');
    rmpref('PIVlab');
end
backup = fullfile(tempdir, 'PIVlab_preferences_backup.mat');
if ~isfile(backup)   % a backup of a stopped run is not overwritten with the cleared preferences
    save(backup, 'prefs');
end
end
