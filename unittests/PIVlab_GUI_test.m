function PIVlab_GUI_test()
%% PIVlab_GUI_test  –  Automated regression test for PIVlab GUI
%
% How it works:
%   Part 1 tests the commandline API (piv.piv_analysis) without any GUI.
%   Part 2 launches the full GUI, bypasses every file-picker dialog by
%   injecting appdata and calling loadimgsbutton_Callback with useGUI=0,
%   then exercises the same callbacks that menu/buttons invoke.
%   No mouse clicks are required.
%
% Usage (run from PIVlab root directory):
%   cd('C:\...\PIVlab_from_github')
%   PIVlab_GUI_test

%% ── Counters (shared with nested functions via closure) ─────────────────
n_pass    = 0;
n_fail    = 0;
fail_msgs = {};

%% ── Configuration ───────────────────────────────────────────────────────
SCRIPT_DIR   = fileparts(fileparts(mfilename('fullpath')));  % PIVlab root (one up from unittests/)
EXAMPLE_DIR  = fullfile(SCRIPT_DIR, 'Example_data');
TEMP_DIR     = 'C:\Users\trash\Documents\MATLAB\claude_code_temp';
SESSION_FILE = fullfile(TEMP_DIR, 'PIVlab_test_session.mat');
N_PAIRS      = 3;   % image pairs to use (max 5 for the Jet set)

%% ── Header ──────────────────────────────────────────────────────────────
fprintf('\n═══════════════════════════════════════════════\n');
fprintf('  PIVlab GUI Test Suite\n');
fprintf('═══════════════════════════════════════════════\n\n');

%% ── Prerequisites ───────────────────────────────────────────────────────
fprintf('── Prerequisites ──\n');

jet_files = dir(fullfile(EXAMPLE_DIR, 'Jet_00*A.jpg'));
assert_test('Example images found', numel(jet_files) >= N_PAIRS, ...
    sprintf('Need %d Jet pairs in %s', N_PAIRS, EXAMPLE_DIR));
if numel(jet_files) < N_PAIRS
    fprintf('\nCannot continue without example images. Aborting.\n');
    print_summary(); return
end
if ~exist(TEMP_DIR,'dir'); mkdir(TEMP_DIR); end
assert_test('Temp dir writable', exist(TEMP_DIR,'dir') == 7);
fprintf('\n');

%% ════════════════════════════════════════════════════════════════════════
fprintf('── Part 1: Commandline API (no GUI) ──\n');

img_A = fullfile(EXAMPLE_DIR, jet_files(1).name);
img_B = fullfile(EXAMPLE_DIR, strrep(jet_files(1).name,'A.jpg','B.jpg'));

preproc_s = { ...
    'ROI',               []; ...
    'CLAHE',             1; ...
    'CLAHE size',        50; ...
    'Highpass',          0; ...
    'Highpass size',     15; ...
    'Clipping',          0; ...
    'Wiener',            0; ...
    'Wiener size',       3; ...
    'Minimum intensity', 0.0; ...
    'Maximum intensity', 1.0};

piv_s = { ...
    'Int. area 1',             64; ...
    'Step size 1',             32; ...
    'Subpix. finder',          1; ...
    'Mask',                    []; ...
    'ROI',                     []; ...
    'Nr. of passes',           1; ...
    'Int. area 2',             32; ...
    'Int. area 3',             16; ...
    'Int. area 4',             16; ...
    'Window deformation',      '*linear'; ...
    'Repeated Correlation',    0; ...
    'Disable Autocorrelation', 0; ...
    'Correlation style',       0; ...
    'Repeat last pass',        0; ...
    'Last pass quality slope', 0.025};

try_test('piv.piv_analysis: single-pass returns results', @test_piv_analysis);
try_test('preproc.PIVlab_preproc: CLAHE applied',          @test_preproc);
try_test('piv.piv_analysis: two-pass returns results',     @test_two_pass);

%% ════════════════════════════════════════════════════════════════════════
fprintf('\n── Part 2: GUI Integration Tests ──\n');
fprintf('   Launching PIVlab GUI ...\n');

PIVlab_GUI(1);
drawnow; pause(1);

hgui = getappdata(0,'hgui');
assert_test('GUI window created', ~isempty(hgui) && ishandle(hgui));
if isempty(hgui) || ~ishandle(hgui)
    fprintf('\nGUI did not open. Aborting GUI tests.\n');
    print_summary(); return
end
handles = gui.gethand;

%% 2.1  Load images ─────────────────────────────────────────────────────
fprintf('\n  [2.1] Image loading\n');

