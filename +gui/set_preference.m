function set_preference(name, value)
% Stores a per-user preference of PIVlab (see gui.get_preference).
try
    setpref('PIVlab', name, value);
catch err
    disp(['-> Could not store the preference ' name ': ' err.message])
end
end
