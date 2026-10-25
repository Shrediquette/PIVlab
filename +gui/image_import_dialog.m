function [files, sequencer, multitiff] = image_import_dialog(mode, start_folder)
%IMAGE_IMPORT_DIALOG Select the images to import (2D PIV or stereo-PIV).
%   [files, sequencer, multitiff] = gui.image_import_dialog('single', start_folder)
%       files: column cell of full file names, in the order in which they were added ([] = cancelled)
%   [files, sequencer, multitiff] = gui.image_import_dialog('stereo', start_folder)
%       files: {files of camera 1, files of camera 2} ([] = cancelled)
%   sequencer: image sequencing style, 0 = time resolved, 1 = pairwise, 2 = reference (also stored as GUI
%              data and preference 'sequencer')
%   multitiff: 1 if the first file (of camera 1) has several layers, else 0
% Left: the images of a folder (folder field, Up, Browse, recent folders, filter "names containing").
% Right: the selection (stereo: one list per camera). The selection keeps the order in which the files were
% added and may contain the same file more than once (e.g. the same image pairs with different settings).
% Clicking a file shows a preview with its size, bit depth, layers, compression and pco double image flag.
files = [];
multitiff = 0;
stereo_mode = strcmp(mode, 'stereo');
n_lists = 1;
if stereo_mode
    n_lists = 2;
end
if nargin < 2 || isempty(start_folder) || ~isfolder(start_folder)
    start_folder = pwd;
end
image_extensions = {'.bmp', '.jpg', '.jpeg', '.png', '.tif', '.tiff', '.b16'};
sequencing_names = {'Time resolved: [A+B], [B+C], [C+D], ...', 'Pairwise: [A+B], [C+D], [E+F], ...', ...
    'Reference: [A+B], [A+C], [A+D], ...'};
sequencer = gui.get_preference('sequencer', 1);
if ~isnumeric(sequencer) || ~isscalar(sequencer) || sequencer < 0 || sequencer > 2
    sequencer = 1;
end
recent = gui.get_preference('import_recent_folders', {});
if ~iscell(recent)
    recent = {};
end

% state
folder = '';
entry_names = {};     % names in the folder list
entry_isfolder = [];  % true: a folder (opens on double click)
picks = cell(1, n_lists);
for k = 1:n_lists
    picks{k} = cell(0, 1);
end
done = false;

%% window
width = 900;
height = 600;
if stereo_mode
    window_title = 'Import stereo images (camera 1 and camera 2)';
else
    window_title = 'Import images';
end
fig = figure('Units', 'pixels', 'Position', [0 0 width height], 'MenuBar', 'none', 'ToolBar', 'none', ...
    'NumberTitle', 'off', 'Name', window_title, 'Resize', 'off', 'WindowStyle', 'modal', 'IntegerHandle', 'off', ...
    'Visible', 'off', 'CloseRequestFcn', @cancel, 'Tag', 'image_import_dialog');
center_on_main_window(fig)