path_struct(N_PAIRS*2,1) = struct('name','','isdir',false);
for k = 1:N_PAIRS
    path_struct(k*2-1).name = fullfile(EXAMPLE_DIR, jet_files(k).name);
    path_struct(k*2  ).name = fullfile(EXAMPLE_DIR, ...
        strrep(jet_files(k).name,'A.jpg','B.jpg'));
    path_struct(k*2-1).isdir = false;
    path_struct(k*2  ).isdir = false;
end

gui.put('sequencer', 1);   % pairwise A/B
gui.put('multitiff', 0);
gui.put('parallel',  0);   % keep serial to avoid framepart complexity

try_test('loadimgsbutton_Callback (no dialog)', @load_images);
drawnow;

try_test('filepath appdata populated',  @check_filepath);
try_test('framenum appdata populated',  @check_framenum);
try_test('framepart appdata populated', @check_framepart);

%% 2.2  Preprocessing settings ─────────────────────────────────────────
fprintf('\n  [2.2] Preprocessing settings\n');

try_test('Set CLAHE on',        @() set(handles.clahe_enable,    'Value',  1));
try_test('Set CLAHE size 50',   @() set(handles.clahe_size,      'String','50'));
try_test('Set highpass off',    @() set(handles.enable_highpass, 'Value',  0));
try_test('Set wiener off',      @() set(handles.wienerwurst,     'Value',  0));
try_test('Set intensity cap off',@() set(handles.enable_intenscap,'Value', 0));
try_test('Set min intensity',   @() set(handles.minintens,       'String','0.0'));
try_test('Set max intensity',   @() set(handles.maxintens,       'String','1.0'));

%% 2.3  PIV algorithm settings ─────────────────────────────────────────
fprintf('\n  [2.3] PIV algorithm settings\n');

try_test('Set algorithm: FFT multipass', ...
    @() set(handles.algorithm_selection, 'Value', 1));
try_test('Set interrogation area 64', ...
    @() set(handles.intarea, 'String', '64'));
try_test('Set step size 32', ...
    @() set(handles.step, 'String', '32'));
try_test('Set subpixel: Gauss 2x3-point', ...
    @() set(handles.subpix, 'Value', 1));
try_test('Enable pass 2 (32 px)', @enable_pass2);
try_test('Disable pass 3', @() set(handles.checkbox27, 'Value', 0));
try_test('Disable pass 4', @() set(handles.checkbox28, 'Value', 0));

%% 2.4  Run PIV analysis ───────────────────────────────────────────────
fprintf('\n  [2.4] PIV analysis\n');
fprintf('        (This may take ~30 s for %d pairs)\n', N_PAIRS);

try_test('do_analys_Callback (switch to analysis panel)', ...
    @() piv.do_analys_Callback([], [], []));
drawnow;

tic;
try_test('AnalyzeAll_Callback (FFT multipass)', ...
    @() piv.AnalyzeAll_Callback([], [], []));
drawnow;
fprintf('        Analysis took %.1f s\n', toc);

try_test('resultslist populated',             @check_resultslist);
try_test('typevector contains valid vectors', @check_typevector);

%% 2.5  Validation / filtering ─────────────────────────────────────────
fprintf('\n  [2.5] Validation & filtering\n');

try_test('Set stdev check on',      @() set(handles.stdev_check,    'Value',  1));
try_test('Set stdev threshold 7',   @() set(handles.stdev_thresh,   'String','7'));
try_test('Set local median on',     @() set(handles.loc_median,     'Value',  1));
try_test('Set local median thresh', @() set(handles.loc_med_thresh, 'String','3'));
try_test('Set interpolate missing', @() set(handles.interpol_missing,'Value', 1));

try_test('apply_filter_all_Callback', ...
    @() validate.apply_filter_all_Callback([], [], []));
drawnow;
try_test('Filtered results stored', @check_filtered);

%% 2.6  Display mode switching ─────────────────────────────────────────
fprintf('\n  [2.6] Display modes\n');

panels = {'multip06','multip07','multip08','multip09','multip10'};
names  = {'Vectors','Vector statistics','Derive parameters', ...
          'Streamlines','Calibration'};
for d = 1:numel(panels)
    pnm = names{d};
    pid = panels{d};
    try_test(sprintf('Switch panel: %s', pnm), @() gui.switchui(pid));
    drawnow;
end

try_test('sliderdisp: vectors (displaywhat=1)',   @show_vectors);
try_test('sliderdisp: magnitude (displaywhat=2)', @show_magnitude);

%% 2.7  Save / load session roundtrip ──────────────────────────────────
fprintf('\n  [2.7] Session save / load\n');

