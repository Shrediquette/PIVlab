% PIVLAB  Command-line interface (API) of PIVlab
%
% Run a complete PIV analysis from the command line with the same functions that the PIVlab
% GUI uses. Every function works with only its required inputs and then uses the PIVlab
% defaults. Type "help pivlab.<function>" for the options of each function.
%
% Typical workflow
%   imgs = pivlab.readImages("Example_data/Jet_*.jpg", "pairwise");   % select and pair the images
%   imgs = pivlab.preprocess(imgs);                                    % CLAHE + intensity stretch
%   res  = pivlab.analyze(imgs);                                       % PIV analysis
%   res  = pivlab.filter(res);                                         % remove outliers, interpolate
%   res  = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=1234);        % calibration -> m, m/s
%   [res, vort] = pivlab.derive(res, "vorticity");                     % derived quantities
%   m    = pivlab.temporal(res, "mean");                               % temporal mean
%   pivlab.display(m, Overlay="magnitude");                            % figure like in PIVlab
%   pivlab.saveSession(res, "analysis.mat");                           % open it in the PIVlab GUI
%
% Images and pre-processing
%   readImages   - Select the images and the sequencing ("pairwise", "timeresolved", "reference")
%   preprocess   - Contrast enhancement, background removal, region of interest, mask
%   getImage     - Read one (pre-processed) image
%
% Analysis and post-processing
%   analyze      - PIV analysis (FFT window deformation, ensemble, DCC, optical flow)
%   filter       - Vector validation: remove outliers and interpolate them
%   toMetric     - Calibration: convert pixels and pixels/frame to m and m/s
%   derive       - Vorticity, magnitude, divergence, Q criterion, shear, strain, LIC, ...
%   temporal     - Temporal mean, standard deviation, sum, turbulent kinetic energy
%   display      - Show vectors and colour maps like the PIVlab GUI
%
% Settings and sessions
%   defaults     - Default settings (the settings the PIVlab GUI starts with)
%   loadSettings - Settings from a PIVlab settings file or session (detected automatically)
%   loadSession  - Results of a PIVlab session
%   saveSession  - Save results as a PIVlab session (can be opened in the GUI)
%
% Example scripts: Example_scripts/PIVlab_api_*.m
