function c = colors(what, varargin)
%COLORS Colours of the 3D scenes.
%   c = scene3d.colors('axes')           3 x 3: x red, y green, z blue (axes of the results)
%   c = scene3d.colors('sequence', n)    n x 3: many cameras (calibration images), one hue sweep at the
%                                        same lightness, readable on dark and light backgrounds
%   c = scene3d.colors('mix', a, b, t)   (1 - t) * a + t * b
%   c = scene3d.colors('shadow', bg)     shadow colour on the background bg
switch what
    case 'axes'
        c = [0.90 0.20 0.20; 0.20 0.72 0.25; 0.25 0.45 1.00];
    case 'sequence'
        n = varargin{1};
        h = linspace(0.55, 1.05, max(n, 1))';
        c = hsv2rgb([mod(h, 1), 0.65 * ones(numel(h), 1), 0.95 * ones(numel(h), 1)]);
        c = c(1:n, :);
    case 'mix'
        c = (1 - varargin{3}) * varargin{1} + varargin{3} * varargin{2};
    case 'shadow'
        if mean(varargin{1}) < 0.5
            c = [0 0 0];
        else
            c = 0.25 * [1 1 1];
        end
    otherwise
        error('scene3d.colors: unknown colour %s', what);
end
end
