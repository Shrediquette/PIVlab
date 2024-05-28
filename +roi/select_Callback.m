function select_Callback(~, ~, ~)
filepath=gui.retr('filepath');
handles=gui.gethand;
if size(filepath,1) > 1 || gui.retr('video_selection_done') == 1
	delete(findobj('tag','warning'));
	gui.toolsavailable(0);
	toggler=gui.retr('toggler');
	selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
	filepath=gui.retr('filepath');
	delete(findobj('tag', 'RegionOfInterest'));
	roi = images.roi.Rectangle;
	%roi.EdgeAlpha=0.75;
	roi.FaceAlpha=0.05;
	roi.LabelVisible = 'on';
	roi.Tag = 'RegionOfInterest';
	roi.Color = 'g';
	roi.StripeColor = 'k';
	roirect = gui.retr('roirect');
	delete(findobj('tag', 'roiplot'));
	if ~isempty(roirect)
		roi=drawrectangle(gui.retr('pivlab_axis'),'Position',roirect);
		%roi.EdgeAlpha=0.75;
		roi.FaceAlpha=0.05;
		roi.LabelVisible = 'on';
		roi.Tag = 'RegionOfInterest';
		roi.Color = 'g';
		roi.StripeColor = 'k';
	else
		axes(gui.retr('pivlab_axis'))
		draw(roi);
	end
	addlistener(roi,'MovingROI',@roi_1.roi_RegionOfInterestevents);
	addlistener(roi,'DeletingROI',@roi_1.roi_RegionOfInterestevents);
	dummyevt.EventName = 'MovingROI';
	roi_1.roi_RegionOfInterestevents(roi,dummyevt); %run the moving event once to update displayed length
	%put ('roirect',roi.Position);
	gui.toolsavailable(1);
end

