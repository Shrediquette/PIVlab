function helper_restore_preferences(prefs)
%HELPER_RESTORE_PREFERENCES Brings back the PIVlab preferences saved by helper_save_preferences.
if ispref('PIVlab')
    rmpref('PIVlab');
end
names = fieldnames(prefs);
for k = 1:numel(names)
    setpref('PIVlab', names{k}, prefs.(names{k}));
end
backup = fullfile(tempdir, 'PIVlab_preferences_backup.mat');
if isfile(backup)
    delete(backup);
end
end
