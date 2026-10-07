function store_last_acquisition_settings
% When PIVlab is closed: remembers the settings of the image acquisition panel and the last
% connected serial port as preferences (gui.apply_last_acquisition_settings).
settings = gui.collect_settings;
saved.acquisition = settings.acquisition;
saved.camera_settings = settings.camera_settings;
saved.popup_texts = struct();
names = fieldnames(settings.popup_texts);
for k = 1:numel(names)
    if isfield(settings.acquisition, names{k})
        saved.popup_texts.(names{k}) = settings.popup_texts.(names{k});
    end
end
gui.set_preference('last_acquisition_settings', saved);
selected_com_port = gui.retr('selected_com_port');
if ~isempty(selected_com_port)
    gui.set_preference('selected_com_port', selected_com_port);
end
end