try_test('Save session (no dialog)', @do_save_session);
rl_before = gui.retr('resultslist');
try_test('Load session back (no dialog)', @do_load_session);
drawnow;
try_test('resultslist survives roundtrip', @check_roundtrip);
try_test('filepath survives roundtrip',    @check_fp_roundtrip);

%% 2.8  Frame navigation ────────────────────────────────────────────────
fprintf('\n  [2.8] Frame navigation\n');

try_test('Navigate to frame 1', @() nav_frame(1));
try_test('Navigate to frame 2', @() nav_frame(2));

%% 2.9  ROI definition ─────────────────────────────────────────────────
fprintf('\n  [2.9] ROI definition\n');

try_test('Set ROI via appdata', @set_roi);
try_test('Clear ROI',           @clear_roi);

%% 2.10  Calibration appdata ────────────────────────────────────────────
fprintf('\n  [2.10] Calibration (appdata only)\n');

try_test('Set calibration factors', @set_calib);
try_test('Reset calibration',       @reset_calib);

%% 2.11  Close GUI ─────────────────────────────────────────────────────
fprintf('\n  [2.11] GUI teardown\n');

try_test('Close GUI cleanly', @close_gui);

%% ── Summary ─────────────────────────────────────────────────────────────
print_summary();


%% ════════════════════════════════════════════════════════════════════════
%  Nested test functions  (share n_pass / n_fail / fail_msgs via closure)
% ════════════════════════════════════════════════════════════════════════

    function assert_test(name, condition, msg)
        if nargin < 3; msg = 'assertion failed'; end
        if condition
            fprintf('  [PASS] %s\n', name);
            n_pass = n_pass + 1;
        else
            fprintf('  [FAIL] %s  ->  %s\n', name, msg);
            n_fail = n_fail + 1;
            fail_msgs{end+1} = sprintf('%s: %s', name, msg);
        end
    end

    function try_test(name, fn)
        try
            fn();
            fprintf('  [PASS] %s\n', name);
            n_pass = n_pass + 1;
        catch err
            fprintf('  [FAIL] %s\n    -> %s\n', name, err.message);
            n_fail = n_fail + 1;
            fail_msgs{end+1} = sprintf('%s: %s', name, err.message);
        end
    end

    function print_summary()
        fprintf('\n═══════════════════════════════════════════════\n');
        fprintf('  Results: %d passed, %d failed  (total %d)\n', ...
            n_pass, n_fail, n_pass + n_fail);
        if n_fail > 0
            fprintf('\n  Failures:\n');
            for fi = 1:numel(fail_msgs)
                fprintf('    • %s\n', fail_msgs{fi});
            end
        end
        fprintf('═══════════════════════════════════════════════\n\n');
    end

%% ── Commandline test bodies ─────────────────────────────────────────────

    function test_piv_analysis()
        [x, y, u, v, typevector, ~] = piv.piv_analysis( ...
            EXAMPLE_DIR, jet_files(1).name, ...
            strrep(jet_files(1).name,'A.jpg','B.jpg'), ...
            preproc_s, piv_s, 1, false);
        assert(~isempty(x),           'x is empty');
        assert(~isempty(u),           'u is empty');
        assert(isequal(size(x),size(u)), 'x/u size mismatch');
        assert(all(isfinite(x(:))),   'x contains non-finite values');
        assert(any(typevector(:)==1), 'no valid vectors returned');
    end

    function test_preproc()
        img = double(imread(img_A)) / 255;
        if size(img,3) == 3; img = rgb2gray(img); end
        out = preproc.PIVlab_preproc(img, [], 1, 50, 0, 15, 0, 0, 3, 0, 1);
        assert(~isempty(out),         'preproc returned empty');
        assert(isequal(size(out),size(img)), 'preproc changed image size');
        assert(max(out(:)) <= 1,      'preproc output exceeds [0,1]');
    end

    function test_two_pass()
        piv2 = piv_s;
        piv2{6,2} = 2;
        [x, ~, u, ~, typevector, ~] = piv.piv_analysis( ...
            EXAMPLE_DIR, jet_files(1).name, ...
            strrep(jet_files(1).name,'A.jpg','B.jpg'), ...
            preproc_s, piv2, 1, false);
        assert(~isempty(x),           'two-pass: x empty');
        assert(any(typevector(:)==1), 'two-pass: no valid vectors');
    end

