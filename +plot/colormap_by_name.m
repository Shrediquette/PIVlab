function cmap = colormap_by_name(name)
%COLORMAP_BY_NAME Colormap of the PIVlab display by name.
%   cmap = plot.colormap_by_name(name)
%   name: 'Parula', 'HSV', 'Jet', 'HSB', 'Hot', 'Cool', 'Spring', 'Summer', 'Autumn', 'Winter',
%   'Gray', 'Bone', 'Copper', 'Pink', 'Lines' or 'Plasma' (not case sensitive).
%   Returns an RGB matrix for the maps that ship with PIVlab (Parula, HSB, Plasma), otherwise the
%   name of the MATLAB colormap (as accepted by COLORMAP).
here = fileparts(mfilename('fullpath'));
switch lower(char(name))
    case 'parula'
        cmap = load_map(fullfile(here,'parula.mat'),'parula');
    case 'hsb'
        cmap = load_map(fullfile(here,'hsbmap.mat'),'hsb');
    case 'plasma'
        cmap = load_map(fullfile(here,'plasma.mat'),'plasma');
    otherwise
        cmap = char(name);
end
end

function cmap = load_map(file, var)
try
    s = load(file, var);
    cmap = s.(var);
catch
    disp([var ' colormap not found in ' file])
    cmap = 'parula';
end
end
