function set_points_Callback(~, ~, ~)
delete(findobj('tag', 'RegionOfInterest'));
regionOfInterest = images.roi.Line;
regionOfInterest.LabelVisible = 'off';
regionOfInterest.Tag = 'RegionOfInterest';
regionOfInterest.Color = 'g';
regionOfInterest.StripeColor = 'y';

axes(gui.retr('pivlab_axis'))
draw(regionOfInterest);

addlistener(regionOfInterest,'MovingROI',@plot.measureDistance_events);
dummyevt.EventName = 'MovingROI';
plot.measureDistance_events(regionOfInterest,dummyevt); %run the moving event once to update displayed length