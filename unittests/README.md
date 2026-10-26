# PIVlab unit tests

All test files are in this folder. The first part of the name says what a file needs and tests:

| Group | Files | Needs | What is tested |
|---|---|---|---|
| core | `test_core_*.m` | nothing | single algorithms without the PIVlab window |
| api | `test_api_*.m` | nothing | the command-line API (`+pivlab`), no PIVlab window |
| acq | `test_acq_*.m` | nothing (no hardware) | image acquisition: oltSync sequences, camera driver folders, packaging |
| stereo | `test_stereo_core.m`, `test_stereo_gui.m` | GUI for `test_stereo_gui` | stereo-PIV |
| gui | `test_gui_*.m` | PIVlab window | the PIVlab window used like a user |
| apigui | `test_apigui_*.m` | PIVlab window | API and GUI give the same numbers, sessions go from one to the other |

`helper_*.m` are functions shared by the tests (start / close PIVlab, save / restore your
preferences, example files, ...). The example images come from `Example_data`: the jet pairs, the
fisheye example `sphere_wake_distorted`; colour images are made from the jet images in `tempdir`
(`helper_files`). `parity/` is the GUI parity check against another git revision
(see `parity/README.md`), `benchmark_bias_rmse/` a benchmark of the bias and random error of the PIV
algorithm (not a pass / fail test).

## Running the tests

```matlab
cd unittests
run_pivlab_tests('fast')     % everything without the PIVlab window (about 5 min)
run_pivlab_tests('gui')      % one group: core, api, acq, stereo, gui, apigui
run_pivlab_tests('all')      % everything (about 25 min)
run_pivlab_tests('test_gui_sessions')                         % one file
runtests('test_gui_sessions.m', 'ProcedureName', 'test_session_with_multitiff')   % one test
```

Notes

* Do not run the GUI groups while you use PIVlab with a camera in another MATLAB: `imaqreset` in the
  test MATLAB can block.
* Your PIVlab preferences are saved and removed before every test file and restored afterwards. If
  a run is stopped in the middle, they are in `tempdir/PIVlab_preferences_backup.mat`:
  `load(fullfile(tempdir,'PIVlab_preferences_backup.mat')); helper_restore_preferences(prefs)`.
* Tests that need data or toolboxes that are not always there are skipped (shown as "Incomplete"),
  not failed: the pco.panda images in `D:\PIV Data\micro_PIV_panda_excelitas\micro_piv_boundary_layer1`,
  the wOFV filter matrices (`+wOFV/Filter matrices`, downloaded at the first optical flow analysis),
  the Parallel Computing Toolbox, more than 12 GB free memory (`test_large_session`).
* The unit tests are not part of the PIVlab toolbox (`package.ignore`).

## Files

| File | Tests |
|---|---|
| `test_core_piv_fftmulti.m` | `piv.piv_FFTmulti`: known shift with double / uint8 / uint16 images, single and multi pass, correlation map, second peak, missing inputs |
| `test_core_piv_ensemble.m` | `piv.piv_FFTensemble`: known shift, single and multi pass, correlation map, number of pairs |
| `test_core_second_peak.m` | second-peak substitution in `validate.filtervectors_all_parallel` |
| `test_core_rescale_map.m` | `plot.rescale_map_core`: derived maps on the image grid, border (mean / extrapolated), masked vectors, ROI, angles |
| `test_core_opencv_undistort.m` | `opencv.opencv_undistort`: image classes, no rescaling of the grey values, same result as MATLAB |
| `test_core_simulate.m` | synthetic particle images (`+simulate`): all GUI flows, cameras, stereo projection, ChArUco boards; checked with PIVlab's PIV |
| `test_core_simulate_3d.m` | particle image generator recordings (`simulate.recording_3d`): files, ground truth, boards, all flows, vortex pairs, simple setup, sphere wake and free jet simulations (about 3 min) |
| `test_core_charuco_filter.m` | `preproc.cam_filter_charuco_corners`: corners of wrongly decoded markers removed, correct corners kept (also with strong distortion), boards with 2000 checkers |
| `test_api_workflow.m` | the whole API chain, `Verbose=false`, the example scripts (not the ones with placeholder file names for your own recording, e.g. stereo), the help texts |
| `test_api_images.m` | `pivlab.readImages`, `pivlab.preprocess`, `pivlab.getImage`: every option |
| `test_api_analyze.m` | `pivlab.analyze`: FFT, ensemble, DCC, optical flow, parallel, every option |
| `test_api_results.m` | `pivlab.filter`, `toMetric`, `derive`, `temporal`: every option; results edited by hand |
| `test_api_display.m` | `pivlab.display`: every option |
| `test_api_settings_sessions.m` | `pivlab.defaults`, `loadSettings`, `saveSession`, `loadSession` |
| `test_acq_oltsync_sequence.m` | `acquisition.validate_oltsync_sequence`, `acquisition.low_energy_sequence` |
| `test_acq_capture_driver_folders.m` | folders of `PIVlab_capture_resources`, MATLAB project path, toolbox contents |
| `test_stereo_core.m` | stereo reconstruction, disparity, lens models, synthetic recordings through `stereo.run` |
| `test_stereo_gui.m` | stereo mode of the PIVlab window: import, cameras, calibration, disparity, analysis, sessions |
| `test_gui_workflow.m` | import, ROI, masks, background, algorithms, parallel, calibration, validation, derived, smoothing, temporal mean, extractions, export, synthetic images |
| `test_gui_settings.m` | default settings, setting controls and dependent controls, settings files, camera settings |
| `test_gui_sessions.m` | sessions bring everything back (settings, data, view, look), multi-page TIFF, capture sessions, large sessions |
| `test_gui_preferences.m` | what PIVlab remembers for the next start, rebuilding the window, warnings and the PIVlab folder stay unchanged |
| `test_gui_bugfixes.m` | old GUI bugs that were fixed (one test per bug) |
| `test_apigui_results.m` | API and GUI: same results (FFT, validation, optical flow, tilted camera model, parallel, ensemble, background), sessions both ways |
| `test_apigui_camera_calibration.m` | camera calibration made in the GUI (standard and tilted model, rectification) used by the API |
