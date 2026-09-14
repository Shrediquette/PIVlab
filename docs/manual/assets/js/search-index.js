/*
 * search-index.js — Client-side search records (no server / no fetch needed).
 *
 * Each record describes one page or one section of a page:
 *   { title, href, hash, section, text }
 *     title   — heading shown in the results list
 *     href    — page path relative to the manual root (e.g. "pages/masking.html")
 *     hash    — optional in-page anchor id (jumps straight to the section)
 *     section — the sidebar group it belongs to (shown as context)
 *     text    — searchable body keywords
 *
 * You can maintain this by hand, or regenerate it with tools/build_search_index.mjs
 * after adding pages.  It is loaded as a plain <script>, so search works even
 * when the site is opened directly from disk (file://).
 */
window.MANUAL_SEARCH = [
  {
    title: "Introduction",
    href: "index.html",
    section: "Getting started",
    text: "welcome pivlab manual particle image velocimetry overview navigation getting started"
  },
  {
    title: "The five-stage mindset",
    href: "pages/best-practices.html", hash: "mindset",
    section: "Best practices",
    text: "five stage mindset workflow acquire images choose parameters configure analysis validate interpret troubleshoot"
  },
  {
    title: "Particle seeding & image quality",
    href: "pages/best-practices.html", hash: "seeding",
    section: "Best practices",
    text: "particle seeding image quality optical contrast homogeneous distribution density laser sheet illumination"
  },
  {
    title: "Diagnose before you tune",
    href: "pages/best-practices.html", hash: "diagnose",
    section: "Best practices",
    text: "diagnose checklist particles visible illumination reflections laser sheet thickness seeding compression artifacts"
  },
  {
    title: "Troubleshooting by symptom",
    href: "pages/best-practices.html", hash: "troubleshooting",
    section: "Best practices",
    text: "troubleshooting symptom noisy vectors interpolated random spurious unrealistic velocities correlation fails batch"
  },
  {
    title: "The interface & workflow",
    href: "pages/interface.html", hash: "layout",
    section: "Getting started",
    text: "interface layout window menu bar settings panel image display workflow left to right order basic advanced mode"
  },
  {
    title: "The Tools panel (frame slider, zoom, pan, current point)",
    href: "pages/interface.html", hash: "tools",
    section: "Getting started",
    text: "tools panel frame slider toggle images zoom pan parallel processing current point readout u v x y quick access progress bar"
  },
  {
    title: "Mouse and coordinate conventions",
    href: "pages/interface.html", hash: "conventions",
    section: "Getting started",
    text: "left mouse button right mouse button coordinate system origin top left u v horizontal vertical"
  },
  {
    title: "Sessions — importing images",
    href: "pages/sessions.html", hash: "importing",
    section: "Getting started",
    text: "import images sequencing style time resolved pairwise reference add import dialog file browser"
  },
  {
    title: "Sessions vs. settings",
    href: "pages/sessions.html", hash: "vs",
    section: "Getting started",
    text: "session settings difference save load PIVlab session PIVlab settings resume reuse configuration"
  },
  {
    title: "Saving and loading a session",
    href: "pages/sessions.html", hash: "session-saveload",
    section: "Getting started",
    text: "save session load session PIVlab_session.mat resume project"
  },
  {
    title: "Saving and loading settings",
    href: "pages/sessions.html", hash: "settings-saveload",
    section: "Getting started",
    text: "save settings load settings PIVlab_set default settings reusable configuration"
  },
  {
    title: "Image pre-processing — CLAHE",
    href: "pages/preprocessing.html", hash: "clahe",
    section: "Image settings",
    text: "clahe contrast limited adaptive histogram equalization window size enhance contrast"
  },
  {
    title: "Image pre-processing — special-case filters",
    href: "pages/preprocessing.html", hash: "specialcases",
    section: "Image settings",
    text: "highpass intensity capping wiener2 denoise low pass kernel size noise reflections glare"
  },
  {
    title: "Auto contrast stretch",
    href: "pages/preprocessing.html", hash: "autocontrast",
    section: "Image settings",
    text: "auto contrast stretch histogram minimum maximum 16-bit images intensity"
  },
  {
    title: "Background subtraction",
    href: "pages/preprocessing.html", hash: "background",
    section: "Image settings",
    text: "background subtraction average intensity minimum intensity view save load background image"
  },
  {
    title: "Tips & tricks: preprocessing isn't a fix-all",
    href: "pages/preprocessing.html", hash: "tips",
    section: "Image settings",
    text: "preprocessing tips start simple one filter at a time compare processed unprocessed changes velocities not cosmetic"
  },
  {
    title: "Region of interest (ROI) — setting a ROI",
    href: "pages/roi.html", hash: "drawing",
    section: "Image settings",
    text: "region of interest roi select rectangle crop x y width height draw"
  },
  {
    title: "ROI vs. masking",
    href: "pages/roi.html", hash: "vs-masking",
    section: "Image settings",
    text: "roi vs masking difference rectangle crop nan per frame combine"
  },
  {
    title: "Choosing a PIV algorithm",
    href: "pages/piv-settings.html", hash: "algorithm",
    section: "Analysis",
    text: "algorithm multipass fft window deformation ensemble dcc direct cross correlation optical flow wofv wavelet which to use"
  },
  {
    title: "Multipass FFT window deformation & Ensemble",
    href: "pages/piv-settings.html", hash: "fft-ensemble",
    section: "Analysis",
    text: "interrogation area step pass 1 2 3 4 overlap percentage multipass ensemble"
  },
  {
    title: "Single pass direct cross-correlation (DCC)",
    href: "pages/piv-settings.html", hash: "dcc",
    section: "Analysis",
    text: "dcc direct cross correlation single pass"
  },
  {
    title: "Optical flow (wOFV) settings",
    href: "pages/piv-settings.html", hash: "wofv",
    section: "Analysis",
    text: "optical flow wofv wavelet parallel patches median filter pyramid levels smoothness eta vector density one vector per pixel"
  },
  {
    title: "Sub-pixel estimation, robustness, uncertainty",
    href: "pages/piv-settings.html", hash: "shared",
    section: "Analysis",
    text: "sub-pixel estimator gauss disable auto-correlation correlation robustness estimate uncertainty sciacchitano"
  },
  {
    title: "Balancing particle count and displacement",
    href: "pages/piv-settings.html", hash: "particles-vs-resolution",
    section: "Analysis",
    text: "interrogation area particles per ia displacement pixels resolution tips choosing suitable"
  },
  {
    title: "How multi-pass deformation changes the rules",
    href: "pages/piv-settings.html", hash: "multipass-changes-rules",
    section: "Analysis",
    text: "quarter rule 1/4 rule multi-pass window deformation pass 1 robustness noise bias"
  },
  {
    title: "A practical interrogation-area starting workflow",
    href: "pages/piv-settings.html", hash: "starting-workflow",
    section: "Analysis",
    text: "starting workflow interrogation area displacement pass 1 subsequent passes particle count noisy resolution"
  },
  {
    title: "When not to fix it with interrogation area size",
    href: "pages/piv-settings.html", hash: "dont-fix-with-ia",
    section: "Analysis",
    text: "don't tune around bad image seeding compression laser sheet illumination suggest settings problematic image data warning"
  },
  {
    title: "Choosing Δt together with the interrogation area",
    href: "pages/piv-settings.html", hash: "choosing-dt",
    section: "Analysis",
    text: "time step delta t dt displacement pixels tools panel current point click vector tune"
  },
  {
    title: "Analyzing current frame vs. all frames",
    href: "pages/analyze.html", hash: "running",
    section: "Analysis",
    text: "analyze current frame all frames ensemble start ensemble analysis run"
  },
  {
    title: "Tracking and cancelling an analysis",
    href: "pages/analyze.html", hash: "progress",
    section: "Analysis",
    text: "progress cancel refresh display frame progress total progress time left parallel"
  },
  {
    title: "Clearing results",
    href: "pages/analyze.html", hash: "clear",
    section: "Analysis",
    text: "clear all results reset re-run derived parameters"
  },
  {
    title: "Export — still image or animation",
    href: "pages/export.html", hash: "image",
    section: "Data",
    text: "export still image animation png jpg pdf matlab figure avi mpeg4 video quality fps frames per second image size resolution"
  },
  {
    title: "Export — text file (ASCII)",
    href: "pages/export.html", hash: "ascii",
    section: "Data",
    text: "ascii text file export delimiter comma tab space add file information column headers derivatives"
  },
  {
    title: "Export — MAT file",
    href: "pages/export.html", hash: "mat",
    section: "Data",
    text: "mat file matlab export vorticity magnitude divergence q criterion shear strain vector angle correlation coefficient"
  },
  {
    title: "Export — Tecplot file",
    href: "pages/export.html", hash: "tecplot",
    section: "Data",
    text: "tecplot export derivatives save current frame all frames"
  },
  {
    title: "Export — Paraview binary VTK",
    href: "pages/export.html", hash: "paraview",
    section: "Data",
    text: "paraview vtk export binary save current frame all frames"
  },
  {
    title: "Export — all results to Matlab workspace",
    href: "pages/export.html", hash: "workspace",
    section: "Data",
    text: "workspace export assignin base variables x y u v original filtered smoothed uncertainty map"
  },
  {
    title: "Keyboard shortcuts",
    href: "pages/shortcuts.html", hash: "top",
    section: "Reference",
    text: "keyboard shortcuts ctrl n e i s a v z d m t p q b g h accelerator hotkey"
  },
  {
    title: "Setting up a ChArUco marker board",
    href: "pages/camera-calibration.html", hash: "markerboard",
    section: "Image settings",
    text: "charuco marker board rows columns checker size origin color guess parameters generate board"
  },
  {
    title: "Camera calibration (lens undistortion)",
    href: "pages/camera-calibration.html", hash: "calibration",
    section: "Image settings",
    text: "camera calibration lens undistortion scheimpflug estimate parameters reprojection error black borders"
  },
  {
    title: "Image rectification",
    href: "pages/camera-calibration.html", hash: "rectification",
    section: "Image settings",
    text: "image rectification alignment laser sheet target coordinate system upscaling"
  },
  {
    title: "Velocity limits (scatter plot validation)",
    href: "pages/validation-velocity.html", hash: "limits",
    section: "Validation",
    text: "velocity limits rectangle freehand auto scatter plot u v outliers cluster display all frames"
  },
  {
    title: "Statistical validation filters",
    href: "pages/validation-velocity.html", hash: "statistical",
    section: "Validation",
    text: "standard deviation filter local median filter westerweel scarano magnitude notch filter threshold"
  },
  {
    title: "Manually rejecting vectors",
    href: "pages/validation-velocity.html", hash: "manual",
    section: "Validation",
    text: "manually reject vector click base discard"
  },
  {
    title: "Interpolating missing vectors",
    href: "pages/validation-velocity.html", hash: "interpolate",
    section: "Validation",
    text: "interpolate missing data orange vectors gaps"
  },
  {
    title: "Tuning strategy: isolate, then combine",
    href: "pages/validation-velocity.html", hash: "tuning",
    section: "Validation",
    text: "tuning strategy isolate one filter at a time test different frames combine threshold dataset"
  },
  {
    title: "Valid detection probability & vector colors",
    href: "pages/validation-velocity.html", hash: "reading",
    section: "Validation",
    text: "valid detection probability vdp green cyan orange vector color legend"
  },
  {
    title: "Image-based validation filters",
    href: "pages/validation-image.html", hash: "top",
    section: "Validation",
    text: "image based validation filter low contrast bright objects correlation coefficient filter threshold suggest threshold"
  },
  {
    title: "Setting the calibration scale",
    href: "pages/spatial-calibration.html", hash: "scaling",
    section: "Spatial calibration",
    text: "reference length pixels real distance mm time step ms displacement velocity calibration"
  },
  {
    title: "Axis directions and origin offset",
    href: "pages/spatial-calibration.html", hash: "offsets",
    section: "Spatial calibration",
    text: "x axis direction y axis direction offset origin coordinate system top left bottom right"
  },
  {
    title: "Derived flow parameters (vorticity, divergence, Q criterion, …)",
    href: "pages/derive-spatial.html", hash: "parameter",
    section: "Plot & post-processing",
    text: "derive parameters vorticity magnitude divergence q criterion shear rate strain rate line integral convolution lic vector direction correlation coefficient uncertainty display parameter"
  },
  {
    title: "How each parameter is computed (equations)",
    href: "pages/derive-spatial.html", hash: "equations",
    section: "Plot & post-processing",
    text: "equation equations formula formulas definition how computed calculated math derivative partial derivative gradient calibrated grid units"
  },
  {
    title: "Equations: magnitude, u, v and vector direction",
    href: "pages/derive-spatial.html", hash: "eq-velocity",
    section: "Plot & post-processing",
    text: "magnitude equation speed vector length u component v component vector direction angle atan2 atan2d degrees clockwise counter-clockwise orientation zero degrees points right axis direction"
  },
  {
    title: "Equations: vorticity, divergence, shear, strain, Q criterion",
    href: "pages/derive-spatial.html", hash: "eq-gradient",
    section: "Plot & post-processing",
    text: "vorticity equation curl sign convention divergence equation shear rate rate-of-strain tensor magnitude simple strain rate q criterion vortex identification rotation strain gradient matlab"
  },
  {
    title: "Equations: correlation coefficient, uncertainty and LIC",
    href: "pages/derive-spatial.html", hash: "eq-analysis",
    section: "Plot & post-processing",
    text: "correlation coefficient pearson deformed interrogation window last pass uncertainty particle image disparity sciacchitano wieneke scarano image matching line integral convolution lic cabral leedom reference citation"
  },
  {
    title: "Data smoothing (2D, temporal)",
    href: "pages/derive-spatial.html", hash: "smoothing",
    section: "Plot & post-processing",
    text: "data smoothing 2d time moving average smoothn damien garcia temporal window bartlett smoothing before derivatives noise amplification"
  },
  {
    title: "Subtracting a background flow",
    href: "pages/derive-spatial.html", hash: "subtract",
    section: "Plot & post-processing",
    text: "subtract flow mean u mean v highpass vector field background flow convection velocity"
  },
  {
    title: "Colormap limits and display",
    href: "pages/derive-spatial.html", hash: "colormap",
    section: "Plot & post-processing",
    text: "colormap limits autoscale min max extrapolate border spring inpainting video rendering"
  },
  {
    title: "Vector appearance (scale, width, density)",
    href: "pages/plot-appearance.html", hash: "vectors",
    section: "Plot & post-processing",
    text: "vector scale width nth vector hide vectors uniform scale power law vector scale autoscale"
  },
  {
    title: "Vector colors",
    href: "pages/plot-appearance.html", hash: "colors",
    section: "Plot & post-processing",
    text: "vector colors valid second peak replaced interpolated derivatives mask transparency"
  },
  {
    title: "Coloring vectors by velocity magnitude",
    href: "pages/plot-appearance.html", hash: "magnitude",
    section: "Plot & post-processing",
    text: "magnitude colored vectors colour by speed velocity magnitude colormap colorbar rainbow arrows uniform vector scale combine calibrated m/s px/frame"
  },
  {
    title: "Derived-parameter colormap",
    href: "pages/plot-appearance.html", hash: "derived-appearance",
    section: "Plot & post-processing",
    text: "colormap opacity parula jet hsv hot cool colormap steps image interpolation bilinear bicubic"
  },
  {
    title: "Color legend / colorbar",
    href: "pages/plot-appearance.html", hash: "colorbar",
    section: "Plot & post-processing",
    text: "colorbar show position numeric format scientific notation"
  },
  {
    title: "Reference vector",
    href: "pages/plot-appearance.html", hash: "reference",
    section: "Plot & post-processing",
    text: "reference vector scale position corner"
  },
  {
    title: "Drawing a poly-line or circle to extract data",
    href: "pages/extract-polyline.html", hash: "drawing",
    section: "Extractions",
    text: "poly-line polyline circle circle series tangent velocity draw save coords load coords"
  },
  {
    title: "Tangent and normal velocity along a line",
    href: "pages/extract-polyline.html", hash: "extracting",
    section: "Extractions",
    text: "tangent velocity normal velocity component parallel perpendicular line circle flux flow rate across control surface vortex swirl"
  },
  {
    title: "Extracting the average over an area",
    href: "pages/extract-area.html", hash: "extracting",
    section: "Extractions",
    text: "extract area average rectangle polygon circle circle series calculate results"
  },
  {
    title: "Velocity histogram (and peak locking)",
    href: "pages/statistics.html", hash: "histogram",
    section: "Statistics",
    text: "histogram u velocity v velocity magnitude sub-pixels bins peak locking bias"
  },
  {
    title: "Stereo PIV settings (not yet implemented)",
    href: "pages/stereo-piv.html", hash: "top",
    section: "Analysis",
    text: "stereo piv disparity correction 2d3c not implemented scheimpflug tilted sensor"
  },
  {
    title: "Phase averaging and frame selection for temporal derivation",
    href: "pages/derive-temporal.html", hash: "selecting",
    section: "Plot & post-processing",
    text: "frames to process phase average append replace mean sum stdev tke turbulent kinetic energy"
  },
  {
    title: "Phase average of periodic (harmonic) flow",
    href: "pages/derive-temporal.html", hash: "phase-average",
    section: "Plot & post-processing",
    text: "phase mean periodic harmonic flow frames per period oscillation cycle flapping wing pulsating jet calculate phase mean"
  },
  {
    title: "Drawing streamlines, rakes and streamslices",
    href: "pages/streamlines.html", hash: "drawing",
    section: "Plot & post-processing",
    text: "streamlines draw rake streamslice hold delete color line width"
  },
  {
    title: "Measuring distance and angle",
    href: "pages/markers.html", hash: "distance",
    section: "Plot & post-processing",
    text: "measure distance angle draw line delta x delta y length degrees horizontal vertical"
  },
  {
    title: "Placing persistent markers",
    href: "pages/markers.html", hash: "markers",
    section: "Plot & post-processing",
    text: "markers set markers clear hold markers display markers persistent point highlight"
  },
  {
    title: "Correlation matrices",
    href: "pages/correlation-matrices.html", hash: "top",
    section: "Plot & post-processing",
    text: "correlation matrices retrieve click vector passes diagnostic peak noisy"
  },
  {
    title: "Second monitor display (experimental)",
    href: "pages/second-monitor.html", hash: "top",
    section: "Plot & post-processing",
    text: "second monitor display experimental full screen presentation dual display"
  },
  {
    title: "Synthetic image particle settings",
    href: "pages/synthetic-images.html", hash: "general",
    section: "Synthetic images",
    text: "particle image generation number of particles diameter sheet thickness noise random z position image size"
  },
  {
    title: "Flow field types (Rankine, Oseen, rotation, linear shift)",
    href: "pages/synthetic-images.html", hash: "flowtype",
    section: "Synthetic images",
    text: "rankine vortex hamel oseen vortex linear shift rotation membrane flow simulation ground truth ground-truth"
  },
  {
    title: "Capturing images: camera and synchronizer workflow",
    href: "pages/capture.html", hash: "workflow",
    section: "Image acquisition",
    text: "capture images camera synchronizer simplesync frame rate pulse distance laser energy connect com port start save checkbox image amount"
  },
  {
    title: "Trying capture with just a webcam",
    href: "pages/capture.html", hash: "webcam",
    section: "Image acquisition",
    text: "webcam demo no synchronizer usb webcam support package no hardware required try capture"
  },
  {
    title: "Masking — overview",
    href: "pages/masking.html", hash: "top",
    section: "Image settings",
    text: "masking exclude regions walls objects glare reflections nan analysis image masking panel"
  },
  {
    title: "Opening the masking panel",
    href: "pages/masking.html", hash: "opening",
    section: "Image settings",
    text: "open masking image settings define masks exclude regions menu panel navigate"
  },
  {
    title: "Mode and Capabilities",
    href: "pages/masking.html", hash: "mode",
    section: "Image settings",
    text: "edit mask preview mask basic expert mode capabilities dropdown"
  },
  {
    title: "Drawing a mask",
    href: "pages/masking.html", hash: "drawing",
    section: "Image settings",
    text: "draw mask free hand assisted circle rectangle polygon left click right click shape rod cylinder"
  },
  {
    title: "Applying a mask to several frames",
    href: "pages/masking.html", hash: "frames",
    section: "Image settings",
    text: "copy mask to frames range 1:end clear masks in frames multiple frames time resolved"
  },
  {
    title: "Overlapping masks — keeping only a region",
    href: "pages/masking.html", hash: "overlapping",
    section: "Image settings",
    text: "overlapping masks overlap even odd xor cancel hole mask everything except region keep only centre middle inverse invert union combine"
  },
  {
    title: "Editing, removing and combining masks",
    href: "pages/masking.html", hash: "editing",
    section: "Image settings",
    text: "shrink grow simplify subdivide optimize combine delete edit modify mask union merge"
  },
  {
    title: "Automatic masks (Expert mode)",
    href: "pages/masking.html", hash: "automatic",
    section: "Image settings",
    text: "automatic mask expert bright area dark area low contrast threshold median filter morphology preview make mask for all frames"
  },
  {
    title: "Saving, loading and importing masks",
    href: "pages/masking.html", hash: "saveload",
    section: "Image settings",
    text: "save all masks load masks import pixel mask binary image reuse mat file"
  }
];
