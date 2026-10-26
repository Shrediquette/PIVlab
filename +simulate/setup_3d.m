function setup = setup_3d(opts)
% Setup of the particle image generator (simulate.recording_3d, simulate.preview_3d) with the
% default values of the PIVlab panel "Particle image generator".
%   setup = simulate.setup_3d()
%   setup = simulate.setup_3d(Board=board)
%   setup = simulate.setup_3d(Mode='cameras')   camera setup instead of the default setup
%
% World coordinates = board coordinates in mm: origin at the first inner corner of the ChArUco
% board, x along the columns (right), y along the rows (down), z into the board. The cameras look
% at the board from z < 0 (or from behind, z > 0: they see the board mirrored).
%
%   setup.Mode        'simple': one camera looks straight at the light sheet (orthographic, no lens;
%                     pixel = sheet position / Simple.PixelSize; no board, no calibration images);
%                     'cameras': setup.cameras with lens and perspective (1 camera, or 2: stereo-PIV)
%   setup.Simple      PixelSize [mm] (size of a pixel in the light sheet, simple setup)
%   setup.cameras(k)  Position [x y z] (camera centre), Target [x y] (aim point on the board, z = 0),
%                     RadialDistortion [k1 k2] (MATLAB / OpenCV model, normalized image coordinates)
%   setup.sensor      ImageSize [height width] px, PixelPitch [um], FocalLength (lens) [mm]
%   setup.board       PatternDims [rows columns], CheckerSize, MarkerSize [mm], MarkerFamily, OriginCheckerColor
%   setup.sheet       Offset [mm] (distance from the board at the centre of the aim points, positive
%                     towards camera 1), TiltX, TiltY [deg] (rotation about the board x / y axis),
%                     Thickness [mm] (e^-2 intensity); simple setup: only Thickness
%   setup.flow        Type: 'vortex_jet' (Rankine vortex with an out-of-plane jet in its core),
%                     'rankine', 'oseen' (Hamel-Oseen vortex), 'uniform' (u = InPlane, v = 0),
%                     'rotation' (solid body), 'membrane', 'sphere' (unsteady wake of a sphere),
%                     'jet' (free round jet, nozzle at the left edge of the views); sphere and jet:
%                     simulate.flow_simulation_3d, every image pair is a later moment of the flow;
%                     InPlane [mm] (max in-plane displacement per image pair; sphere: free stream,
%                     jet: jet exit displacement), Radius [mm] (vortex core), OutOfPlane [mm] (peak
%                     w of the jet, or constant w of the other flows), Distance [mm] (rankine,
%                     oseen: > 0 a pair of counter-rotating vortices this far apart), Diameter [mm]
%                     (sphere / nozzle), Spacing (sphere, jet: time between image pairs in D/U, i.e.
%                     travel between the pairs in diameters)
%   setup.particles   Density [particles per pixel], Diameter, DiameterVariation [px], Noise (imnoise variance)
%   setup.output      Pairs (image pairs per camera), CalibrationImages (per camera), Backgrounds (mat file
%                     with the cell array backgrounds, or a folder with photos, e.g. of the experimenter:
%                     heavily blurred background of the calibration images; none: a synthetic background)
arguments
    opts.Board struct = struct([])
    opts.Mode {mustBeMember(opts.Mode, {'', 'simple', 'cameras'})} = ''
end
d = gui.default_settings;
t = d.tools;
setup.Mode = 'cameras';
if t.sim3d_setup == 1
    setup.Mode = 'simple';
end
if ~isempty(opts.Mode)
    setup.Mode = opts.Mode;
end
setup.Simple = struct('PixelSize', t.sim3d_pixel);
setup.cameras = struct('Position', {[t.sim3d_c1x t.sim3d_c1y t.sim3d_c1z], [t.sim3d_c2x t.sim3d_c2y t.sim3d_c2z]}, ...
    'Target', {[t.sim3d_c1ax t.sim3d_c1ay], [t.sim3d_c2ax t.sim3d_c2ay]}, ...
    'RadialDistortion', {[t.sim3d_c1k1 t.sim3d_c1k2], [t.sim3d_c2k1 t.sim3d_c2k2]});
if t.sim3d_setup == 2
    setup.cameras = setup.cameras(1);
end
setup.sensor = struct('ImageSize', [t.sim3d_sizey t.sim3d_sizex], 'PixelPitch', t.sim3d_pitch, 'FocalLength', t.sim3d_focal);
if isempty(opts.Board)
    c = d.calibration;
    colors = {'black', 'white'};
    setup.board = struct('PatternDims', [c.calib_rows c.calib_columns], 'CheckerSize', c.calib_checkersize, ...
        'MarkerSize', c.calib_markersize, 'MarkerFamily', "DICT_4X4_1000", 'OriginCheckerColor', string(colors{c.calib_origincolor}));
else
    setup.board = opts.Board;
end
setup.sheet = struct('Offset', t.sim3d_sheet_offset, 'TiltX', t.sim3d_sheet_tiltx, 'TiltY', t.sim3d_sheet_tilty, ...
    'Thickness', t.sim3d_sheet_thick);
types = simulate.flow_types_3d;
setup.flow = struct('Type', types{t.sim3d_flow}, 'InPlane', t.sim3d_displ, 'Radius', t.sim3d_radius, 'OutOfPlane', t.sim3d_w, ...
    'Distance', t.sim3d_vortex_distance, 'Diameter', t.sim3d_diameter, 'Spacing', t.sim3d_pair_time);
setup.particles = struct('Density', t.sim3d_ppp, 'Diameter', t.sim3d_psize, 'DiameterVariation', t.sim3d_pvar, 'Noise', t.sim3d_noise);
setup.output = struct('Pairs', t.sim3d_pairs, 'CalibrationImages', t.sim3d_ncalib, ...
    'Backgrounds', fullfile(fileparts(fileparts(mfilename('fullpath'))), 'images', 'calibration_backgrounds.mat'));
end
