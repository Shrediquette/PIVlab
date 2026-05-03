function putmarkers_Callback(~, ~, ~)
handles=gui.gethand;
target_axis = gui.retr('pivlab_axis');
button=1;
manmarkersX=gui.retr('manmarkersX');
manmarkersY=gui.retr('manmarkersY');
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
	gui.put('manmarkersX',[]);
	gui.put('manmarkersY',[]);
	xposition=[];
	yposition=[];
	delete(findobj(target_axis,'tag','manualmarker'));
end
hold(target_axis,'on');
gui.toolsavailable(0)
figure(ancestor(target_axis,'figure')); % ensure ginput captures from the correct window
while button == 1
	[rawx,rawy,button] = ginput(1);
	if button~=1
		break
	end
	xposition(i)=rawx;
	yposition(i)=rawy;
	plot(target_axis,xposition(i),yposition(i), 'r*','Color', [0.55,0.75,0.9], 'tag', 'manualmarker');
	i=i+1;
end
gui.toolsavailable(1)
delete(findobj(target_axis,'tag','manualmarker'));
plot(target_axis,xposition,yposition, 'o','MarkerEdgeColor','k','MarkerFaceColor',[.2 .2 1], 'MarkerSize',9, 'tag', 'manualmarker');
plot(target_axis,xposition,yposition, '*','MarkerEdgeColor','w', 'tag', 'manualmarker');
gui.put('manmarkersX',xposition);
gui.put('manmarkersY',yposition);
hold(target_axis,'off');

