function plot_streamrake_Callback(~, ~, ~)
handles=gui.gui_gethand;
toggler=gui.gui_retr('toggler');
selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
resultslist=gui.gui_retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	gui.gui_toolsavailable(0);
	x=resultslist{1,currentframe};
	y=resultslist{2,currentframe};
	typevector=resultslist{5,currentframe};
	if size(resultslist,1)>6 %filtered exists
		if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
			u=resultslist{10,currentframe};
			v=resultslist{11,currentframe};
			typevector=resultslist{9,currentframe}; %von smoothed
		else
			u=resultslist{7,currentframe};
			if size(u,1)>1
				v=resultslist{8,currentframe};
				typevector=resultslist{9,currentframe}; %von smoothed
			else
				u=resultslist{3,currentframe};
				v=resultslist{4,currentframe};
				typevector=resultslist{5,currentframe};
			end
		end
	else
		u=resultslist{3,currentframe};
		v=resultslist{4,currentframe};
	end
	ismean=gui.gui_retr('ismean');
	if    numel(ismean)>0
		if ismean(currentframe)==1 %if current frame is a mean frame, typevector is stored at pos 5
			typevector=resultslist{5,currentframe};
		end
	end
	calu=gui.gui_retr('calu');calv=gui.gui_retr('calv');
	ustream=u-(gui.gui_retr('subtr_u')/gui.gui_retr('calu'));
	vstream=v-(gui.gui_retr('subtr_v')/gui.gui_retr('calv'));
	ustream(typevector==0)=nan;
	vstream(typevector==0)=nan;
	calxy=gui.gui_retr('calxy');
	button=1;
	streamlinesX=gui.gui_retr('streamlinesX');
	streamlinesY=  gui.gui_retr('streamlinesY');
	if get(handles.holdstream,'value')==1
		if numel(streamlinesX)>0
			i=size(streamlinesX,2)+1;
			xposition=streamlinesX;
			yposition=streamlinesY;
		else
			i=1;
		end
	else
		i=1;
		gui.gui_put('streamlinesX',[]);
		gui.gui_put('streamlinesY',[]);
		xposition=[];
		yposition=[];
		delete(findobj('tag','streamline'));
	end
	[rawx,rawy,~] = ginput(1);
	hold on; scatter(rawx,rawy,'y*','tag','streammarker');hold off;
	[rawx(2),rawy(2),~] = ginput(1);
	delete(findobj('tag','streammarker'))
	rawx=linspace(rawx(1),rawx(2),str2num(get(handles.streamlamount,'string')));
	rawy=linspace(rawy(1),rawy(2),str2num(get(handles.streamlamount,'string')));

	xposition(i:i+str2num(get(handles.streamlamount,'string'))-1)=rawx;
	yposition(i:i+str2num(get(handles.streamlamount,'string'))-1)=rawy;
	h=streamline(mmstream2(x,y,ustream,vstream,xposition(i),yposition(i),'on'));
	set (h,'tag','streamline');
	i=i+1;
end
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	delete(findobj('tag','streamline'));
	h=streamline(mmstream2(x,y,ustream,vstream,xposition,yposition,'on'));
	contents = get(handles.streamlcolor,'String');
	set(h,'LineWidth',get(handles.streamlwidth,'value'),'Color', contents{get(handles.streamlcolor,'Value')});
	set (h,'tag','streamline');
	gui.gui_put('streamlinesX',xposition);
	gui.gui_put('streamlinesY',yposition);
end
gui.gui_toolsavailable(1);

