function setup = setup_3d(opts)
% Setup of the 3D / stereo particle image generator (simulate.recording_3d, simulate.preview_3d)
% with the default values of the PIVlab panel "3D particle image generator".
%   setup = simulate.setup_3d()
%   setup = simulate.setup_3d(Board=board)
%
% World coordinates = board coordinates in mm: origin at the first inner corner of the ChArUco
% board, x along the columns (right), y along the rows (down), z into the board. The cameras look
% at the board from z < 0 (or from behind, z > 0: they see the board mirrored).
%
%   setup.cameras(k)  Position [x y z] (camera centre), Target [x y] (aim point on the board, z = 0),
%                     RadialDistortion [k1 k2] (MATLAB / OpenCV model, normalized image coordinates)
%   setup.sensor      ImageSize [height width] px, PixelPitch [um], FocalLength (lens) [mm]
%   setup.board       PatternDims [rows columns], CheckerSize, MarkerSize [mm], MarkerFamily, OriginCheckerColor
%   setup.sheet       Offset [mm] (distance from the board at the centre of the aim points, positive
%                     towards camera 1), TiltX, TiltY [deg] (rotation about the board x / y axis),
%                     Thickness [mm] (e^-2 intensity)
%   setup.flow        Type: 'vortex_jet' (Rankine vortex with an out-of-plane jet in its core),
%                     'rankine', 'uniform' (u = InPlane, v = 0), 'rotation' (solid body), 'membrane';
%                     InPlane [mm] (max in-plane displacement per image pair), Radius [mm] (vortex
%                     core), OutOfPlane [mm] (peak w of the jet, or constant w of the other flows)
%   setup.particles   Density [particles per pixel], Diameter, DiameterVariation [px], Noise (imnoise variance)
%   setup.output      Pairs (image pairs per camera), CalibrationImages (per camera), Backgrounds (mat file
%                     with the cell array backgrounds, or a folder with photos, e.g. of the experimenter:
%                     heavily blurred background of the calibration images; none: a synthetic background)
arguments
    opts.Board struct = struct([])
end
d = gui.default_settings;
t = d.tools;
setup.cameras = struct('Position', {[t.sim3d_c1x t.sim3d_c1y t.sim3d_c1z], [t.sim3d_c2x t.sim3d_c2y t.sim3d_c2z]}, ...
    'Target', {[t.sim3d_c1ax t.sim3d_c1ay], [t.sim3d_c2ax t.sim3d_c2ay]}, ...
    'RadialDistortion', {[t.sim3d_c1k1 t.sim3d_c1k2], [t.sim3d_c2k1 t.sim3d_c2k2]});
if t.sim3d_ncams == 1
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
setup.flow = struct('Type', types{t.sim3d_flow}, 'InPlane', t.sim3d_displ, 'Radius', t.sim3d_radius, 'OutOfPlane', t.sim3d_w);
setup.particles = struct('Density', t.sim3d_ppp, 'Diameter', t.sim3d_psize, 'DiameterVariation', t.sim3d_pvar, 'Noise', t.sim3d_noise);
setup.output = struct('Pairs', t.sim3d_pairs, 'CalibrationImages', t.sim3d_ncalib, ...
    'Backgrounds', fullfile(fileparts(fileparts(mfilename('fullpath'))), 'images', 'calibration_backgrounds.mat'));
end
