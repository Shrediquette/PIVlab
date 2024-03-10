function plot_putmarkers_Callback(~, ~, ~)
handles=gui_NameSpace.gui_gethand;
button=1;
manmarkersX=gui_NameSpace.gui_retr('manmarkersX');
manmarkersY=gui_NameSpace.gui_retr('manmarkersY');
if get(handles.holdmarkers,'value')==1

	if numel(manmarkersX)>0
		i=size(manmarkersX,2)+1;
		xposition=manmarkersX;
		yposition=manmarkersY;
	else
		i=1;
	end
else
	i=1;
	gui_NameSpace.gui_put('manmarkersX',[]);
	gui_NameSpace.gui_put('manmarkersY',[]);
	xposition=[];
	yposition=[];
	delete(findobj('tag','manualmarker'));
end
hold on;
gui_NameSpace.gui_toolsavailable(0)
while button == 1
	[rawx,rawy,button] = ginput(1);
	if button~=1
		break
	end
	xposition(i)=rawx;
	yposition(i)=rawy;
	plot(xposition(i),yposition(i), 'r*','Color', [0.55,0.75,0.9], 'tag', 'manualmarker');
	i=i+1;
end
gui_NameSpace.gui_toolsavailable(1)
delete(findobj('tag','manualmarker'));
plot(xposition,yposition, 'o','MarkerEdgeColor','k','MarkerFaceColor',[.2 .2 1], 'MarkerSize',9, 'tag', 'manualmarker');
plot(xposition,yposition, '*','MarkerEdgeColor','w', 'tag', 'manualmarker');
gui_NameSpace.gui_put('manmarkersX',xposition);
gui_NameSpace.gui_put('manmarkersY',yposition);
hold off
