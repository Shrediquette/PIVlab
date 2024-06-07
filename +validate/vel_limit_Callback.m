function vel_limit_Callback(~, ~, ~)
gui.toolsavailable(0)
%if analys existing
resultslist=gui.retr('resultslist');
handles=gui.gethand;
currentframe=2*floor(get(handles.fileselector, 'value'))-1;
if size(resultslist,2)>=(currentframe+1)/2 %data for current frame exists
	x=resultslist{1,(currentframe+1)/2};
	if size(x,1)>1
		if get(handles.meanofall,'value')==1 %calculating mean doesn't mae sense...
			index=1;
			foundfirst=0;
			for i = 1:size(resultslist,2)
				x=resultslist{1,i};
				if isempty(x)==0 && foundfirst==0
					firstsizex=size(x,1);
					secondsizex=size(x,2);
					foundfirst=1;
				end
				if size(x,1)>1 && size(x,1)==firstsizex && size(x,2) == secondsizex
					u(:,:,index)=resultslist{3,i}; %#ok<AGROW>
					v(:,:,index)=resultslist{4,i}; %#ok<AGROW>
					index=index+1;
				end
			end
		else
			y=resultslist{2,(currentframe+1)/2};
			u=resultslist{3,(currentframe+1)/2};
			v=resultslist{4,(currentframe+1)/2};
			typevector=resultslist{5,(currentframe+1)/2};
		end
		velrect=gui.retr('velrect');
		calu=gui.retr('calu');calv=gui.retr('calv');
		if numel(velrect)>0
			%user already selected window before...
			%"filter u+v" and display scatterplot
			%problem: if user selects limits and then wants to refine vel
			%limits, all data is filterd out...
			umin=velrect(1);
			umax=velrect(3)+umin;
			vmin=velrect(2);
			vmax=velrect(4)+vmin;
			%check if all results are nan...
			u_backup=u;
			v_backup=v;
			u(u*calu<umin)=NaN;
			u(u*calu>umax)=NaN;
			v(u*calu<umin)=NaN;
			v(u*calu>umax)=NaN;
			v(v*calv<vmin)=NaN;
			v(v*calv>vmax)=NaN;
			u(v*calv<vmin)=NaN;
			u(v*calv>vmax)=NaN;
			if mean(mean(mean((isnan(u)))))>0.9 || mean(mean(mean((isnan(v)))))>0.9
				disp('User calibrated after selecting velocity limits. Discarding limits.')
				u=u_backup;
				v=v_backup;
			end
		end

		%problem: wenn nur ein frame analysiert, dann gibts probleme wenn display all frames in scatterplot an.
		datau=reshape(u*calu,1,size(u,1)*size(u,2)*size(u,3));
		datav=reshape(v*calv,1,size(v,1)*size(v,2)*size(v,3));
		if size(datau,2)>1000000 %more than one million value pairs are too slow in scatterplot.
			pos=unique(ceil(rand(1000000,1)*(size(datau,2)-1))); %select random entries...
			scatter(gca,datau(pos),datav(pos), 0.25,'k.'); %.. and plot them
			set(gca,'Yaxislocation','right','layer','top');
		else
			scatter(gca,datau,datav, 0.25,'k.');
			set(gca,'Yaxislocation','right','layer','top');
		end
		drawnow;%needed from R2021b on... Why...?
		oldsize=get(gca,'outerposition');
		newsize=[oldsize(1)+10 0.15 oldsize(3)*0.87 oldsize(4)*0.87];
		set(gca,'outerposition', newsize)
		%%{
		if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
			xlabel(gca, 'u velocity [px/frame]', 'fontsize', 12)
			ylabel(gca, 'v velocity [px/frame]', 'fontsize', 12)
		else
			xlabel(gca, 'u velocity [m/s]', 'fontsize', 12)
			ylabel(gca, 'v velocity [m/s]', 'fontsize', 12)
		end

		grid on
		%axis equal;
		set (gca, 'tickdir', 'in');
		%rangeu=nanmax(nanmax(nanmax(u*calu)))-nanmin(nanmin(nanmin(u*calu)));
		%rangev=nanmax(nanmax(nanmax(v*calv)))-nanmin(nanmin(nanmin(v*calv)));

		%set(gca,'xlim',[nanmin(nanmin(nanmin(u*caluv)))-rangeu*0.15 nanmax(nanmax(nanmax(u*caluv)))+rangeu*0.15])
		%set(gca,'ylim',[nanmin(nanmin(nanmin(v*caluv)))-rangev*0.15 nanmax(nanmax(nanmax(v*caluv)))+rangev*0.15])
		%=range of data +- 15%
		%%}

		%{
		keyboard
		figure;
		datax=rand(1000000,1);
		datay=rand(1000000,1);
		plottl=scatter(datax,datay)
		roi = images.roi.Freehand;
		draw(roi)
		tf = inROI(roi,datax,datay);
		plottl.CData=double([1-tf tf*0 tf*0]); %makes markers outside red.
		%}
		velrect = getrect(gca);
		if velrect(1,3)~=0 && velrect(1,4)~=0
			gui.put('velrect', velrect);
			validate.update_velocity_limits_information
			gui.sliderdisp(gui.retr('pivlab_axis'))
			delete(findobj(gca,'Type','text','color','r'));
			text(50,50,'Result will be shown after applying vector validation','color','r','fontsize',10, 'fontweight','bold', 'BackgroundColor', 'k')
		else
			gui.sliderdisp(gui.retr('pivlab_axis'))
			text(50,50,'Invalid selection: Click and hold left mouse button to create a rectangle.','color','r','fontsize',8, 'BackgroundColor', 'k')
		end
	end
end
gui.toolsavailable(1)
gui.MainWindow_ResizeFcn(gcf)

