/*
 * nav.js — Single source of truth for the manual's navigation tree.
 *
 * This mirrors PIVlab's actual menu structure (see +gui/generateMenu.m) —
 * one item per menu concept. The master content plan, priorities and source
 * references for each topic live in manual/CONTENT_PLAN.md; read that file
 * first when adding a page here.
 *
 * To add a page: write pages/<slug>.html, then flip that item's `status`
 * from "soon" to "live", add a one-line `blurb` (shown on the homepage's
 * "Start here" cards — auto-built from this file, so the homepage never goes
 * stale), and check it off in CONTENT_PLAN.md. Pages that are not written yet
 * use `status: "soon"` and render as a greyed-out, non-clickable placeholder
 * so the intended structure is visible.
 */
window.MANUAL_NAV = {
  title: "PIVlab Manual",
  sections: [
    {
      title: "Getting started",
      items: [
        { label: "Introduction",                       href: "index.html",                    status: "live" },
        { label: "Interface & workflow",               href: "pages/interface.html",          status: "live",
          blurb: "The window layout, the left-to-right workflow, and the Tools panel." },
        { label: "Sessions: new, load, save",          href: "pages/sessions.html",            status: "live",
          blurb: "Import an image sequence, and know when to save a session vs. just settings." }
      ]
    },
    {
      title: "Best practices",
      items: [
        { label: "Best practices & troubleshooting",   href: "pages/best-practices.html",     status: "live",
          blurb: "Getting good images, diagnosing problems before tuning, and troubleshooting by symptom." }
      ]
    },
    {
      title: "Image settings",
      items: [
        { label: "Camera calibration & rectification", href: "pages/camera-calibration.html", status: "live",
          blurb: "Correct lens distortion and align the image with your target coordinate system." },
        { label: "Image pre-processing",                href: "pages/preprocessing.html",       status: "live",
          blurb: "CLAHE, filtering and other enhancements before correlation." },
        { label: "Region of interest (ROI)",            href: "pages/roi.html",                 status: "live",
          blurb: "Restrict the analysis to a rectangular area of the image." },
        { label: "Masking",                             href: "pages/masking.html",              status: "live",
          blurb: "Exclude walls, objects and reflections so they are not analysed." }
      ]
    },
    {
      title: "Analysis",
      items: [
        { label: "PIV settings",                        href: "pages/piv-settings.html",         status: "live",
          blurb: "Choose the algorithm, interrogation areas and passes." },
        { label: "Stereo PIV settings",                 href: "pages/stereo-piv.html",            status: "live",
          blurb: "Not implemented yet — current status and related infrastructure." },
        { label: "Running the analysis (ANALYZE!)",     href: "pages/analyze.html",               status: "live",
          blurb: "Analyze one frame or the whole session, and track progress." }
      ]
    },
    {
      title: "Validation",
      items: [
        { label: "Velocity-based validation",           href: "pages/validation-velocity.html",  status: "live",
          blurb: "Remove spurious vectors with statistical filters, velocity limits, and manual rejection." },
        { label: "Image-based validation",              href: "pages/validation-image.html",     status: "live",
          blurb: "Reject vectors from low-contrast, over-bright or poorly-correlated image regions." }
      ]
    },
    {
      title: "Spatial calibration",
      items: [
        { label: "Calibrating pixels to mm",            href: "pages/spatial-calibration.html",  status: "live",
          blurb: "Convert pixels and frames into millimeters and velocities." }
      ]
    },
    {
      title: "Plot & post-processing",
      items: [
        { label: "Deriving spatial parameters",         href: "pages/derive-spatial.html",       status: "live",
          blurb: "Vorticity, divergence, shear, Q criterion, smoothing and background-flow subtraction." },
        { label: "Deriving temporal parameters",        href: "pages/derive-temporal.html",      status: "live",
          blurb: "Mean, sum, standard deviation and turbulent kinetic energy across frames." },
        { label: "Modifying plot appearance",           href: "pages/plot-appearance.html",      status: "live",
          blurb: "Vector scale, colors, colormaps, colorbars and the reference vector." },
        { label: "Streamlines",                         href: "pages/streamlines.html",           status: "live",
          blurb: "Draw manual streamlines, rakes, or an automatic streamslice." },
        { label: "Markers / distance / angle",          href: "pages/markers.html",               status: "live",
          blurb: "Measure distance/angle between two points and place persistent markers." },
        { label: "Correlation matrices",                href: "pages/correlation-matrices.html", status: "live",
          blurb: "Inspect the raw correlation surface behind any single vector." },
        { label: "Second monitor display",              href: "pages/second-monitor.html",       status: "live",
          blurb: "Mirror the vector plot full-screen to a second monitor (experimental)." }
      ]
    },
    {
      title: "Extractions",
      items: [
        { label: "Parameters from poly-line",           href: "pages/extract-polyline.html",     status: "live",
          blurb: "Extract a velocity or vorticity profile along a drawn line or circle." },
        { label: "Parameters from area",                href: "pages/extract-area.html",          status: "live",
          blurb: "Compute the average of a derived parameter over a drawn area." }
      ]
    },
    {
      title: "Statistics",
      items: [
        { label: "Statistics",                          href: "pages/statistics.html",            status: "live",
          blurb: "Mean/min/max readouts, histograms and a u-v scatter plot." }
      ]
    },
    {
      title: "Synthetic images",
      items: [
        { label: "Synthetic particle image generation", href: "pages/synthetic-images.html",     status: "live",
          blurb: "Generate test image pairs with a known ground-truth flow field." }
      ]
    },
    {
      title: "Data",
      items: [
        { label: "Exporting results",                   href: "pages/export.html",                status: "live",
          blurb: "Six ways to get your results out — images, text, MAT, Tecplot, VTK, or straight to the workspace." },
        { label: "Command line (API)",                  href: "pages/command-line.html",          status: "live",
          blurb: "Run the whole analysis from a MATLAB script with the pivlab.* functions — same code as the GUI." }
      ]
    },
    {
      title: "Image acquisition",
      items: [
        { label: "Capturing images from a camera",      href: "pages/capture.html",                status: "live",
          blurb: "Acquire PIV image pairs live from a camera, with optional laser sync." }
      ]
    },
    {
      title: "Reference",
      items: [
        { label: "Keyboard shortcuts",                  href: "pages/shortcuts.html",              status: "live",
          blurb: "Jump straight to any panel without touching the menu." }
      ]
    }
  ]
};
