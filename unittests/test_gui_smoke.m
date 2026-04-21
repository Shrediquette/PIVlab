function tests = test_gui_smoke
tests = functiontests(localfunctions);
end

function setup(testCase)
closePIVlabIfOpen();
testCase.TestData.ProjectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(testCase.TestData.ProjectRoot);
testCase.TestData.ExamplePairPaths = getExampleJetPair(testCase.TestData.ProjectRoot);
end

function teardown(~)
closePIVlabIfOpen();
close all force;
end

function test_gui_can_load_example_images_and_analyze_one_pair(testCase)
guiFigure = launchPIVlabForTesting();
testCase.assertTrue(ishghandle(guiFigure), 'PIVlab GUI figure was not created.');

handles = gui.gethand();
testCase.assertTrue(isfield(handles, 'quick1'));
testCase.assertTrue(isfield(handles, 'quick5'));

pathSelection = buildPathSelectionStruct(testCase.TestData.ExamplePairPaths);
import.loadimgsbutton_Callback([], [], 0, pathSelection);
drawnow;

filepath = gui.retr('filepath');
filename = gui.retr('filename');
expectedImageSize = gui.retr('expected_image_size');
testCase.verifyNotEmpty(filepath, 'GUI did not store imported file paths.');
testCase.verifyNumElements(filepath, 2, 'Expected one imported image pair.');
testCase.verifyNotEmpty(filename, 'GUI did not populate display filenames.');
testCase.verifyEqual(size(expectedImageSize), [1 2], 'Imported image size was not detected.');
testCase.verifyEqual(get(handles.remove_imgs, 'Enable'), 'on');

gui.quick2_Callback([], []);
drawnow;
testCase.verifyTrue(isOnState(get(handles.multip25, 'Visible')), 'Mask panel did not become visible.');

gui.quick3_Callback([], []);
drawnow;
testCase.verifyTrue(isOnState(get(handles.multip03, 'Visible')), 'Pre-processing panel did not become visible.');

gui.quick4_Callback([], []);
drawnow;
testCase.verifyTrue(isOnState(get(handles.multip04, 'Visible')), 'PIV settings panel did not become visible.');

set(handles.algorithm_selection, 'Value', 1);
piv.algorithm_selection_Callback(handles.algorithm_selection, [], []);
drawnow;

set(handles.update_display_checkbox, 'Value', 0);
gui.quick5_Callback([], []);
drawnow;
testCase.verifyTrue(isOnState(get(handles.multip05, 'Visible')), 'Analyze panel did not become visible.');

piv.AnalyzeAll_Callback([], [], []);
drawnow;

resultslist = gui.retr('resultslist');
testCase.verifyNotEmpty(resultslist, 'Analysis did not create a results list.');
testCase.verifySize(resultslist, [12 1], 'Unexpected results list dimensions after analysis.');
testCase.verifyNotEmpty(resultslist{1,1}, 'X coordinates missing after analysis.');
testCase.verifyNotEmpty(resultslist{2,1}, 'Y coordinates missing after analysis.');
testCase.verifyNotEmpty(resultslist{3,1}, 'U field missing after analysis.');
testCase.verifyNotEmpty(resultslist{4,1}, 'V field missing after analysis.');
testCase.verifyTrue(any(isfinite(resultslist{3,1}(:))), 'U field contains no finite values.');
testCase.verifyTrue(any(isfinite(resultslist{4,1}(:))), 'V field contains no finite values.');
end

function guiFigure = launchPIVlabForTesting()
PIVlab_GUI();
drawnow;
gui.put('batchModeActive', 1);
gui.put('sequencer', 1);
guiFigure = getappdata(0, 'hgui');
end

function paths = getExampleJetPair(projectRoot)
paths = {
    fullfile(projectRoot, 'Example_data', 'Jet_0001A.jpg')
    fullfile(projectRoot, 'Example_data', 'Jet_0001B.jpg')
    };
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

function tf = isOnState(value)
if isa(value, 'matlab.lang.OnOffSwitchState')
    tf = value == matlab.lang.OnOffSwitchState.on;
else
    tf = isequal(value, 'on');
end
end
