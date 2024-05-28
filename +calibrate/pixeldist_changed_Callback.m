function pixeldist_changed_Callback(src,~)
if exist('src','var')
	if strcmp(src.Tag,'pixeldist') % Reference distance has been edited in the edit field and not by clicking two points
		% simulate clicking a distance in a calibration image and draw a line
		delete(findobj('tag', 'caliline'))
		spacing_to_border=50;
		misc.misc_check_comma(src)
		xposition(1)=spacing_to_border;
		xposition(2)=spacing_to_border+str2double(src.String);

		yposition(1)=spacing_to_border;
		yposition(2)=spacing_to_border;


		gui.gui_put('pointscali',[xposition' yposition']);

		calibrate.calibrate_draw_line_Callback

	end
else
	handles=gui.gui_gethand;
	pointscali=gui.gui_retr('pointscali');
	if ~isempty(pointscali)
		xposition=pointscali(:,1);
		yposition=pointscali(:,2);
		if numel(pointscali)>0
			set(handles.pixeldist,'String',num2str(round((sqrt((xposition(1)-xposition(2))^2+(yposition(1)-yposition(2))^2))*100)/100))
		end
	else
		set(handles.pixeldist,'String','1');
	end
end

