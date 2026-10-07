function value = get_preference(name, default)
% A per-user preference of PIVlab (not part of settings files or sessions): last folder,
% Basic/Advanced mode, panel width, dark mode, last acquisition settings, ...
% Stored as MATLAB preference (group 'PIVlab'), which also works in the compiled app and in
% MATLAB Online. Returns default if the preference does not exist (or cannot be read).
value = default;
try
    if ispref('PIVlab', name)
        value = getpref('PIVlab', name);
    end
catch
end
end
