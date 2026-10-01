function out=rescale_maps(in,isangle)
%input has same dimensions as x,y,u,v,
%output has size of the piv image
%(interpolation shared with the command-line API: plot.rescale_map_core)
handles=gui.gethand;
currentframe=floor(get(handles.fileselector, 'value'));
[currentimage,~]=import.get_img(2*currentframe-1);
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
out = plot.rescale_map_core(in, x, y, size(currentimage), isangle, interp_method, extrapolate_border, gui.retr('roirect'));
