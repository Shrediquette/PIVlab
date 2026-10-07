function apply_last_acquisition_settings
% At startup: the image acquisition panel gets the settings it had when PIVlab was closed the
% last time (preference 'last_acquisition_settings', see gui.store_last_acquisition_settings).
% Everything else starts with the default settings.
saved = gui.get_preference('last_acquisition_settings', []);
if isstruct(saved)
    gui.apply_settings(saved, {'acquisition'}, true);
end
gui.put('selected_com_port', gui.get_preference('selected_com_port', [])); % last connected serial port
end
