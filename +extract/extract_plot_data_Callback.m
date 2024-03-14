function extract_plot_data_Callback(A, ~, ~)
handles=gui.gui_gethand;

if strcmp (A.Tag,'plot_data') %function called from button press
	currentframe=floor(get(handles.fileselector, 'value'));
else %function called from other skript
	currentframe=A.Tag;
end
resultslist=gui.gui_retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	x=resultslist{1,currentframe};
	y=resultslist{2,currentframe};
	xposition=gui.gui_retr('xposition');
	yposition=gui.gui_retr('yposition');
	extract_type=gui.gui_retr('extract_type');
	if get(handles.draw_what,'value')==3 %circle series
		set(handles.extraction_choice,'Value',11); %set to tangent
	end
	extractwhat=get(handles.extraction_choice,'Value');
	if ~isempty(xposition)
		if strcmp(extract_type,'extract_poly')
			for i=1:size(xposition,1)-1
				%length of one segment:
				laenge(i)=sqrt((xposition(i+1,1)-xposition(i,1))^2+(yposition(i+1,1)-yposition(i,1))^2); %#ok<AGROW>
			end
			length=sum(laenge);
			extraction_coordinates_x = xposition; %coordinates in rows
			extraction_coordinates_y = yposition;
		elseif strcmp(extract_type,'extract_circle')
			length = 2*yposition*pi;
			%cenvert circular roi object to series of coordinates
			valtable=linspace(0,2*pi,361)';
			extraction_coordinates_x=zeros(size(valtable));
			extraction_coordinates_y=zeros(size(valtable));
			for i=1:size(valtable,1)
				extraction_coordinates_x (i,1)=sin(valtable(i,1))*yposition+xposition(1);
				extraction_coordinates_y (i,1)=cos(valtable(i,1))*yposition+xposition(2);
			end
		elseif strcmp(extract_type,'extract_circle_series')
			length = 2*yposition*pi;
		end
		%percentagex=xposition/max(max(x));
		%xaufderivative=percentagex*size(x,2);
		%percentagey=yposition/max(max(y));
		%yaufderivative=percentagey*size(y,1);

		stepsize=ceil((x(1,2)-x(1,1))/1);
		nrpoints = double(round(length/stepsize*3));

		switch extractwhat
			case {1,2,3,4,5,6,7,8}
				plot.plot_derivative_calc(currentframe,extractwhat+1,0);
				derived=gui.gui_retr('derived');
				maptoget=derived{extractwhat,currentframe};
				maptoget=plot.plot_rescale_maps_nan(maptoget,0,currentframe);
				[cx, cy, c] = improfile(maptoget,extraction_coordinates_x,extraction_coordinates_y,round(nrpoints),'bicubic');
				distance=linspace(0,length,size(c,1))';
			case {9,10}
				% auf stelle 9 steht vector angle. Bei derivatives ist der aber auf platz 11. daher zwei dazu
				%auf stelle 10 steht correlation coeff, bei derivatives auf
				%12, daher zwei dazu
				plot.plot_derivative_calc(currentframe,extractwhat+2,0);
				derived=gui.gui_retr('derived');
				maptoget=derived{extractwhat+1,currentframe};
				maptoget=plot.plot_rescale_maps_nan(maptoget,0,currentframe);
				[cx, cy, c] = improfile(maptoget,extraction_coordinates_x,extraction_coordinates_y,round(nrpoints),'bicubic');
				distance=linspace(0,length,size(c,1))';
			case 11 %tangent
				if ~strcmp(extract_type,'extract_circle_series')
					if size(resultslist,1)>6 %filtered exists
						if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
							u=resultslist{10,currentframe};
							v=resultslist{11,currentframe};
							typevector=resultslist{9,currentframe};
							if numel(typevector)==0%happens if user smoothes sth without NaN and without validation
								typevector=resultslist{5,currentframe};
							end
						else
							u=resultslist{7,currentframe};
							if size(u,1)>1
								v=resultslist{8,currentframe};
								typevector=resultslist{9,currentframe};
							else
								u=resultslist{3,currentframe};
								v=resultslist{4,currentframe};
								typevector=resultslist{5,currentframe};
							end
						end
					else
						u=resultslist{3,currentframe};
						v=resultslist{4,currentframe};
						typevector=resultslist{5,currentframe};
					end
					calu=gui.gui_retr('calu');calv=gui.gui_retr('calv');
					u=u*calu-gui.gui_retr('subtr_u');
					v=v*calv-gui.gui_retr('subtr_v');

					u=plot.plot_rescale_maps_nan(u,0,currentframe);
					v=plot.plot_rescale_maps_nan(v,0,currentframe);

					[cx, cy, cu] = improfile(u,extraction_coordinates_x,extraction_coordinates_y,round(nrpoints),'bicubic');
					cv = improfile(v,extraction_coordinates_x,extraction_coordinates_y,round(nrpoints),'bicubic');
					cx=cx';
					cy=cy';
					deltax=zeros(1,size(cx,2)-1);
					deltay=zeros(1,size(cx,2)-1);
					laenge=zeros(1,size(cx,2)-1);
					alpha=zeros(1,size(cx,2)-1);
					sinalpha=zeros(1,size(cx,2)-1);
					cosalpha=zeros(1,size(cx,2)-1);
					for i=2:size(cx,2)
						deltax(1,i)=cx(1,i)-cx(1,i-1);
						deltay(1,i)=cy(1,i)-cy(1,i-1);
						laenge(1,i)=sqrt(deltax(1,i)*deltax(1,i)+deltay(1,i)*deltay(1,i));
						alpha(1,i)=(acos(deltax(1,i)/laenge(1,i)));
						if deltay(1,i) < 0
							sinalpha(1,i)=sin(alpha(1,i));
						else
							sinalpha(1,i)=sin(alpha(1,i))*-1;
						end
						cosalpha(1,i)=cos(alpha(1,i));
					end
					sinalpha(1,1)=sinalpha(1,2);
					cosalpha(1,1)=cosalpha(1,2);
					cu=cu.*cosalpha';
					cv=cv.*sinalpha';
					c=cu-cv;
					cx=cx';
					cy=cy';
					distance=linspace(0,length,size(cu,1))';
				end
				%% circle series --> can only be tangent velocity
				if strcmp(extract_type,'extract_circle_series') %user chose circle series

					%draw circles as displayed

					x=resultslist{1,currentframe};
					stepsize=ceil((x(1,2)-x(1,1))/1);
					radii=[linspace(stepsize,yposition-stepsize,round(((yposition-stepsize)/stepsize))) yposition];
					length = 2*radii*pi; %column vector with the lengths of the circle series
					%convert circular roi object to series of coordinates
					valtable=linspace(0,2*pi,361)';
					extraction_coordinates_x=zeros(size(valtable,1),numel(length)); %rows=coordinates of one circle, cols = the different circles of the series
					extraction_coordinates_y=zeros(size(valtable,1),numel(length));
					for i=1:size(valtable,1)
						for j=1:numel(length)
							extraction_coordinates_x (i,j)=sin(valtable(i,1))*radii(j)+xposition(1);
							extraction_coordinates_y (i,j)=cos(valtable(i,1))*radii(j)+xposition(2);
						end
					end

					if size(resultslist,1)>6 %filtered exists
						if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
							u=resultslist{10,currentframe};
							v=resultslist{11,currentframe};
							typevector=resultslist{9,currentframe};
							if numel(typevector)==0%happens if user smoothes sth without NaN and without validation
								typevector=resultslist{5,currentframe};
							end
						else
							u=resultslist{7,currentframe};
							if size(u,1)>1
								v=resultslist{8,currentframe};
								typevector=resultslist{9,currentframe};
							else
								u=resultslist{3,currentframe};
								v=resultslist{4,currentframe};
								typevector=resultslist{5,currentframe};
							end
						end
					else
						u=resultslist{3,currentframe};
						v=resultslist{4,currentframe};
						typevector=resultslist{5,currentframe};
					end
					calu=gui.gui_retr('calu');calv=gui.gui_retr('calv');
					u=u*calu-gui.gui_retr('subtr_u');
					v=v*calv-gui.gui_retr('subtr_v');
					u=plot.plot_rescale_maps_nan(u,0,currentframe);
					v=plot.plot_rescale_maps_nan(v,0,currentframe);

					min_y=floor(min(extraction_coordinates_y(:)))-1;
					max_y=ceil(max(extraction_coordinates_y(:)))+1;
					min_x=floor(min(extraction_coordinates_x(:)))-1;
					max_x=ceil(max(extraction_coordinates_x(:)))+1;
					if min_y<1
						min_y=1;
					end
					if max_y>size(u,1)
						max_y=size(u,1);
					end
					if min_x<1
						min_x=1;
					end
					if max_x>size(u,2)
						max_x=size(u,2);
					end

					uc=u(min_y:max_y,min_x:max_x);
					vc=v(min_y:max_y,min_x:max_x);

					for m=1:numel(length)
						[cx(m,:),cy(m,:),cu(m,:)] = improfile(uc,extraction_coordinates_x(:,m)-min_x,extraction_coordinates_y(:,m)-min_y,100,'nearest');
						cv(m,:) =improfile(vc,extraction_coordinates_x(:,m)-min_x,extraction_coordinates_y(:,m)-min_y,100,'nearest');
					end
					deltax=zeros(1,size(cx,2)-1);
					deltay=zeros(1,size(cx,2)-1);
					laenge=zeros(1,size(cx,2)-1);
					alpha=zeros(1,size(cx,2)-1);
					sinalpha=zeros(1,size(cx,2)-1);
					cosalpha=zeros(1,size(cx,2)-1);
					for m=1:numel(length)
						for i=2:size(cx,2)
							deltax(m,i)=cx(m,i)-cx(m,i-1);
							deltay(m,i)=cy(m,i)-cy(m,i-1);
							laenge(m,i)=sqrt(deltax(m,i)*deltax(m,i)+deltay(m,i)*deltay(m,i));
							alpha(m,i)=(acos(deltax(m,i)/laenge(m,i)));
							if deltay(m,i) < 0
								sinalpha(m,i)=sin(alpha(m,i));
							else
								sinalpha(m,i)=sin(alpha(m,i))*-1;
							end
							cosalpha(m,i)=cos(alpha(m,i));
						end
						sinalpha(m,1)=sinalpha(m,2); %ersten winkel fÃ¼llen
						cosalpha(m,1)=cosalpha(m,2);
					end
					cu=cu.*cosalpha;
					cv=cv.*sinalpha;
					c=cu-cv;
					for m=1:numel(length)
						distance(m,:)=linspace(0,length(m),size(cu,2))'; % %in pixeln...
					end
				end
		end
		%% Plotting
		if ~strcmp(extract_type,'extract_circle_series') %user did not choose circle series
			calxy=gui.gui_retr('calxy');
			%get units
			if (gui.gui_retr('calu')==1 || gui.gui_retr('calu')==-1) && gui.gui_retr('calxy')==1
				distunit='px^2';
			else
				distunit='m^2';
			end
			if (gui.gui_retr('calu')==1 || gui.gui_retr('calu')==-1) && gui.gui_retr('calxy')==1
				distunit_2=' px';
			else
				distunit_2=' m';
			end

			current=get(handles.extraction_choice,'string');
			current=current{extractwhat};
			%removing nans for integral!
			distance2=distance(~isnan(c));
			c2=c(~isnan(c));
			integral=trapz(distance2*calxy,c2);
			currentstripped=current(1:strfind(current,'[')-1);

			unitpar=get(handles.extraction_choice,'string');
			unitpar=unitpar{get(handles.extraction_choice,'value')};
			unitpar=unitpar(strfind(unitpar,'[')+1:end-1);
			%plot only when called from button...
			if strcmp (A.Tag,'plot_data') %function called from button press
				h=figure;
				screensize=get( 0, 'ScreenSize' );
				rect = [screensize(3)/4-300, screensize(4)/2-250, 600, 500];
				set(h,'position', rect);
				set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',[current ', frame ' num2str(currentframe)],'tag', 'derivplotwindow');
				h2=plot(distance*calxy,c);
				set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
				h_extractionplot=gui.gui_retr('h_extractionplot');
				h_extractionplot(size(h_extractionplot,1)+1,1)=h;
				gui.gui_put ('h_extractionplot', h_extractionplot);
				xlabel(['Distance on line' distunit_2 sprintf('\n') 'Integral of ' currentstripped ' = ' num2str(integral) ' [' unitpar '*' distunit_2 ']']);
				ylabel(current);
			end
			%modified units...
			gui.gui_put('distance',distance*calxy);
			gui.gui_put('c',c);
			[cx_cal,cy_cal] = calibrate.calibrate_xy(cx,cy);
			gui.gui_put('cx',cx_cal);
			gui.gui_put('cy',cy_cal);
		end
		if strcmp(extract_type,'extract_circle_series') %user chose circle series
			calxy=gui.gui_retr('calxy');

			%interpolate circles that contain less than 50% missing data
			amount_of_nans_in_circle=zeros(numel(length),1);
			for ind=1:numel(length)
				amount_of_nans_in_circle(ind)=numel(find(isnan(c(ind,:))));
			end
			amount_of_nans_in_circle = amount_of_nans_in_circle / size(c,2);
			c_interpolated=inpaint_nans(c); %interpolate all nans
			c_interpolated(amount_of_nans_in_circle>0.5,:)=nan; %set rows with more than 50% nan back to nan
			for m=1:numel(length)
				integral(m)=trapz(distance(m,:)*calxy,c_interpolated(m,:));
			end

			%highlight circle with highest circ
			delete(findobj('tag', 'extractline'))
			[r,col]=find(max(abs(integral))==abs(integral)); %find absolute max of integral
			if ~isempty(radii(col))
				extract_poly_maximum_circ=drawcircle(gui.gui_retr('pivlab_axis'),'Center',xposition,'Radius',radii(col),'Tag',[extract_type '_max_circulation'],'Deletable',0,'FaceAlpha',0,'FaceSelectable',0,'InteractionsAllowed','none','Color','r','StripeColor','y');
				current=get(handles.extraction_choice,'string');
				current=current{extractwhat};
				calxy=gui.gui_retr('calxy');
				if strcmp (A.Tag,'plot_data') %function called from button press
					h=figure;
					screensize=get( 0, 'ScreenSize' );
					rect = [screensize(3)/4-300, screensize(4)/2-250, 600, 500];
					set(h,'position', rect);
					set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',[current ', frame ' num2str(currentframe)],'tag', 'derivplotwindow');
					plot (1:numel(length), integral);
					hold on;
					scattergroup1=scatter(1:numel(length), integral, 80, 'ko');
					hold off;
					set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
					xlabel('circle series nr. (circle with max. circulation highlighted)');
					if (gui.gui_retr('calu')==1 || gui.gui_retr('calu')==-1) && gui.gui_retr('calxy')==1
						ylabel('tangent velocity loop integral (circulation) [px^2/frame]');
					else
						ylabel('tangent velocity loop integral (circulation) [m^2/s]');
					end
					h_extractionplot=gui.gui_retr('h_extractionplot');
					h_extractionplot(size(h_extractionplot,1)+1,1)=h;
					gui.gui_put ('h_extractionplot', h_extractionplot);
				end
				gui.gui_put('distance',distance*calxy);
				gui.gui_put('c',c);
				[cx_cal,cy_cal] = calibrate.calibrate_xy(cx,cy);
				gui.gui_put('cx',cx_cal);
				gui.gui_put('cy',cy_cal);
				gui.gui_put('integral', integral);
			end
		end
	end
end

