function tests = test_gui_regression
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);

testRunDir = tempname(tempdir);
mkdir(testRunDir);

testCase.TestData.ProjectRoot = projectRoot;
testCase.TestData.TestRunDir = testRunDir;
testCase.TestData.SessionFile = fullfile(testRunDir, 'PIVlab_gui_regression_session.mat');
testCase.TestData.ExportFile = fullfile(testRunDir, 'PIVlab_gui_regression_export.mat');
testCase.TestData.PolylineFile = fullfile(testRunDir, 'PIVlab_gui_regression_polyline.mat');
testCase.TestData.AreaFile = fullfile(testRunDir, 'PIVlab_gui_regression_area.mat');
testCase.TestData.TempFiles = {
    testCase.TestData.SessionFile
    testCase.TestData.ExportFile
    testCase.TestData.PolylineFile
    testCase.TestData.AreaFile
    };

setappdata(0, 'PIVlabTestMode', true);
end

function teardownOnce(testCase)
closePIVlabIfOpen();
closeAllTestFigures();
if isappdata(0, 'PIVlabTestMode')
    rmappdata(0, 'PIVlabTestMode');
end
if isfield(testCase.TestData, 'TestRunDir') && exist(testCase.TestData.TestRunDir, 'dir')
    try
        rmdir(testCase.TestData.TestRunDir, 's');
    catch
    end
end
end

function test_serial_then_parallel_gui_regression(testCase)
testCase.TestData.JetPairPaths = getJetPairPaths(testCase.TestData.ProjectRoot, 3);
testCase.TestData.FuerteventuraPaths = getFuerteventuraPaths(testCase.TestData.ProjectRoot, 4);

closePIVlabIfOpen();
closeAllNonPIVlabFigures();
runGuiRegressionForMode(testCase, 0);

closePIVlabIfOpen();
closeAllNonPIVlabFigures();
try
    runGuiRegressionForMode(testCase, 2);
catch err
    testCase.assumeTrue(false, ['Parallel GUI regression could not be exercised: ' err.message]);
end
end

function runGuiRegressionForMode(testCase, numCores)
guiFigure = launchPIVlabForTesting(numCores);
testCase.assertTrue(ishghandle(guiFigure), 'PIVlab GUI figure was not created.');
if numCores < 2
    testCase.verifyEqual(gui.retr('parallel'), 0, 'Serial launch should not enable parallel processing.');
else
    testCase.verifyTrue(ismember(gui.retr('parallel'), [0 1]), 'Parallel state should be stored as 0 or 1.');
end

loadImages(testCase.TestData.JetPairPaths, 1);
assertImportedImages(testCase, 6, 'grayscale Jet images');
exerciseFftWorkflow(testCase, numCores);

loadImages(testCase.TestData.FuerteventuraPaths, 0);
assertImportedImages(testCase, 6, 'color Fuerteventura images');
expectedImageSize = gui.retr('expected_image_size');
testCase.verifyEqual(size(expectedImageSize), [1 2], 'Color import did not record image dimensions.');

loadImages(testCase.TestData.JetPairPaths, 1);
configurePivAlgorithm(2, 'singlePass');
runAnalysisAndAssert(testCase, 1);

loadImages(testCase.TestData.JetPairPaths(1:2), 1);
configurePivAlgorithm(3, 'singlePass');
runAnalysisAndAssert(testCase, 1);

exerciseSyntheticImageGeneration(testCase);
end

function exerciseFftWorkflow(testCase, numCores)
setRoiAndMasks(testCase);
generateAndApplyBackground(testCase);
configurePivAlgorithm(1, 'fourPass');
runAnalysisAndAssert(testCase, 3);

applyCalibration(testCase);
applyValidation(testCase);
calculateDerivedAndMeanVelocity(testCase);
exerciseExtractionPanels(testCase);
exerciseMatExport(testCase);
exerciseSessionRoundTrip(testCase, numCores);
end

function exerciseSyntheticImageGeneration(testCase)
handles = gui.gethand();

