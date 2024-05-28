function display_brighter_darker_Callback (caller,~,~)
pivlab_axis=gui.gui_retr('pivlab_axis');
axis_childs=pivlab_axis.Children;
if ~isa(axis_childs(end).CData,'double')
	axis_childs(end).CData = im2double(axis_childs(end).CData);
end
if strcmp(caller.Tag,'mask_display_brighter')
	axis_childs(end).CData = axis_childs(end).CData *1.33;
elseif strcmp(caller.Tag,'mask_display_darker')
	axis_childs(end).CData = axis_childs(end).CData /1.33;
end