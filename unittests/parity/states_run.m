function states_run(outfile, root)
%STATES_RUN Click through the GUI rules for enabled / visible controls and record the states.
%   states_run(outfile)         PIVlab of this repository
%   states_run(outfile, root)   another PIVlab folder (e.g. a git worktree of main)
% Every scenario starts a fresh PIVlab window, changes controls like a user (value + the
% control's own callback) and records, after every step, Enable / Visible of all tagged controls
% and panels and the text of text / edit fields. Controls renamed in PIVlab 4 are stored under
% their new Tag (tag_renames.csv), so two versions can be compared with states_compare.
% A screenshot of the window is saved at the end of every scenario (next to outfile).
here = fileparts(mfilename('fullpath'));
if nargin < 2 || isempty(root)
    root = fileparts(fileparts(here));
end
prefs = struct();
if ispref('PIVlab')
    prefs = getpref('PIVlab');
    rmpref('PIVlab');
end
setpref('PIVlab','dark_mode_theme',1);
cd(root); addpath(root);
setappdata(0,'PIVlabTestMode',true);
warning('off','all');
pngdir = fileparts(outfile);
jet = cell(4,1);
for i = 1:2
    jet{2*i-1} = fullfile(root,'Example_data',sprintf('Jet_%04dA.jpg',i));
    jet{2*i}   = fullfile(root,'Example_data',sprintf('Jet_%04dB.jpg',i));
end

% {name, setup, panel, steps}; setup: '' (empty window), 'images', 'results' (analysed),
% 'calibrated' (analysed + calibrated)
C = {
    'algorithms',     'images',  'multip04', {'algorithm_selection',2; 'algorithm_selection',3; 'algorithm_selection',4; 'algorithm_selection',1}
    'passes_on',      'images',  'multip04', {'pass2_enable',0; 'pass2_enable',1; 'pass3_enable',1; 'pass4_enable',1}
    'passes_off',     'images',  'multip04', {'pass4_enable',1; 'pass3_enable',0; 'pass2_enable',0; 'pass4_enable',1}
    'pass_sizes',     'images',  'multip04', {'pass2_size','48'; 'pass3_enable',1; 'pass3_size','20'; 'pass4_enable',1; 'pass4_size','12'}
    'repeat_last',    'images',  'multip04', {'repeat_last_enable',1; 'pass2_enable',0; 'pass2_enable',1; 'repeat_last_enable',0}
    'algo_ensemble',  'images',  'multip04', {'pass3_enable',1; 'repeat_last_enable',1; 'algorithm_selection',2; 'algorithm_selection',1}
    'algo_ofv',       'images',  'multip04', {'pass4_enable',1; 'algorithm_selection',4; 'algorithm_selection',3; 'algorithm_selection',1}
    'derive_scale',   'results', 'multip08', {'autoscaler',0; 'autoscaler',1}
    'derive_smooth',  'results', 'multip08', {'smooth_mode',2; 'smooth_mode',3; 'smooth_mode',4; 'smooth_mode',1}
    'derive_list',    'results', 'multip08', {'derivchoice',2; 'derivchoice',3; 'derivchoice',10; 'derivchoice',11; 'derivchoice',1}
    'derive_units',   'calibrated', 'multip08', {'derivchoice',2; 'derivchoice',3; 'derivchoice',6; 'derivchoice',8; 'derivchoice',12}
    'vector_scale',   'results', 'multip09', {'autoscale_vec',0; 'autoscale_vec',1}
    'mask_modes',     'images',  'multip25', {'mask_basic_expert',2; 'mask_bright_or_dark',2; 'mask_bright_or_dark',3; 'mask_bright_or_dark',1; 'mask_basic_expert',1}
    'mask_bright',    'images',  'multip25', {'mask_basic_expert',2; 'binarize_enable',1; 'binarize_enable',0}
    'mask_dark',      'images',  'multip25', {'mask_basic_expert',2; 'mask_bright_or_dark',2; 'binarize_enable_2',1; 'binarize_enable_2',0}
    'mask_lowcontr',  'images',  'multip25', {'mask_basic_expert',2; 'mask_bright_or_dark',3; 'low_contrast_mask_enable',1; 'low_contrast_mask_enable',0}
    'particles',      '',        'multip15', {'flow_sim',2; 'singledoubleoseen',2; 'singledoubleoseen',1; 'flow_sim',3; 'flow_sim',4; 'flow_sim',5; 'flow_sim',1; 'singledoublerankine',2; 'singledoublerankine',1}
    'export_formats', 'results', 'multip16', {'export_still_or_animation',2; 'export_still_or_animation',3; 'export_still_or_animation',4; 'export_still_or_animation',5; 'export_still_or_animation',6; 'export_still_or_animation',1}
    'extraction',     'results', 'multip12', {'draw_what',2; 'draw_what',3; 'draw_what',1}
    'intensity',      'images',  'multip03', {'autolimit_enable',0; 'minintens','-0.3'; 'maxintens','1.7'; 'minintens','0.2'; 'maxintens','0.9'}
    };
S = struct();
for k = 1:size(C,1)
    name = C{k,1};
    try
        start_pivlab();
        prepare(C{k,2}, jet);
        open_panel(C{k,3});
        S.(name).s0 = snapshot();
        steps = C{k,4};
        for j = 1:size(steps,1)
            click(steps{j,1}, steps{j,2});
            S.(name).(sprintf('s%d_%s', j, steps{j,1})) = snapshot();
        end
        shot(fullfile(pngdir, ['states_' name '.png']));
        fprintf('STATES %s OK\n', name);
    catch err
        S.(name).error = [err.message ' @ ' err.stack(1).name ':' num2str(err.stack(1).line)];
        fprintf('STATES %s ERROR %s\n', name, S.(name).error);
    end
    close_pivlab();
end

% Basic / Advanced mode, also after changing the algorithm and the mask mode
try
    start_pivlab();
    prepare('images', jet);
    S.mode.advanced_start = snapshot();
    open_panel('multip04'); click('algorithm_selection', 4);
    open_panel('multip25'); click('mask_basic_expert', 2);
    S.mode.advanced_changed = snapshot();
    gui.request_mode_switch('basic'); drawnow;
    S.mode.basic = snapshot();
    shot(fullfile(pngdir, 'states_mode_basic.png'));
    open_panel('multip04'); click('algorithm_selection', 3);
    S.mode.basic_dcc = snapshot();
    click('algorithm_selection', 1);
    open_panel('multip08');
    S.mode.basic_derive = snapshot();
    gui.request_mode_switch('advanced'); drawnow;
    S.mode.advanced_again = snapshot();
    open_panel('multip04'); click('algorithm_selection', 2);
    gui.request_mode_switch('basic'); drawnow;
    gui.request_mode_switch('advanced'); drawnow;
    S.mode.advanced_after_ensemble = snapshot();
    fprintf('STATES mode OK\n');
catch err
    S.mode.error = [err.message ' @ ' err.stack(1).name ':' num2str(err.stack(1).line)];
    fprintf('STATES mode ERROR %s\n', S.mode.error);
end
close_pivlab();
% a fresh start in Basic mode
try
    gui.set_preference('ui_mode', 'basic');
catch
    setpref('PIVlab', 'ui_mode', 'basic');
end
try
    start_pivlab();
    prepare('images', jet);
    S.mode.basic_start = snapshot();
    fprintf('STATES mode_start OK\n');
catch err
    S.mode.error_start = err.message;
end
close_pivlab();

save(outfile, '-struct', 'S');
if ispref('PIVlab'), rmpref('PIVlab'); end
f = fieldnames(prefs);
for k = 1:numel(f)
    setpref('PIVlab', f{k}, prefs.(f{k}));
end
end

%% ------------------------------------------------------------------
function prepare(what, jet)
if isempty(what)
    return
end
gui.put('sequencer',1); gui.put('multitiff',0); gui.put('video_selection_done',0);
ps = struct('name',jet(:),'isdir',num2cell(false(numel(jet),1)));
import.loadimgsbutton_Callback([],[],0,ps); drawnow;
if strcmp(what,'images')
    return
end
h = hand();
set(h.update_display_checkbox,'Value',0);
piv.AnalyzeAll_Callback([],[],[]); drawnow;
if strcmp(what,'calibrated')
    gui.put('pointscali',[10 10; 110 10]);
    set(h.realdist,'String','10'); set(h.time_inp,'String','100');
    calibrate.apply_cali_Callback([],[],[]); drawnow;
end
end

function open_panel(p)
% the panels are opened like from the menu
switch p
    case 'multip08', plot.derivs_Callback([],[],[]);
    case 'multip09', gui.switchui('multip09');
    case 'multip12', gui.switchui('multip12');
    case 'multip16', export.pixel_data([],[],[]);
    otherwise,       gui.switchui(p);
end
drawnow;
end

function click(tag, value)
% set a control like a user and run its callback
h = hand();
c = h.(tag);
if ischar(value)
    set(c, 'String', value);
else
    set(c, 'Value', value);
end
cb = get(c, 'Callback');
if isa(cb, 'function_handle')
    cb(c, []);
elseif iscell(cb)
    feval(cb{1}, c, [], cb{2:end});
elseif ischar(cb) && ~isempty(cb)
    eval(cb);
end
drawnow;
end

function S = snapshot()
% Enable / Visible of all tagged controls and panels, text of text and edit fields
hgui = getappdata(0,'hgui');
c = [findall(hgui,'Type','uicontrol'); findall(hgui,'Type','uipanel')];
R = tag_renames();
S = struct();
for k = 1:numel(c)
    t = get(c(k),'Tag');
    if isempty(t) || ~isvarname(t), continue; end
    idx = find(strcmp(R.old, t), 1);
    if ~isempty(idx), t = R.new{idx}; end
    e = '';
    if isprop(c(k),'Enable'), e = char(string(get(c(k),'Enable'))); end
    s = [e '/' char(string(get(c(k),'Visible')))];
    if isprop(c(k),'Style') && any(strcmp(get(c(k),'Style'), {'edit','text'}))
        str = get(c(k),'String');
        if iscell(str), str = strjoin(str, ' | '); end
        if size(str,1) > 1, str = strjoin(cellstr(str), ' | '); end
        s = [s ' "' char(str) '"'];
    end
    S.(t) = s;
end
end

function h = hand()
h = gui.gethand;
R = tag_renames();
for k = 1:numel(R.old)
    if ~isfield(h, R.new{k}) && isfield(h, R.old{k})
        h.(R.new{k}) = h.(R.old{k});
    end
end
end

function R = tag_renames()
persistent T
if isempty(T)
    here = fileparts(mfilename('fullpath'));
    lines = readlines(fullfile(here, 'tag_renames.csv'));
    T.old = {}; T.new = {};
    for k = 2:numel(lines)
        p = split(strtrim(lines(k)), ',');
        if numel(p) == 2
            T.old{end+1} = char(p(1)); T.new{end+1} = char(p(2));
        end
    end
end
R = T;
end

function start_pivlab()
close_pivlab();
PIVlab_GUI(1); drawnow;
gui.put('batchModeActive',1);
hgui = getappdata(0,'hgui');
set(hgui,'Units','pixels','Position',[20 40 1600 1000]); drawnow;
try, gui.MainWindow_ResizeFcn(hgui); catch, end
drawnow;
end

function close_pivlab()
hgui = getappdata(0,'hgui');
if ~isempty(hgui) && ishghandle(hgui)
    try, gui.put('batchModeActive',1); catch, end
    try, delete(hgui); catch, close(hgui,'force'); end
end
setappdata(0,'hgui',[]);
try, close(findall(0,'Type','figure'),'force'); catch, end
end

function shot(file)
hgui = getappdata(0,'hgui');
drawnow;
F = getframe(hgui);
imwrite(F.cdata, file);
end
