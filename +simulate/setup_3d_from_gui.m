function setup = setup_3d_from_gui(handles)
% Setup of the 3D particle image generator (simulate.setup_3d) from the panel "3D particle image
% generator"; the board from the marker board setup of the camera calibration.
if nargin < 1
    handles = gui.gethand;
end
v = @(tag) str2double(get(handles.(tag), 'String'));
setup = simulate.setup_3d(Board=stereo.board_from_gui(handles));
n = get(handles.sim3d_ncams, 'Value');
for k = 1:2
    c = sprintf('sim3d_c%d', k);
    cams(k) = struct('Position', [v([c 'x']) v([c 'y']) v([c 'z'])], 'Target', [v([c 'ax']) v([c 'ay'])], ...
        'RadialDistortion', [v([c 'k1']) v([c 'k2'])]); %#ok<AGROW>
end
setup.cameras = cams(1:n);
setup.sensor = struct('ImageSize', round([v('sim3d_sizey') v('sim3d_sizex')]), 'PixelPitch', v('sim3d_pitch'), 'FocalLength', v('sim3d_focal'));
setup.sheet = struct('Offset', v('sim3d_sheet_offset'), 'TiltX', v('sim3d_sheet_tiltx'), 'TiltY', v('sim3d_sheet_tilty'), ...
    'Thickness', v('sim3d_sheet_thick'));
types = simulate.flow_types_3d;
setup.flow = struct('Type', types{get(handles.sim3d_flow, 'Value')}, 'InPlane', v('sim3d_displ'), 'Radius', v('sim3d_radius'), ...
    'OutOfPlane', v('sim3d_w'));
setup.particles = struct('Density', v('sim3d_ppp'), 'Diameter', v('sim3d_psize'), 'DiameterVariation', v('sim3d_pvar'), ...
    'Noise', v('sim3d_noise'));
setup.output.Pairs = round(v('sim3d_pairs')); % (Backgrounds: default folder of simulate.setup_3d)
setup.output.CalibrationImages = round(v('sim3d_ncalib'));
end
