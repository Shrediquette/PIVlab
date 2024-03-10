function calibrate_set_offset_Callback (~,~,~)
%calxy=retr('calxy');
filepath=gui_NameSpace.gui_retr('filepath');
caliimg=gui_NameSpace.gui_retr('caliimg');
if numel(caliimg)==0 && size(filepath,1) >1
	gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
end
if size(filepath,1) >1 || numel(caliimg)>0 || gui_NameSpace.gui_retr('video_selection_done') == 1
	handles=gui_NameSpace.gui_gethand;
	delete(findobj('tag', 'offsetroi'))
	gui_NameSpace.gui_toolsavailable(0)

	points_offsetx = gui_NameSpace.gui_retr('points_offsetx');
	points_offsety = gui_NameSpace.gui_retr('points_offsety');


	roi = images.roi.Crosshair;
	%roi.EdgeAlpha=0.75;
	roi.LabelVisible = 'on';
	roi.Tag = 'offsetroi';
	roi.Color = 'y';
	roi.LineWidth = 1;
	axes(gui_NameSpace.gui_retr('pivlab_axis'))
	draw(roi);

	addlistener(roi,'MovingROI',@calibrate_NameSpace.calibrate_Offsetselectionevents);
	addlistener(roi,'DeletingROI',@calibrate_NameSpace.calibrate_Offsetselectionevents);

	prompt =['Enter true X coordinate in mm:'];
	dlgtitle = ['Set X offset'];
	if isempty (points_offsetx)
		definput = {'0'};
	else
		definput = {num2str(points_offsetx(3))};
	end
	answer_x = inputdlg(prompt,dlgtitle,[1 40],definput);
	prompt =['Enter true Y coordinate in mm:'];
	dlgtitle = ['Set Y offset'];
	if isempty (points_offsety)
		definput = {'0'};
	else
		definput = {num2str(points_offsety(3))};
	end
	answer_y = inputdlg(prompt,dlgtitle,[1 40],definput);
	if ~isempty(answer_x) && ~isempty(answer_y)
		answer_x{1} = regexprep(answer_x{1}, ',', '.');
		answer_y{1} = regexprep(answer_y{1}, ',', '.');
		points_offsetx = [roi.Position(1),roi.Position(2),str2num(answer_x{1})];
		gui_NameSpace.gui_put('points_offsetx',points_offsetx);
		points_offsety = [roi.Position(1),roi.Position(2),str2num(answer_y{1})];
		gui_NameSpace.gui_put('points_offsety',points_offsety);
	end
	dummyevt.EventName = 'MovingROI';
	calibrate_NameSpace.calibrate_Offsetselectionevents(roi,dummyevt); %run the moving event once to update displayed length
	calibrate_NameSpace.calibrate_calccali
	gui_NameSpace.gui_toolsavailable(1)
end
