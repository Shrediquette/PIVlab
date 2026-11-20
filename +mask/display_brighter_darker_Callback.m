function display_brighter_darker_Callback (caller,~,~)
pivlab_axis=gui.retr('pivlab_axis');
axis_childs=pivlab_axis.Children;
if ~isa(axis_childs(end).CData,'double')
	axis_childs(end).CData = im2double(axis_childs(end).CData);
end
%the factor is kept with the image: a large frame drawn at screen resolution gets new CData after
%zoom / pan (plot.draw_background), which is made brighter / darker again with it
brightness_factor = 1;
if isappdata(axis_childs(end),'brightness_factor')
	brightness_factor = getappdata(axis_childs(end),'brightness_factor');
end
if strcmp(caller.Tag,'mask_display_brighter')
	axis_childs(end).CData = axis_childs(end).CData *1.33;
	brightness_factor = brightness_factor *1.33;
elseif strcmp(caller.Tag,'mask_display_darker')
	axis_childs(end).CData = axis_childs(end).CData /1.33;
	brightness_factor = brightness_factor /1.33;
end
setappdata(axis_childs(end),'brightness_factor',brightness_factor);
