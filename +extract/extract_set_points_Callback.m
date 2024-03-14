function extract_set_points_Callback(~, ~, ~)
gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))
hold on;
gui.gui_toolsavailable(0)
delete(findobj('tag', 'measure'));
n=0;
for i=1:2
	[xi,yi,but] = ginput(1);
	n=n+1;
	xposition(n)=xi; %#ok<AGROW>
	yposition(n)=yi; %#ok<AGROW>
	plot(xposition(n),yposition(n), 'r*','Color', [0.55,0.75,0.9], 'tag', 'measure');
	line(xposition,yposition,'LineWidth',3, 'Color', [0.05,0,0], 'tag', 'measure');
	line(xposition,yposition,'LineWidth',1, 'Color', [0.05,0.75,0.05], 'tag', 'measure');
end
line([xposition(1,1) xposition(1,2)],[yposition(1,1) yposition(1,1)], 'LineWidth',3, 'Color', [0.05,0.0,0.0], 'tag', 'measure');
line([xposition(1,1) xposition(1,2)],[yposition(1,1) yposition(1,1)], 'LineWidth',1, 'Color', [0.95,0.05,0.01], 'tag', 'measure');
line([xposition(1,2) xposition(1,2)], yposition,'LineWidth',3, 'Color',[0.05,0.0,0], 'tag', 'measure');
line([xposition(1,2) xposition(1,2)], yposition,'LineWidth',1, 'Color',[0.35,0.35,1], 'tag', 'measure');
hold off;
gui.gui_toolsavailable(1)
deltax=abs(xposition(1,1)-xposition(1,2));
deltay=abs(yposition(1,1)-yposition(1,2));
length=sqrt(deltax^2+deltay^2);
alpha=(180/pi) *(acos(deltax/length));
beta=(180/pi) *(asin(deltax/length));
handles=gui.gui_gethand;
calxy=gui.gui_retr('calxy');
if (gui.gui_retr('calu')==1 || gui.gui_retr('calu')==-1) && gui.gui_retr('calxy')==1
	set (handles.deltax, 'String', [num2str(deltax*calxy) ' [px]']);
	set (handles.deltay, 'String', [num2str(deltay*calxy) ' [px]']);
	set (handles.length, 'String', [num2str(length*calxy) ' [px]']);

else
	set (handles.deltax, 'String', [num2str(deltax*calxy) ' [m]']);
	set (handles.deltay, 'String', [num2str(deltay*calxy) ' [m]']);
	set (handles.length, 'String', [num2str(length*calxy) ' [m]']);
end
set (handles.alpha, 'String', num2str(alpha));
set (handles.beta, 'String', num2str(beta));

