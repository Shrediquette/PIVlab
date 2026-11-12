function coloobj = scale_colorbar(target_axis, cmap, clims, label, position, colorbar_format, tag)
%SCALE_COLORBAR Colour bar of a colour scale that is drawn as truecolor (vector magnitude, stereo-PIV maps).
%   coloobj = plot.scale_colorbar(target_axis, cmap, clims, label, position, colorbar_format, tag)
%   cmap             colormap of the scale (n x 3)
%   clims            [min max] of the scale
%   label            label of the colour bar
%   position         'None' (no colour bar, coloobj = []), 'SouthOutside', 'NorthOutside', 'EastOutside',
%                    'WestOutside' or a location inside the axes ('East', 'West', ...)
%   colorbar_format  1 = %0.3g, 2 = %0.3e, 3 = %0.3f (as the colour bar of the derived parameters)
%   tag              Tag of the colour bar; an earlier colour bar with this tag is deleted first
% The axes colormap and CLim are set to cmap / clims so that a normal colour bar reads them. That is only
% safe when nothing else on the axes uses the colormap: the particle image and the mask are truecolor RGB
% and ignore it.
parentfig = ancestor(target_axis, 'figure');
delete(findobj(parentfig, 'Tag', tag));
coloobj = [];
if strcmpi(position, 'None')
    return
end

colormap(target_axis, cmap);
set(target_axis, 'CLim', clims); % property assignment, not clim(): works on old releases too

coloobj = colorbar(position, 'Fontsize', 12, 'HitTest', 'off', 'parent', parentfig, 'Tag', tag);
if any(strcmpi(position, {'EastOutside', 'WestOutside', 'East', 'West'}))
    ylabel(coloobj, label, 'fontsize', 12, 'fontweight', 'bold');
else
    xlabel(coloobj, label, 'fontsize', 12, 'fontweight', 'bold');
end

% Match the tick formatting of the scalar colorbar.
switch colorbar_format
    case 2
        fmt = '%0.3e';
    case 3
        fmt = '%0.3f';
    otherwise
        fmt = '%0.3g';
end
ticks = linspace(clims(1), clims(2), min(size(cmap, 1), 8) + 1);
coloobj.Ticks      = ticks;
coloobj.TickLabels = num2str(ticks(:), fmt);
end
