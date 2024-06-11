function set_offset_Callback (~,~,~)
%calxy=retr('calxy');
filepath=gui.retr('filepath');
caliimg=gui.retr('caliimg');
if numel(caliimg)==0 && size(filepath,1) >1
	gui.sliderdisp(gui.retr('pivlab_axis'))
end
if size(filepath,1) >1 || numel(caliimg)>0 || gui.retr('video_selection_done') == 1
	handles=gui.gethand;
	delete(findobj('tag', 'offsetroi'))
	gui.toolsavailable(0)

	points_offsetx = gui.retr('points_offsetx');
	points_offsety = gui.retr('points_offsety');


	regionOfInterest = images.roi.Crosshair;
	%regionOfInterest.EdgeAlpha=0.75;
	regionOfInterest.LabelVisible = 'on';
	regionOfInterest.Tag = 'offsetroi';
	regionOfInterest.Color = 'y';
	regionOfInterest.LineWidth = 1;
	axes(gui.retr('pivlab_axis'))
	draw(regionOfInterest);

	addlistener(regionOfInterest,'MovingROI',@calibrate.Offsetselectionevents);
	addlistener(regionOfInterest,'DeletingROI',@calibrate.Offsetselectionevents);

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
		points_offsetx = [regionOfInterest.Position(1),regionOfInterest.Position(2),str2num(answer_x{1})];
		gui.put('points_offsetx',points_offsetx);
		points_offsety = [regionOfInterest.Position(1),regionOfInterest.Position(2),str2num(answer_y{1})];
		gui.put('points_offsety',points_offsety);
	end
	dummyevt.EventName = 'MovingROI';
	calibrate.Offsetselectionevents(regionOfInterest,dummyevt); %run the moving event once to update displayed length
	calibrate.calccali
	gui.toolsavailable(1)
end

