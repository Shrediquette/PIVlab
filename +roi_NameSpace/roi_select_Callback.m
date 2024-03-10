function roi_select_Callback(~, ~, ~)
filepath=gui_NameSpace.gui_retr('filepath');
handles=gui_NameSpace.gui_gethand;
if size(filepath,1) > 1 || gui_NameSpace.gui_retr('video_selection_done') == 1
	delete(findobj('tag','warning'));
	gui_NameSpace.gui_toolsavailable(0);
	toggler=gui_NameSpace.gui_retr('toggler');
	selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
	filepath=gui_NameSpace.gui_retr('filepath');
	delete(findobj('tag', 'RegionOfInterest'));
	roi = images.roi.Rectangle;
	%roi.EdgeAlpha=0.75;
	roi.FaceAlpha=0.05;
	roi.LabelVisible = 'on';
	roi.Tag = 'RegionOfInterest';
	roi.Color = 'g';
	roi.StripeColor = 'k';
	roirect = gui_NameSpace.gui_retr('roirect');
	delete(findobj('tag', 'roiplot'));
	if ~isempty(roirect)
		roi=drawrectangle(gui_NameSpace.gui_retr('pivlab_axis'),'Position',roirect);
		%roi.EdgeAlpha=0.75;
		roi.FaceAlpha=0.05;
		roi.LabelVisible = 'on';
		roi.Tag = 'RegionOfInterest';
		roi.Color = 'g';
		roi.StripeColor = 'k';
	else
		axes(gui_NameSpace.gui_retr('pivlab_axis'))
		draw(roi);
	end
	addlistener(roi,'MovingROI',@roi_NameSpace.roi_RegionOfInterestevents);
	addlistener(roi,'DeletingROI',@roi_NameSpace.roi_RegionOfInterestevents);
	dummyevt.EventName = 'MovingROI';
	roi_NameSpace.roi_RegionOfInterestevents(roi,dummyevt); %run the moving event once to update displayed length
	%put ('roirect',roi.Position);
	gui_NameSpace.gui_toolsavailable(1);
end