% folder row
uicontrol(fig, 'Style', 'text', 'String', 'Folder:', 'Position', [10 562 50 18], 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
folder_edit = uicontrol(fig, 'Style', 'edit', 'Position', [60 560 470 24], 'HorizontalAlignment', 'left', ...
    'Callback', @folder_typed, 'Tag', 'import_folder', 'TooltipString', 'Type a folder and press Enter');
uicontrol(fig, 'Style', 'pushbutton', 'String', 'Up', 'Position', [535 560 45 24], 'Callback', @folder_up, ...
    'TooltipString', 'Parent folder');
uicontrol(fig, 'Style', 'pushbutton', 'String', 'Browse...', 'Position', [585 560 75 24], 'Callback', @browse);
recent_popup = uicontrol(fig, 'Style', 'popupmenu', 'String', [{'Recent folders'}; recent(:)], 'Position', [665 560 225 24], ...
    'Callback', @recent_selected, 'Tag', 'import_recent');

% left: the images of the folder
uicontrol(fig, 'Style', 'text', 'String', 'Filter:', 'Position', [10 530 40 18], 'HorizontalAlignment', 'left');
filter_edit = uicontrol(fig, 'Style', 'edit', 'Position', [50 528 150 24], 'HorizontalAlignment', 'left', ...
    'Callback', @refresh_folder, 'Tag', 'import_filter', ...
    'TooltipString', ['Only names that contain this text, e.g. _A or cam1. With * (any characters) and ? (one ' ...
    'character) the whole name must match, e.g. cam1*_A or PIVlab_00??_B (not case sensitive)']);
folder_label = uicontrol(fig, 'Style', 'text', 'String', '', 'Position', [210 530 160 18], 'HorizontalAlignment', 'left');
% lists: tables (click and drag selects several entries) from MATLAB 2025 on, else list boxes
use_table = ~verLessThan('matlab', '25');
file_list = make_list(fig, [10 258 360 267], 'import_files', use_table, @file_list_clicked, ...
    @file_list_double_clicked, @file_list_key, 'Double click opens a folder. Drag, Shift / Ctrl: select several files, Ctrl+A: all.');

% preview: the whole width of the left column
preview_axes = axes(fig, 'Units', 'pixels', 'Position', [10 10 360 240], 'XTick', [], 'YTick', [], 'Box', 'on');

% right: the selection
lists = gobjects(1, n_lists);
list_labels = gobjects(1, n_lists);
list_names = cell(1, n_lists);
if stereo_mode
    list_top = [530 315];
    list_height = 160;
else
    list_top = 530;
    list_height = 375;
end
for k = 1:n_lists
    if stereo_mode
        name = sprintf('Camera %d', k);
        add_text = sprintf('Add to camera %d', k);
    else
        name = 'Selected images';
        add_text = 'Add';
    end
    list_names{k} = name;
    list_labels(k) = uicontrol(fig, 'Style', 'text', 'String', name, 'Position', [385 list_top(k) 505 18], ...
        'HorizontalAlignment', 'left', 'FontWeight', 'bold');
    lists(k) = make_list(fig, [385 list_top(k) - list_height - 3 505 list_height], sprintf('import_list%d', k), use_table, ...
        {@pick_list_clicked, k}, [], {@pick_list_key, k}, 'Delete: remove the selected files');
    y = list_top(k) - list_height - 33;
    uicontrol(fig, 'Style', 'pushbutton', 'String', add_text, 'Position', [385 y 125 26], 'FontWeight', 'bold', ...
        'Callback', {@add_files, k, false}, 'Tag', sprintf('import_add%d', k), ...
        'TooltipString', 'Add the files selected on the left (at the end)');
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Add all', 'Position', [515 y 80 26], ...
        'Callback', {@add_files, k, true}, 'Tag', sprintf('import_addall%d', k), ...
        'TooltipString', 'Add all files of the list on the left (at the end)');
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Remove', 'Position', [600 y 80 26], ...
        'Callback', {@remove_files, k}, 'Tag', sprintf('import_remove%d', k), 'TooltipString', 'Remove the selected files');
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Clear', 'Position', [685 y 80 26], ...
        'Callback', {@clear_files, k}, 'Tag', sprintf('import_clear%d', k), 'TooltipString', 'Remove all files');
end