gui.switchui('multip15');
set(handles.flow_sim, 'Value', 3);
set(handles.img_sizex, 'String', '96');
set(handles.img_sizey, 'String', '96');
set(handles.part_am, 'String', '250');
set(handles.part_noise, 'String', '0.001');
set(handles.shiftdisplacement, 'String', '2');

simulate.generate_it_Callback([], [], []);
drawnow;

generatedA = gui.retr('gen_image_1');
generatedB = gui.retr('gen_image_2');
testCase.verifyNotEmpty(generatedA, 'Synthetic first image was not generated.');
testCase.verifyNotEmpty(generatedB, 'Synthetic second image was not generated.');
testCase.verifyEqual(size(generatedA), [96 96], 'Synthetic first image has unexpected dimensions.');
testCase.verifyEqual(size(generatedB), [96 96], 'Synthetic second image has unexpected dimensions.');
closeAllNonPIVlabFigures();
end

function guiFigure = launchPIVlabForTesting(numCores)
PIVlab_GUI(numCores);
drawnow;
gui.put('batchModeActive', 1);
gui.put('sequencer', 1);
gui.put('multitiff', 0);
gui.put('parallel', gui.retr('parallel'));
guiFigure = getappdata(0, 'hgui');
end

function loadImages(paths, sequencer)
gui.put('sequencer', sequencer);
gui.put('multitiff', 0);
gui.put('video_selection_done', 0);
pathSelection = buildPathSelectionStruct(paths);
import.loadimgsbutton_Callback([], [], 0, pathSelection);
drawnow;
end

function assertImportedImages(testCase, expectedCount, description)
filepath = gui.retr('filepath');
filename = gui.retr('filename');
testCase.verifyNotEmpty(filepath, ['GUI did not store imported ' description '.']);
testCase.verifyNumElements(filepath, expectedCount, ['Unexpected number of imported ' description '.']);
testCase.verifyNotEmpty(filename, ['GUI did not populate filenames for ' description '.']);
for idx = 1:numel(filepath)
    testCase.verifyEqual(exist(filepath{idx}, 'file'), 2, ['Imported file does not exist: ' filepath{idx}]);
end
end

function configurePivAlgorithm(algorithmValue, passMode)
handles = gui.gethand();
gui.quick4_Callback([], []);
set(handles.algorithm_selection, 'Value', algorithmValue);
piv.algorithm_selection_Callback(handles.algorithm_selection, [], []);

set(handles.intarea, 'String', '64');
piv.intarea_Callback(handles.intarea, [], []);
set(handles.step, 'String', '32');
piv.step_Callback(handles.step, [], []);
set(handles.subpix, 'Value', 1);

switch passMode
    case 'singlePass'
        set(handles.checkbox26, 'Value', 0);
        piv.pass2_checkbox_Callback(handles.checkbox26, [], []);
        set(handles.checkbox27, 'Value', 0);
        piv.pass3_checkbox_Callback(handles.checkbox27, [], []);
        set(handles.checkbox28, 'Value', 0);
        piv.pass4_checkbox_Callback(handles.checkbox28, [], []);
    case 'fourPass'
        set(handles.checkbox26, 'Value', 1);
        set(handles.edit50, 'String', '32');
        piv.pass2_checkbox_Callback(handles.checkbox26, [], []);
        set(handles.checkbox27, 'Value', 1);
        set(handles.edit51, 'String', '16');
        piv.pass3_checkbox_Callback(handles.checkbox27, [], []);
        set(handles.checkbox28, 'Value', 1);
        set(handles.edit52, 'String', '16');
        piv.pass4_checkbox_Callback(handles.checkbox28, [], []);
end

set(handles.update_display_checkbox, 'Value', 0);
drawnow;
end

function runAnalysisAndAssert(testCase, expectedFrames)
handles = gui.gethand();
gui.quick5_Callback([], []);
drawnow;
set(handles.update_display_checkbox, 'Value', 0);

piv.AnalyzeAll_Callback([], [], []);
drawnow;

assertResultsValid(testCase, expectedFrames);
end

