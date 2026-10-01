function cmap = vector_colormap_core(map_name, nLevels, maxLevels, nVectors)
%VECTOR_COLORMAP_CORE Colormap for magnitude-colored vectors, as N-by-3 RGB (no GUI needed).
%   cmap = plot.vector_colormap_core(map_name, nLevels, maxLevels, nVectors)
%   map_name   PIVlab colormap name ('Parula','HSV',...,'Plasma')
%   nLevels    number of colour steps selected by the user
%   maxLevels  cap for the number of levels (speed, see plot.vector_colormap)
%   nVectors   optional: number of vectors, fewer levels for small fields
%   Used by plot.vector_colormap (GUI) and plot.draw_vectors.
if nargin < 3 || isempty(maxLevels)
    maxLevels = 64;
end
here = fileparts(mfilename('fullpath'));
cmap = [];
switch lower(char(map_name))
    case 'parula'
        cmap = load_map(fullfile(here,'parula.mat'),'parula');
    case 'hsb'
        cmap = load_map(fullfile(here,'hsbmap.mat'),'hsb');
    case 'plasma'
        cmap = load_map(fullfile(here,'plasma.mat'),'plasma');
    case 'hsv'
        cmap = hsv(256);
    case 'jet'
        cmap = jet(256);
    case 'hot'
        cmap = hot(256);
    case 'cool'
        cmap = cool(256);
    case 'spring'
        cmap = spring(256);
    case 'summer'
        cmap = summer(256);
    case 'autumn'
        cmap = autumn(256);
    case 'winter'
        cmap = winter(256);
    case 'gray'
        cmap = gray(256);
    case 'bone'
        cmap = bone(256);
    case 'copper'
        cmap = copper(256);
    case 'pink'
        cmap = pink(256);
    case 'lines'
        cmap = lines(256);
end
if isempty(cmap)
    cmap = parula(256);
end
% Number of levels: the user's colormap_steps setting, capped for speed.
if ~isfinite(nLevels) || nLevels < 2
    nLevels = 64;
end
nLevels = min(nLevels, maxLevels);
if nargin >= 4 && ~isempty(nVectors) && nVectors > 0
    nLevels = min(nLevels, max(16, round(nVectors/300)));
end
if size(cmap,1) ~= nLevels
    cmap = interp1(1:size(cmap,1), cmap, linspace(1, size(cmap,1), nLevels));
end
cmap = min(1, max(0, cmap));
end

function cmap = load_map(matfile, var)
cmap = [];
try
    s = load(matfile, var);
    cmap = s.(var);
catch
    disp([var '.mat not found in ' matfile])
end
end
