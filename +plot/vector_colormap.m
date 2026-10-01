function cmap = vector_colormap(handles, maxLevels, nVectors)
%VECTOR_COLORMAP Colormap for magnitude-colored vectors, as N-by-3 RGB.
%
%   CMAP = PLOT.VECTOR_COLORMAP(HANDLES, MAXLEVELS) returns the colormap
%   currently selected in handles.colormap_choice, resampled to the number of
%   steps selected in handles.colormap_steps but capped at MAXLEVELS rows.
%
%   CMAP = PLOT.VECTOR_COLORMAP(HANDLES, MAXLEVELS, NVECTORS) additionally
%   scales the level count down for small fields.
%
%   The cap matters for speed: plot.quiverc draws one line object per color
%   level and each level costs a roughly fixed amount of time, so the 256-step
%   setting would add about a quarter of a second per redraw. 64 levels is
%   visually indistinguishable from a continuous ramp and keeps the draw time
%   at parity with a plain QUIVER.
%
%   The NVECTORS taper exists because that per-level cost is fixed while the
%   render cost scales with the vector count: on a large field the levels
%   disappear into the render, but on a small one 64 line objects are pure
%   overhead. A field of a few thousand vectors cannot resolve 64 distinct
%   magnitude bands anyway, so fewer levels costs nothing visually.
%
%   The calculation (plot.vector_colormap_core) is shared with the
%   command-line API.
%
%   See also PLOT.QUIVERC, PLOT.VECTORS, PLOT.VECTOR_COLORMAP_CORE.

if nargin < 2 || isempty(maxLevels)
	maxLevels = 64;
end
if nargin < 3
	nVectors = [];
end
avail_maps     = get(handles.colormap_choice,'string');
selected_index = get(handles.colormap_choice,'value');
if selected_index < 1 || selected_index > numel(avail_maps)
	selected_index = 1;
end
steps_list  = get(handles.colormap_steps,'String');
steps_value = get(handles.colormap_steps,'Value');
nLevels     = str2double(steps_list{steps_value});
cmap = plot.vector_colormap_core(avail_maps{selected_index}, nLevels, maxLevels, nVectors);
end