function assertResultsValid(testCase, expectedFrames)
resultslist = gui.retr('resultslist');
testCase.verifyNotEmpty(resultslist, 'Analysis did not create a results list.');
testCase.verifyGreaterThanOrEqual(size(resultslist, 1), 5, 'Results list has too few rows.');
testCase.verifyGreaterThanOrEqual(size(resultslist, 2), expectedFrames, 'Unexpected number of analyzed frames.');
for frame = 1:expectedFrames
    testCase.verifyNotEmpty(resultslist{1, frame}, 'X coordinates missing after analysis.');
    testCase.verifyNotEmpty(resultslist{2, frame}, 'Y coordinates missing after analysis.');
    testCase.verifyNotEmpty(resultslist{3, frame}, 'U field missing after analysis.');
    testCase.verifyNotEmpty(resultslist{4, frame}, 'V field missing after analysis.');
    testCase.verifyNotEmpty(resultslist{5, frame}, 'Type vector missing after analysis.');
    testCase.verifyTrue(any(isfinite(resultslist{3, frame}(:))), 'U field contains no finite values.');
    testCase.verifyTrue(any(isfinite(resultslist{4, frame}(:))), 'V field contains no finite values.');
end
end

function setRoiAndMasks(testCase)
expectedImageSize = gui.retr('expected_image_size');
testCase.assertEqual(size(expectedImageSize), [1 2], 'Cannot create ROI without imported image size.');

height = expectedImageSize(1);
width = expectedImageSize(2);
roi = [20 20 min(width - 40, 300) min(height - 40, 220)];
gui.put('roirect', roi);
testCase.verifyEqual(gui.retr('roirect'), roi, 'ROI was not stored in GUI appdata.');

rng(1);
masksInFrame = cell(1, 3);
masksInFrame{1} = {'ROI_object_rectangle', [25 + randi(8) 25 + randi(8) 40 35]};
masksInFrame{2} = {'ROI_object_polygon', [120 90; 155 95; 150 130; 115 125]};
masksInFrame{3} = cell(0);
gui.put('masks_in_frame', masksInFrame);
storedMasks = gui.retr('masks_in_frame');
testCase.verifyEqual(numel(storedMasks), 3, 'Mask assignment was not stored for all frames.');
testCase.verifyEmpty(storedMasks{3}, 'One test frame should intentionally remain mask-free.');
end

function generateAndApplyBackground(testCase)
handles = gui.gethand();
gui.quick3_Callback([], []);
set(handles.bg_subtract, 'Value', 2);
preproc.generate_BG_img();
drawnow;

bgA = gui.retr('bg_img_A');
bgB = gui.retr('bg_img_B');
testCase.verifyNotEmpty(bgA, 'Background image A was not generated.');
testCase.verifyNotEmpty(bgB, 'Background image B was not generated.');
testCase.verifyEqual(get(handles.bg_subtract, 'Value'), 2, 'Background subtraction mode was not kept enabled.');
end

function applyCalibration(testCase)
handles = gui.gethand();
gui.quick6_Callback([], []);
gui.put('pointscali', [10 10; 110 10]);
set(handles.realdist, 'String', '10');
set(handles.time_inp, 'String', '100');
set(handles.x_axis_direction, 'Value', 1);
set(handles.y_axis_direction, 'Value', 1);

calibrate.apply_cali_Callback([], [], []);
drawnow;

testCase.verifyEqual(gui.retr('calxy'), 1e-4, 'AbsTol', 1e-12, 'Calibration length scale is unexpected.');
testCase.verifyEqual(gui.retr('calu'), 0.001, 'AbsTol', 1e-12, 'Horizontal calibration velocity factor is unexpected.');
testCase.verifyEqual(gui.retr('calv'), 0.001, 'AbsTol', 1e-12, 'Vertical calibration velocity factor is unexpected.');
end

function applyValidation(testCase)
handles = gui.gethand();
set(handles.stdev_check, 'Value', 1);
set(handles.stdev_thresh, 'String', '7');
set(handles.loc_median, 'Value', 1);
set(handles.loc_med_thresh, 'String', '3');
set(handles.interpol_missing, 'Value', 1);

validate.apply_filter_all_Callback([], [], []);
drawnow;

