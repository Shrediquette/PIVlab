function appPosition = setAppSizefromMonitor()
% This function is for internal use only. It may change or be removed in
% a future release. 
% appPosition = wavelet.internal.setAppSizefromMonitor returns a structure
% array with the [X Y width height] settings for an app launched from
% MATLAB. setAppSizefromMonitor accounts for the possibility of dual
% monitors.

%   Copyright 2021 The MathWorks, Inc.

width = 1200;
height = 800;
appPosition = struct('X',0,'Y',0,'Width',0,'Height',0);
% Compensates for dual monitor
monitorPositions = get(0,'MonitorPositions');
% Are there dual monitors
isDualMonitor = size(monitorPositions,1) > 1;
 
if isDualMonitor
    origins = monitorPositions(:,1:2);
    % Identify the primary monitor
    primaryMonitorIndex = find(origins(:,1) == 1 & origins(:,2) == 1,1);
    
    if isempty(primaryMonitorIndex)
        % pick the first monitor if this does not work.
        primaryMonitorIndex = 1;
    else
        primaryMonitorIndex = max(primaryMonitorIndex,1);
    end
    
    screenSize = monitorPositions(primaryMonitorIndex, :);
else
    screenSize = get(0, 'ScreenSize');
end 

screenWidth = screenSize(3);
screenHeight = screenSize(4);
maxWidth = 0.8 * screenWidth;
maxHeight = 0.8 * screenHeight;
if width > maxWidth
    width = maxWidth;
end
if height > maxHeight
    height = maxHeight;
end
appPosition.X = (screenWidth - width) / 2;
appPosition.Y = (screenHeight - height) / 2;
appPosition.Width = width;
appPosition.Height = height;


end