% bottom right: sequencing style, count, Import / Cancel
uicontrol(fig, 'Style', 'text', 'String', 'Sequencing style:', 'Position', [385 92 110 18], 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
sequencing_popup = uicontrol(fig, 'Style', 'popupmenu', 'String', sequencing_names, 'Value', sequencer + 1, ...
    'Position', [495 90 270 24], 'Callback', @update_counts, 'Tag', 'import_sequencing', ...
    'TooltipString', 'How the images are combined to image pairs');
count_text = uicontrol(fig, 'Style', 'text', 'String', '', 'Position', [385 30 380 52], 'HorizontalAlignment', 'left', ...
    'Tag', 'import_count');
normal_colour = get(count_text, 'ForegroundColor'); % text colour of the theme (light / dark)
uicontrol(fig, 'Style', 'pushbutton', 'String', 'Import', 'Position', [775 52 115 50], 'FontWeight', 'bold', ...
    'FontSize', 11, 'ForegroundColor', [0 0.5 0], 'Callback', @import_files, 'Tag', 'import_ok');
uicontrol(fig, 'Style', 'pushbutton', 'String', 'Cancel', 'Position', [775 12 115 32], 'Callback', @cancel, ...
    'Tag', 'import_cancel');

open_folder(start_folder)
update_counts()
set(fig, 'Visible', 'on')
uiwait(fig)
if isgraphics(fig)
    delete(fig)
end
hgui = getappdata(0, 'hgui');
if ~isempty(hgui) && isgraphics(hgui)
    figure(hgui) % focus back to the PIVlab window
end
if ~done
    files = [];
end

%% nested functions (share the state above)

    function open_folder(new_folder)
        if ~isfolder(new_folder)
            return
        end
        folder = char(new_folder);
        set(folder_edit, 'String', folder);
        refresh_folder()
    end

    function refresh_folder(~, ~)
        d = dir(folder);
        names = {d.name};
        is_dir = [d.isdir];
        keep = ~strcmp(names, '.') & ~strcmp(names, '..');
        names = names(keep);
        is_dir = is_dir(keep);
        filter_text = strtrim(get(filter_edit, 'String'));
        image_names = {};
        folder_names = {};
        for i = 1:numel(names)
            if is_dir(i)
                folder_names{end + 1} = names{i}; %#ok<AGROW>
            else
                [~, ~, ext] = fileparts(names{i});
                if any(strcmpi(ext, image_extensions)) && name_matches(names{i}, filter_text)
                    image_names{end + 1} = names{i}; %#ok<AGROW>
                end
            end
        end
        image_names = sort(image_names);
        folder_names = sort(folder_names);
        entry_names = [folder_names, image_names];
        entry_isfolder = [true(1, numel(folder_names)), false(1, numel(image_names))];
        shown = cell(1, numel(entry_names));
        for i = 1:numel(entry_names)
            if entry_isfolder(i)
                shown{i} = ['[' entry_names{i} ']'];
            else
                shown{i} = entry_names{i};
            end
        end
        set_items(file_list, shown, true);
        set(folder_label, 'String', sprintf('%d images', numel(image_names)));
    end

    function folder_typed(~, ~)
        typed = strtrim(get(folder_edit, 'String'));
        if isfolder(typed)
            open_folder(typed)
        else
            set(folder_edit, 'String', folder);
            gui.custom_msgbox('error', fig, 'Folder', ['The folder "' typed '" does not exist.'], 'modal');
        end
    end

    function folder_up(~, ~)
        parent = fileparts(folder);
        if ~isempty(parent) && ~strcmp(parent, folder)
            open_folder(parent)
        end
    end

    function browse(~, ~)
        chosen = uigetdir(folder, 'Select the image folder');
        if ~isequal(chosen, 0)
            open_folder(chosen)
        end
    end

    function recent_selected(~, ~)
        choice = get(recent_popup, 'Value');
        set(recent_popup, 'Value', 1);
        if choice > 1 && choice - 1 <= numel(recent)
            if isfolder(recent{choice - 1})
                open_folder(recent{choice - 1})
            else
                gui.custom_msgbox('error', fig, 'Folder', ['The folder "' recent{choice - 1} '" does not exist any more.'], 'modal');
            end
        end
    end

    function file_list_clicked(~, ~)
        selected = get_selection(file_list);
        if isempty(selected)
            return
        end
        if strcmp(get(fig, 'SelectionType'), 'open') % second click of a double click
            % tables: the DoubleClickedFcn handles it. A new folder listing here would come too early: the
            % table still processes the double click with the row of the old listing (index error).
            if ~use_table
                file_list_double_clicked()
            end
            return
        end
        last = selected(end);
        if ~entry_isfolder(last)
            show_preview(fullfile(folder, entry_names{last}))
        end
    end

    function file_list_double_clicked(~, ~)
        % a folder opens; a file is added (2D import)
        selected = get_selection(file_list);
        if isempty(selected)
            return
        end
        last = selected(end);
        if entry_isfolder(last)
            open_folder(fullfile(folder, entry_names{last}))
        elseif ~stereo_mode
            add_files([], [], 1, false)
        end
    end

    function file_list_key(~, event)
        if strcmp(event.Key, 'a') && any(strcmp(event.Modifier, 'control'))
            set_selection(file_list, find(~entry_isfolder));
        elseif strcmp(event.Key, 'return') && ~stereo_mode
            add_files([], [], 1, false)
        end
    end

    function add_files(~, ~, k, all_files)
        if all_files
            selected = find(~entry_isfolder);
        else
            selected = get_selection(file_list);
            selected = selected(~entry_isfolder(selected));
        end
        if isempty(selected)
            return
        end
        new_files = cell(numel(selected), 1);
        for i = 1:numel(selected)
            new_files{i} = fullfile(folder, entry_names{selected(i)});
        end
        picks{k} = [picks{k}; new_files];
        refresh_pick_list(k)
        suggest_sequencing()
        update_counts()
    end

    function remove_files(~, ~, k)
        selected = get_selection(lists(k));
        if isempty(selected) || isempty(picks{k})
            return
        end
        picks{k}(selected) = [];
        refresh_pick_list(k)
        update_counts()
    end

    function clear_files(~, ~, k)
        picks{k} = cell(0, 1);
        refresh_pick_list(k)
        update_counts()
    end

    function refresh_pick_list(k)
        shown = cell(numel(picks{k}), 1);
        for i = 1:numel(picks{k})
            [~, name, ext] = fileparts(picks{k}{i});
            shown{i} = [name ext];
        end
        set_items(lists(k), shown, false);
    end

    function pick_list_clicked(~, ~, k)
        selected = get_selection(lists(k));
        if ~isempty(selected) && selected(end) <= numel(picks{k})
            file = picks{k}{selected(end)};
            show_preview(file)
        end
    end

    function pick_list_key(~, event, k)
        if any(strcmp(event.Key, {'delete', 'backspace'}))
            remove_files([], [], k)
        elseif strcmp(event.Key, 'a') && any(strcmp(event.Modifier, 'control'))
            set_selection(lists(k), 1:numel(picks{k}));
        end
    end

    function suggest_sequencing()
        % file names ending with A and B: pairwise (the style that fits double-frame cameras)
        if numel(picks{1}) < 2
            return
        end
        [~, first] = fileparts(picks{1}{1});
        [~, second] = fileparts(picks{1}{2});
        if ~isempty(first) && ~isempty(second) && strcmpi(first(end), 'A') && strcmpi(second(end), 'B')
            set(sequencing_popup, 'Value', 2);
        end
    end

    function update_counts(~, ~)
        style = get(sequencing_popup, 'Value') - 1;
        lines = {};
        for k = 1:n_lists
            n = numel(picks{k});
            if style == 1
                pairs = floor(n / 2);
            else
                pairs = max(n - 1, 0);
            end
            if stereo_mode
                prefix = sprintf('Camera %d: ', k);
            else
                prefix = '';
            end
            if n > 0 && layers_of(picks{k}{1}) > 1
                lines{end + 1} = sprintf('%s%d multi-layer files (image pairs are counted at the import)', prefix, n); %#ok<AGROW>
            else
                lines{end + 1} = sprintf('%s%d files = %d image pairs', prefix, n, pairs); %#ok<AGROW>
            end
            set(list_labels(k), 'String', sprintf('%s (%d files)', list_names{k}, n));
        end
        colour = normal_colour;
        if stereo_mode && numel(picks{1}) ~= numel(picks{2}) && ~isempty(picks{1}) && ~isempty(picks{2})
            lines{end + 1} = 'Both cameras need the same number of files.';
            colour = [0.8 0 0];
        end
        set(count_text, 'String', lines, 'ForegroundColor', colour);
    end

    function import_files(~, ~)
        for k = 1:n_lists
            if isempty(picks{k})
                if stereo_mode
                    message = sprintf('Add the images of camera %d.', k);
                else
                    message = 'Add the images to import.';
                end
                gui.custom_msgbox('error', fig, 'Import', message, 'modal');
                return
            end
        end
        sequencer = get(sequencing_popup, 'Value') - 1;
        gui.set_preference('sequencer', sequencer);
        hgui_now = getappdata(0, 'hgui');
        if ~isempty(hgui_now) && isgraphics(hgui_now)
            setappdata(hgui_now, 'sequencer', sequencer);
        end
        multitiff = double(layers_of(picks{1}{1}) > 1);
        % recent folders: the folders of the selection first, at most 10
        used = {};
        for k = 1:n_lists
            used{end + 1} = fileparts(picks{k}{1}); %#ok<AGROW>
        end
        for i = 1:numel(recent)
            used{end + 1} = recent{i}; %#ok<AGROW>
        end
        recent_new = {};
        for i = 1:numel(used)
            if ~any(strcmpi(recent_new, used{i}))
                recent_new{end + 1} = used{i}; %#ok<AGROW>
            end
        end
        gui.set_preference('import_recent_folders', recent_new(1:min(10, numel(recent_new))));
        if stereo_mode
            files = picks;
        else
            files = picks{1};
        end
        done = true;
        delete(fig) % ends uiwait (the window closes at once)
    end

    function cancel(~, ~)
        done = false;
        delete(fig) % ends uiwait
    end

    function show_preview(file)
        cla(preview_axes)
        try
            [~, ~, ext] = fileparts(file);
            info_text = '';
            warning_text = '';
            if strcmpi(ext, '.b16')
                img = double(import.f_readB16(file));
                img = img / max(img(:));
                info_text = 'b16 image';
            else
                if any(strcmpi(ext, {'.tif', '.tiff'}))
                    img = imread(file, 1); % first layer of a multi-TIFF
                else
                    img = imread(file);
                end
                if size(img, 3) > 3
                    img = img(:, :, 1:3); % Chronos workaround
                end
                info = imfinfo(file);
                compression = 'Uncompressed';
                if isfield(info, 'Compression')
                    compression = info(1).Compression;
                elseif isfield(info, 'CodingMethod')
                    compression = info(1).CodingMethod;
                end
                layers = numel(info);
                layer_word = 'layer';
                if layers > 1
                    layer_word = 'layers';
                end
                double_image = '';
                if isfield(info, 'Software') && strncmp(info(1).Software, 'PCO_Recorder', 10)
                    double_image = ', dual shutter';
                end
                info_text = sprintf('%d*%d - %d bit - %.1f MB\n%s - %d %s%s', info(1).Width, info(1).Height, ...
                    info(1).BitDepth, info(1).FileSize / 1024 / 1024, compression, layers, layer_word, double_image);
                if isempty(compression) || (~strcmpi(compression, 'Uncompressed') && ~strcmpi(compression, 'packbits'))
                    warning_text = 'Warning: compressed data';
                end
            end
            img = im2double(img);
            if size(img, 3) == 1
                img = imadjust(img, stretchlim(img));
            end
            image(preview_axes, 'CData', repmat(img, [1 1 3 / size(img, 3)]));
            axis(preview_axes, 'image', 'ij');
            set(preview_axes, 'XTick', [], 'YTick', []);
            text(preview_axes, 0.01, 0.99, info_text, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
                'BackgroundColor', 'k', 'Color', 'w', 'FontSize', 8, 'Interpreter', 'none', 'Margin', 1);
            text(preview_axes, 0.01, 0.01, 'contrast enhanced', 'Units', 'normalized', 'VerticalAlignment', 'bottom', ...
                'BackgroundColor', 'k', 'Color', [0.8 0.8 0.8], 'FontSize', 7, 'Interpreter', 'none', 'Margin', 1);
            if ~isempty(warning_text)
                text(preview_axes, 0.99, 0.01, warning_text, 'Units', 'normalized', 'HorizontalAlignment', 'right', ...
                    'VerticalAlignment', 'bottom', 'BackgroundColor', 'r', 'Color', 'k', 'FontWeight', 'bold', 'Interpreter', 'none');
            end
        catch
            text(preview_axes, 0.5, 0.5, 'No preview', 'Units', 'normalized', 'HorizontalAlignment', 'center');
        end
    end
end

function h = make_list(fig, position, tag, use_table, clicked, double_clicked, key, tooltip)
% a list with several selectable entries: a table (click and drag selects a range) or a list box. A double
% click: tables call double_clicked ([] = none); list boxes call clicked with SelectionType 'open' of the figure
if use_table
    h = uitable(fig, 'Position', position, 'Data', cell(0, 1), 'ColumnName', {}, 'RowName', {}, ...
        'ColumnWidth', {position(3) - 22}, 'ColumnEditable', false, 'SelectionType', 'cell', 'Multiselect', 'on', ...
        'RowStriping', 'off', 'ClickedFcn', clicked, 'DoubleClickedFcn', double_clicked, 'KeyPressFcn', key, 'Tag', tag, ...
        'Tooltip', tooltip, 'Interruptible', 'off', 'BusyAction', 'cancel'); % cell selection: click and drag selects a range
else
    h = uicontrol(fig, 'Style', 'listbox', 'Position', position, 'Max', 2, 'Min', 0, 'Callback', clicked, ...
        'KeyPressFcn', key, 'Tag', tag, 'TooltipString', tooltip);
end
end

function set_items(h, items, to_top)
% new entries of a list, nothing selected (to_top: show the first entry, else keep the scroll position)
if isa(h, 'matlab.ui.control.Table')
    h.Selection = [];
    h.Data = items(:);
    if to_top && ~isempty(items)
        try
            scroll(h, 'top');
        catch
        end
    end
else
    top = 1;
    if ~to_top
        top = min(max(1, get(h, 'ListboxTop')), max(1, numel(items)));
    end
    set(h, 'String', items, 'Value', [], 'ListboxTop', top);
end
end

function selected = get_selection(h)
% numbers of the selected entries (row vector, sorted)
if isa(h, 'matlab.ui.control.Table')
    selected = [];
    if ~isempty(h.Selection)
        selected = unique(h.Selection(:, 1))'; % cell selection: [row column]
    end
else
    selected = get(h, 'Value');
end
end

function set_selection(h, selected)
if isa(h, 'matlab.ui.control.Table')
    if isempty(selected)
        h.Selection = [];
    else
        h.Selection = [selected(:), ones(numel(selected), 1)];
    end
else
    set(h, 'Value', selected);
end
end

function tf = name_matches(name, filter_text)
% filter of the file list (not case sensitive). Without * or ?: the name contains the text. With * (any
% characters) or ? (one character): the whole name matches, with or without its extension (*_A = *_A.tif).
tf = true;
if isempty(filter_text)
    return
end
if ~any(filter_text == '*') && ~any(filter_text == '?')
    tf = contains(name, filter_text, 'IgnoreCase', true);
    return
end
pattern = regexptranslate('escape', filter_text);
pattern = strrep(pattern, '\*', '.*');
pattern = strrep(pattern, '\?', '.');
[~, base] = fileparts(name);
tf = ~isempty(regexpi(name, ['^' pattern '$'], 'once')) || ~isempty(regexpi(base, ['^' pattern '$'], 'once'));
end

function n = layers_of(file)
% number of layers of an image file (multi-TIFF), 1 for other files or when the file can not be read
n = 1;
[~, ~, ext] = fileparts(file);
if any(strcmpi(ext, {'.tif', '.tiff'}))
    try
        n = numel(imfinfo(file));
    catch
    end
end
end

function center_on_main_window(fig)
% centre on the PIVlab main window (on its monitor)
hgui = getappdata(0, 'hgui');
fig_pos = get(fig, 'Position');
if isempty(hgui) || ~isgraphics(hgui)
    movegui(fig, 'center')
    return
end
main_pos = getpixelposition(hgui);
pos = round(main_pos(1:2) + main_pos(3:4) / 2 - fig_pos(3:4) / 2);
monitors = get(0, 'MonitorPositions');
mon = monitors(1, :);
centre = main_pos(1:2) + main_pos(3:4) / 2;
for i = 1:size(monitors, 1)
    m = monitors(i, :);
    if centre(1) >= m(1) && centre(1) < m(1) + m(3) && centre(2) >= m(2) && centre(2) < m(2) + m(4)
        mon = m;
    end
end
pos(1) = min(max(pos(1), mon(1)), mon(1) + mon(3) - fig_pos(3));
pos(2) = min(max(pos(2), mon(2)), mon(2) + mon(4) - fig_pos(4) - 30);
set(fig, 'Position', [pos fig_pos(3:4)])
end
