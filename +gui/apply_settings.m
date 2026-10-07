function notes = apply_settings(settings, groups, include_session_only)
% Writes settings (struct as made by gui.collect_settings) into the controls of the PIVlab window.
%   groups                cellstr, the groups to change, e.g. {'analysis','calibration','masks'}
%   include_session_only  true when a session is loaded: also the controls marked
%                         'UserData','session_only' in gui.generateUI (their data, e.g. the
%                         camera parameters, is only stored in sessions)
% The callbacks of the controls do not run: no dialogs, no data changes. Afterwards
% gui.update_dependent_controls sets Enable / Visible. A setting that is missing in settings
% gets its default value; a setting that this PIVlab version does not know is ignored.
% Popup menus select the stored text; if the list does not contain it (yet), see below.
% notes: cellstr with what could not be applied (also shown in the command window).
if nargin < 3
    include_session_only = false;
end
hgui = getappdata(0, 'hgui');
default = gui.default_settings;
[controls, tags] = gui.setting_controls(hgui);
popup_texts = struct();
if isfield(settings, 'popup_texts')
    popup_texts = settings.popup_texts;
end
pending = gui.retr('pending_popup_texts');
if ~isstruct(pending)
    pending = struct();
end
notes = {};
for g = 1:numel(groups)
    group = groups{g};
    if ~isfield(default, group)
        continue
    end
    stored = struct();
    if isfield(settings, group) && isstruct(settings.(group))
        stored = settings.(group);
    end
    names = fieldnames(default.(group));
    for n = 1:numel(names)
        tag = names{n};
        control = [];
        for k = 1:numel(tags)
            if strcmp(tags{k}, tag)
                control = controls(k);
            end
        end
        if isempty(control)
            continue
        end
        if ~include_session_only && ischar(control.UserData) && strcmp(control.UserData, 'session_only')
            continue
        end
        if isfield(stored, tag)
            value = stored.(tag);
        else
            value = default.(group).(tag);
        end
        text = '';
        if isfield(popup_texts, tag)
            text = popup_texts.(tag);
        end
        [ok, is_pending, note] = gui.set_setting_control(control, value, text);
        if ~ok
            notes{end+1} = note; %#ok<AGROW>
        end
        if is_pending || (~ok && ~isempty(text)) % the list may get this item later (one more try)
            pending.(tag) = text;
        elseif isfield(pending, tag)
            pending = rmfield(pending, tag);
        end
    end
    unknown = setdiff(fieldnames(stored), names);
    for u = 1:numel(unknown)
        notes{end+1} = ['Setting "' unknown{u} '" is not known in this PIVlab version and was ignored.']; %#ok<AGROW>
    end
end
gui.put('pending_popup_texts', pending);
if any(strcmp(groups, 'acquisition')) % the camera windows belong to the image acquisition
    camera_settings = struct();
    if isfield(settings, 'camera_settings') && isstruct(settings.camera_settings)
        camera_settings = settings.camera_settings;
    end
    % The bit depth of the OPTOcam 2/80 is also set in the synchronizer (SET_CAM_BITS), only when
    % it is changed in its window. Loading must not change it without telling the synchronizer.
    if isfield(camera_settings, 'OPTOcam_bits')
        camera_settings = rmfield(camera_settings, 'OPTOcam_bits');
    end
    current_bits = gui.camera_setting('OPTOcam_bits');
    if ~isempty(current_bits)
        camera_settings.OPTOcam_bits = current_bits;
    end
    gui.put('camera_settings', camera_settings);
end
gui.update_dependent_controls;
for k = 1:numel(notes)
    disp(['-> ' notes{k}])
end
end