%% ── GUI test bodies ──────────────────────────────────────────────────────

    function load_images()
        import.loadimgsbutton_Callback([], [], 0, path_struct);
    end

    function check_filepath()
        fp = gui.retr('filepath');
        assert(~isempty(fp), 'filepath is empty after load');
        assert(size(fp,1) == N_PAIRS*2, ...
            sprintf('Expected %d entries, got %d', N_PAIRS*2, size(fp,1)));
        assert(exist(fp{1},'file') == 2, 'First filepath does not exist on disk');
    end

    function check_framenum()
        fn = gui.retr('framenum');
        assert(~isempty(fn),           'framenum is empty');
        assert(numel(fn)==N_PAIRS*2,   'framenum length mismatch');
    end

    function check_framepart()
        fp2 = gui.retr('framepart');
        assert(~isempty(fp2),   'framepart is empty');
        assert(size(fp2,2)==2,  'framepart should have 2 columns');
    end

    function enable_pass2()
        set(handles.checkbox26, 'Value', 1);
        set(handles.edit50,     'String','32');
        piv.pass2_checkbox_Callback(handles.checkbox26, [], []);
    end

    function check_resultslist()
        rl = gui.retr('resultslist');
        assert(~isempty(rl), 'resultslist empty after analysis');
        assert(size(rl,2) == N_PAIRS, ...
            sprintf('Expected %d columns, got %d', N_PAIRS, size(rl,2)));
        assert(~isempty(rl{1,1}), 'x coords (row 1) empty');
        assert(~isempty(rl{3,1}), 'u velocities (row 3) empty');
        assert(any(isfinite(rl{3,1}(:))), 'u velocities all non-finite');
    end

    function check_typevector()
        rl = gui.retr('resultslist');
        tv = rl{5,1};
        assert(any(tv(:)==1), 'No valid vectors (typevector==1)');
    end

    function check_filtered()
        rl = gui.retr('resultslist');
        assert(size(rl,1) >= 7,    'resultslist has fewer than 7 rows');
        assert(~isempty(rl{7,1}),  'Filtered u (row 7) is empty');
    end

    function show_vectors()
        gui.put('displaywhat', 1);
        gui.switchui('multip06');
        gui.sliderdisp(gui.retr('pivlab_axis'));
        drawnow;
    end

    function show_magnitude()
        gui.put('displaywhat', 2);
        gui.sliderdisp(gui.retr('pivlab_axis'));
        drawnow;
    end

    function do_save_session()
        [pn, fn, ext] = fileparts(SESSION_FILE);
        export.save_session_function(pn, [fn ext]);
        assert(exist(SESSION_FILE,'file') == 2, 'Session file not created');
    end

    function do_load_session()
        import.load_session_Callback(1, SESSION_FILE);
    end

    function check_roundtrip()
        rl_after = gui.retr('resultslist');
        assert(~isempty(rl_after),             'resultslist empty after reload');
        assert(isequal(size(rl_before), size(rl_after)), ...
            'resultslist size changed after roundtrip');
        assert(isequal(rl_before{1,1}, rl_after{1,1}), ...
            'x coordinates changed after roundtrip');
    end

    function check_fp_roundtrip()
        fp = gui.retr('filepath');
        assert(~isempty(fp),                 'filepath empty after reload');
        assert(exist(fp{1},'file') == 2,     'Reloaded filepath does not exist');
    end

    function nav_frame(n)
        h2 = gui.gethand;
        set(h2.fileselector, 'Value', n);
        gui.fileselector_Callback(h2.fileselector, [], []);
        drawnow;
    end

    function set_roi()
        fp = gui.retr('filepath');
        img = imread(fp{1});
        [H, W, ~] = size(img);
        roi = [10, 10, min(W-20, 200), min(H-20, 150)];
        gui.put('roirect', roi);
        assert(isequal(gui.retr('roirect'), roi), 'roirect not stored correctly');
    end

    function clear_roi()
        gui.put('roirect', []);
        assert(isempty(gui.retr('roirect')), 'roirect not cleared');
    end

    function set_calib()
        gui.put('calu',  2.5);
        gui.put('calv',  2.5);
        gui.put('calxy', 1.0);
        assert(gui.retr('calu') == 2.5, 'calu not stored');
    end

    function reset_calib()
        gui.put('calu',  1);
        gui.put('calv',  1);
        gui.put('calxy', 1);
        assert(gui.retr('calu') == 1, 'calu reset failed');
    end

    function close_gui()
        if ishandle(hgui)
            % batchModeActive=1 makes CloseRequestFcn skip the confirmation dialog
            gui.put('batchModeActive', 1);
            gui.MainWindow_CloseRequestFcn(hgui, [], []);
        end
        pause(0.5);
    end

end % PIVlab_GUI_test
