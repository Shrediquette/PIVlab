function [out, minscale, maxscale, region]=rescale_maps(in,isangle,imsize,grid,region)
%input has same dimensions as x,y,u,v,
%output has size of the piv image
%(interpolation shared with the command-line API: plot.rescale_map_core)
%imsize (optional): [height width] of the piv image, when the caller knows it (saves reading the
%image again)
%grid (optional): display grid of a large frame (plot.display_grid): out is the map at the display
%pixels only, minscale / maxscale the value range of the full resolution map (plot.rescale_map_display)
%region (optional, with grid): full resolution map of an earlier call, used again after zoom / pan
%when the map is the same (plot.rescale_map_display)
handles=gui.gethand;
currentframe=floor(get(handles.fileselector, 'value'));
if nargin < 3 || isempty(imsize)
	[currentimage,~]=import.get_img(2*currentframe-1);
	imsize = size(currentimage);
end
if nargin < 4
	grid = [];
end
if nargin < 5
	region = [];
end
resultslist=gui.retr('resultslist');
x=resultslist{1,currentframe};
y=resultslist{2,currentframe};
extrapolate_border=get(handles.extrapolate_border,'value');
displaywhat=gui.retr('displaywhat');
if displaywhat==12 || displaywhat==13  % correlation or uncertainty: discrete per-window values, nearest-neighbor only
	interp_method='nearest';
else
	colormap_interpolation_list=get(handles.colormap_interpolation,'String');
	colormap_interpolation_value = get(handles.colormap_interpolation,'Value');
	interp_method=colormap_interpolation_list{colormap_interpolation_value};
end
if isempty(grid)
	out = plot.rescale_map_core(in, x, y, imsize, isangle, interp_method, extrapolate_border, gui.retr('roirect'));
	minscale = [];
	maxscale = [];
else
	[out, minscale, maxscale, region] = plot.rescale_map_display(in, x, y, imsize, isangle, interp_method, extrapolate_border, gui.retr('roirect'), grid, region);
end
