function measureDistance_events(src,evt)
evname = evt.EventName;
handles=gui.gethand;
switch(evname)
	case{'MovingROI'}
		roirect = round(src.Position); %Position of the ROI, specified as a 2-by-2 numeric matrix of the form [x1 y1; x2 y2]. Each row specifies the respective end-point of the line segment.
		calxy=gui.retr('calxy');
		xposition=[roirect(1,1) roirect(2,1)];
		yposition=[roirect(1,2) roirect(2,2)];
		deltax=abs(xposition(1,1)-xposition(1,2));
		deltay=abs(yposition(1,1)-yposition(1,2));
		length=sqrt(deltax^2+deltay^2);
		alpha=(180/pi) *(acos(deltax/length));
		beta=(180/pi) *(asin(deltax/length));
		%src.Label = ['x: ' num2str(roirect(1)*calxy) '   y: ' num2str(roirect(2)*calxy) '   w: ' num2str(roirect(3)) '   h: ' num2str(roirect(4))];
		if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
			set (handles.deltax, 'String', [num2str(deltax*calxy) ' [px]']);
			set (handles.deltay, 'String', [num2str(deltay*calxy) ' [px]']);
			set (handles.length, 'String', [num2str(length*calxy) ' [px]']);
		else
			set (handles.deltax, 'String', [num2str(deltax*calxy) ' [m]']);
			set (handles.deltay, 'String', [num2str(deltay*calxy) ' [m]']);
			set (handles.length, 'String', [num2str(length*calxy) ' [m]']);
		end
		set (handles.alpha, 'String', num2str(round(alpha,1)));
		set (handles.beta, 'String', num2str(round(beta,1)));
end