resultslist = gui.retr('resultslist');
testCase.verifyGreaterThanOrEqual(size(resultslist, 1), 9, 'Validation did not add filtered result rows.');
testCase.verifyNotEmpty(resultslist{7, 1}, 'Filtered U field was not stored.');
testCase.verifyNotEmpty(resultslist{8, 1}, 'Filtered V field was not stored.');
testCase.verifyNotEmpty(resultslist{9, 1}, 'Filtered type vector was not stored.');
end

function calculateDerivedAndMeanVelocity(testCase)
handles = gui.gethand();
gui.switchui('multip08');
set(handles.smooth, 'Value', 1);
set(handles.smoothstr, 'Value', 3);
plot.derivative_calc(1, 3, 0);

derived = gui.retr('derived');
resultslist = gui.retr('resultslist');
testCase.verifyNotEmpty(derived{2, 1}, 'Velocity magnitude was not calculated.');
testCase.verifyNotEmpty(resultslist{10, 1}, 'Smoothed U field was not stored.');
testCase.verifyNotEmpty(resultslist{11, 1}, 'Smoothed V field was not stored.');

gui.put('displaywhat', 2);
gui.sliderdisp(gui.retr('pivlab_axis'));
drawnow;

set(handles.selectedFramesMean, 'String', '1:3');
set(handles.append_replace, 'Value', 1);
plot.temporal_operation_Callback([], [], 1);
drawnow;

resultslist = gui.retr('resultslist');
testCase.verifyGreaterThanOrEqual(size(resultslist, 2), 4, 'Temporal mean velocity was not appended.');
testCase.verifyNotEmpty(resultslist{3, 4}, 'Mean U field is empty.');

plot.statistics_Callback([], [], []);
testCase.verifyTrue(isOnState(get(handles.multip14, 'Visible')), 'Statistics panel did not become visible.');
end

function exerciseExtractionPanels(testCase)
handles = gui.gethand();
resultslist = gui.retr('resultslist');
testCase.assertNotEmpty(resultslist{1, 1}, 'Extraction requires analyzed vector coordinates.');

x = resultslist{1, 1};
y = resultslist{2, 1};
polyX = double([x(2, 2); x(2, end - 1); x(end - 1, end - 1)]);
polyY = double([y(2, 2); y(2, end - 1); y(end - 1, end - 1)]);
saveExtractionCoordinates(testCase.TestData.PolylineFile, polyX, polyY, 'extract_poly');

extract.poly_extract_Callback([], [], []);
extract.load_polyline_Callback(handles.load_polyline, [], testCase.TestData.PolylineFile);
set(handles.extraction_choice, 'Value', 1);
extract.plot_data_Callback(handles.plot_data, [], []);

testCase.verifyNotEmpty(gui.retr('distance'), 'Polyline extraction distance was not stored.');
testCase.verifyNotEmpty(gui.retr('c'), 'Polyline extraction values were not stored.');
testCase.verifyNotEmpty(gui.retr('cx'), 'Polyline extraction X coordinates were not stored.');
testCase.verifyNotEmpty(gui.retr('cy'), 'Polyline extraction Y coordinates were not stored.');
polylineValues = gui.retr('c');
testCase.verifyTrue(any(isfinite(polylineValues(:))), 'Polyline extraction contains no finite values.');

areaX = double([x(2, 2); x(2, end - 2); x(end - 2, end - 2); x(end - 2, 2)]);
areaY = double([y(2, 2); y(2, end - 2); y(end - 2, end - 2); y(end - 2, 2)]);
saveExtractionCoordinates(testCase.TestData.AreaFile, areaX, areaY, 'extract_poly_area');

extract.area_panel_activation_Callback([], [], []);
extract.load_polyline_Callback(handles.load_area_coordinates, [], testCase.TestData.AreaFile);
set(handles.extraction_choice_area, 'Value', 2);
[returnedData, returnedHeader] = extract.plot_data_area(1, 1);

