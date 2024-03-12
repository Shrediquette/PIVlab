function plot_display_manual_markers(target_axis,handles)
%manualmarkers
if get(handles.displmarker,'value')==1
	manmarkersX=gui.gui_retr('manmarkersX');
	manmarkersY=gui.gui_retr('manmarkersY');
	delete(findobj('tag','manualmarker'));
	if numel(manmarkersX)>0
		hold on
		plot(manmarkersX,manmarkersY, 'o','MarkerEdgeColor','k','MarkerFaceColor',[.2 .2 1], 'MarkerSize',9, 'tag', 'manualmarker','parent',target_axis);
		plot(manmarkersX,manmarkersY, '*','MarkerEdgeColor','w', 'tag', 'manualmarker','parent',target_axis);
		hold off
	end
end

