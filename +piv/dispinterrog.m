function dispinterrog
handles=gui.gui_gethand;
selected=2*floor(get(handles.fileselector, 'value'))-1;
filepath=gui.gui_retr('filepath');
if numel(filepath)>1
	[image_dummy,~]=import.import_get_img(selected);
	size_img(1)=size(image_dummy,2)/2;
	size_img(2)=size(image_dummy,1)/2;
	step=str2double(get(handles.step,'string'));
	delete(findobj(gca,'Type','hggroup')); %=vectors and scatter markers
	delete(findobj(gca,'tag','intareadispl'));
	centre(1)= size_img(2); %y
	centre(2)= size_img(1); %x

	intarea1=str2double(get(handles.intarea,'string'))/2;
	x1=[centre(2)-intarea1 centre(2)+intarea1 centre(2)+intarea1 centre(2)-intarea1 centre(2)-intarea1];
	y1=[centre(1)-intarea1 centre(1)-intarea1 centre(1)+intarea1 centre(1)+intarea1 centre(1)-intarea1];
	hold on;
	plot(x1,y1,'c-', 'linewidth', 1, 'linestyle', ':','tag','intareadispl');
	if get(handles.fftmulti,'value')==1 || get(handles.ensemble,'value')==1
		text(x1(1),y1(1), ['pass 1'],'color','c','fontsize',8,'tag','intareadispl','HorizontalAlignment','right','verticalalignment','bottom')
		if get(handles.checkbox26,'value')==1
			intarea2=str2double(get(handles.edit50,'string'))/2;
			x2=[centre(2)-intarea2 centre(2)+intarea2 centre(2)+intarea2 centre(2)-intarea2 centre(2)-intarea2];
			y2=[centre(1)-intarea2 centre(1)-intarea2 centre(1)+intarea2 centre(1)+intarea2 centre(1)-intarea2];
			plot(x2,y2,'y-', 'linewidth', 1, 'linestyle', ':','tag','intareadispl');
			text(x2(2),y2(1), ['pass 2'],'color','y','fontsize',8,'tag','intareadispl','HorizontalAlignment','left','verticalalignment','bottom')
		end
		if get(handles.checkbox27,'value')==1
			intarea3=str2double(get(handles.edit51,'string'))/2;
			x3=[centre(2)-intarea3 centre(2)+intarea3 centre(2)+intarea3 centre(2)-intarea3 centre(2)-intarea3];
			y3=[centre(1)-intarea3 centre(1)-intarea3 centre(1)+intarea3 centre(1)+intarea3 centre(1)-intarea3];
			plot(x3,y3,'g-', 'linewidth', 1, 'linestyle', ':','tag','intareadispl');
			text(x3(2),y3(3), ['pass 3'],'color','g','fontsize',8,'tag','intareadispl','HorizontalAlignment','left','verticalalignment','top')
		end
		if get(handles.checkbox28,'value')==1
			intarea4=str2double(get(handles.edit52,'string'))/2;
			x4=[centre(2)-intarea4 centre(2)+intarea4 centre(2)+intarea4 centre(2)-intarea4 centre(2)-intarea4];
			y4=[centre(1)-intarea4 centre(1)-intarea4 centre(1)+intarea4 centre(1)+intarea4 centre(1)-intarea4];
			plot(x4,y4,'r-', 'linewidth', 1, 'linestyle', ':','tag','intareadispl');
			text(x4(1),y4(3), ['pass 4'],'color','r','fontsize',8,'tag','intareadispl','HorizontalAlignment','right','verticalalignment','top')
		end
	end
	hold off;
	%check if step is ok
	if step/(intarea1*2) < 0.25
		text (centre(2),centre(1)/2,'Warning: Step of pass 1 is very small.','color','r','tag','intareadispl','HorizontalAlignment','center','verticalalignment','top','Fontsize',10,'Backgroundcolor','k')
	end
	%check if int area sizes are decreasing
	sizeerror=0;
	try
		if intarea4 > intarea3 || intarea4 > intarea2 || intarea4 > intarea1
			sizeerror=1;
		end
	catch
	end
	try
		if intarea3 > intarea2 || intarea3 > intarea1
			sizeerror=1;
		end
	catch
	end
	try
		if intarea2 > intarea1
			sizeerror=1;
		end
	catch
	end
	if sizeerror == 1
		text (centre(2),centre(1)*4/3,['Warning: Interrogation area sizes should be' sprintf('\n') 'gradually decreasing from pass 1 to pass 4.'],'color','r','tag','intareadispl','HorizontalAlignment','center','verticalalignment','top','Fontsize',10,'Backgroundcolor','k') %#ok<*SPRINTFN>
		sizeerror=0;
	end

	roirect=gui.gui_retr('roirect');

	if isempty(roirect) == 0 %roi eingeschaltet
		roirect=gui.gui_retr('roirect');
		minisize=min([roirect(3) roirect(4)]);
	else
		minisize=min([size_img(1) size_img(2)]);
	end

	if intarea1*2 *2 > minisize
		text (centre(2),centre(1)*5/3,['Warning: Interrogation area of pass 1 is most likely too big.'],'color','r','tag','intareadispl','HorizontalAlignment','center','verticalalignment','top','Fontsize',10,'Backgroundcolor','k')
	end

end