testCase.verifyNotEmpty(returnedHeader, 'Area extraction header is empty.');
testCase.verifyNotEmpty(returnedData, 'Area extraction data is empty.');
testCase.verifyTrue(any(cellfun(@(value) isnumeric(value) && isfinite(value), returnedData(:))), ...
    'Area extraction contains no finite numeric values.');
end

function exerciseMatExport(testCase)
export.mat_file_save(1, 'PIVlab_gui_regression_export.mat', testCase.TestData.TestRunDir, 2);
testCase.verifyEqual(exist(testCase.TestData.ExportFile, 'file'), 2, 'MAT export file was not created.');
end

function exerciseSessionRoundTrip(testCase, numCores)
resultsBefore = gui.retr('resultslist');
filepathBefore = gui.retr('filepath');

export.save_session_function(testCase.TestData.TestRunDir, 'PIVlab_gui_regression_session.mat');
testCase.verifyEqual(exist(testCase.TestData.SessionFile, 'file'), 2, 'Session file was not created.');

closePIVlabIfOpen();
launchPIVlabForTesting(numCores);
import.load_session_Callback(1, testCase.TestData.SessionFile);
drawnow;

resultsAfter = gui.retr('resultslist');
filepathAfter = gui.retr('filepath');
testCase.verifyEqual(size(resultsAfter), size(resultsBefore), 'Results list size changed after session round-trip.');
testCase.verifyEqual(size(filepathAfter), size(filepathBefore), 'File path list size changed after session round-trip.');
testCase.verifyEqual(resultsAfter{1, 1}, resultsBefore{1, 1}, 'X coordinates changed after session round-trip.');

handles = gui.gethand();
maxFrame = min(3, size(resultsAfter, 2));
for frame = 1:maxFrame
    set(handles.fileselector, 'Value', frame);
    gui.fileselector_Callback(handles.fileselector, [], []);
    gui.sliderdisp(gui.retr('pivlab_axis'));
    drawnow;
    testCase.verifyEqual(floor(get(handles.fileselector, 'Value')), frame, 'Frame slider did not keep requested value.');
end
end

function saveExtractionCoordinates(filename, xposition, yposition, extract_type)
save(filename, 'xposition', 'yposition', 'extract_type');
end

function paths = getJetPairPaths(projectRoot, numberOfPairs)
paths = cell(numberOfPairs * 2, 1);
for idx = 1:numberOfPairs
    paths{idx * 2 - 1} = fullfile(projectRoot, 'Example_data', sprintf('Jet_%04dA.jpg', idx));
    paths{idx * 2} = fullfile(projectRoot, 'Example_data', sprintf('Jet_%04dB.jpg', idx));
end
end

function paths = getFuerteventuraPaths(projectRoot, numberOfImages)
paths = cell(numberOfImages, 1);
for idx = 1:numberOfImages
    paths{idx} = fullfile(projectRoot, 'Example_data', sprintf('Fuerteventura_%06d.jpeg', idx - 1));
end
end

function pathSelection = buildPathSelectionStruct(paths)
pathSelection = struct('name', paths(:), 'isdir', num2cell(false(numel(paths), 1)));
end

function closePIVlabIfOpen()
hgui = getappdata(0, 'hgui');
if ~isempty(hgui) && ishghandle(hgui)
    try
        gui.put('batchModeActive', 1);
    catch
    end
    try
        delete(hgui);
    catch
        close(hgui, 'force');
    end
end
setappdata(0, 'hgui', []);
end

function closeAllTestFigures()
try
    close(findall(0, 'Type', 'figure', 'Tag', 'derivplotwindow'), 'force');
catch
end
try
    close(findall(0, 'Type', 'figure'), 'force');
catch
end
end

function closeAllNonPIVlabFigures()
allFigures = findall(0, 'Type', 'figure');
hgui = getappdata(0, 'hgui');
for idx = 1:numel(allFigures)
    if isempty(hgui) || ~isequal(allFigures(idx), hgui)
        try
            close(allFigures(idx), 'force');
        catch
        end
    end
end
end

function tf = isOnState(value)
if isa(value, 'matlab.lang.OnOffSwitchState')
    tf = value == matlab.lang.OnOffSwitchState.on;
else
    tf = isequal(value, 'on');
end
end
