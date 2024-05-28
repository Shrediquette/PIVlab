function pos = customWait(hROI)
% Listen for mouse clicks on the ROI
l = addlistener(hROI,'ROIClicked',@roi.ROIclickCallback);
% Block program execution
uiwait;
% Remove listener
delete(l);
% Return the current position
pos = hROI.Position;

