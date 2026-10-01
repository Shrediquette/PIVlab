# GUI parity check

Checks that a code change does not alter what the PIVlab GUI computes or shows.
The GUI is driven through 13 scripted scenarios (pairwise and time-resolved images, FFT / DCC /
ensemble / optical flow, serial and parallel, ROI, masks, background subtraction, validation
filters, calibration with flipped axes, all derived quantities, smoothing, temporal statistics,
about 30 display settings, session and settings save / load). Every number is stored, and a
screenshot of the PIVlab window is taken at the interesting points.

## Usage (in MATLAB, from the PIVlab folder)

```matlab
addpath unittests/parity
parity_check            % working copy vs. HEAD (about 20 minutes)
parity_check("v3.13")   % working copy vs. another revision
```

`parity_check` checks the reference revision out into a temporary git worktree, runs
`parity_run` for both versions in separate MATLAB processes (`matlab -batch`), and compares:

* all numbers with `isequaln` (results, derived maps, calibration, exports, GUI control states,
  the data of every drawn graphics object),
* all screenshots pixel by pixel (rendering is deterministic on one computer),
* runtimes of the analyses (reported, not compared).

With `API=true` (default) it also checks that the `pivlab.*` command-line functions give
bit-identical results and graphics as the reference GUI (`api_vs_gui`, `api_vs_gui_more`,
`api_display_vs_gui`).

Single steps:

```matlab
parity_run(outdir)                    % run the scenarios of the working copy
parity_run(outdir, {'display_variants'}, root)   % selected scenarios, other PIVlab folder
parity_compare(dirA, dirB)            % compare two runs
```

Notes

* Run the scenarios in a fresh MATLAB without an open PIVlab window.
* PIVlab writes into `PIVlab_settings_default.mat` and creates the LIC MEX file and the wOFV
  filter matrices while the scenarios run; `parity_run` restores / removes them afterwards.
* `mocks/` contains `uigetfile` / `uiputfile` replacements for the file dialogs. The folder is
  only on the path while `parity_run` runs.
* Optical flow is not part of the API comparison: `pivlab.analyze(Algorithm="ofv")` uses the correct
  per-image intensity stretch, the GUI's wOFV loop does not (known GUI bug).
