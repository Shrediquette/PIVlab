function scatterplotter_Callback(~, ~, ~)
% Scatter plot of the velocities of the current frame (Statistics panel): u vs. v in 2D,
% a 3D scatter plot of u, v, w in stereo-PIV mode.
handles=gui.gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=gui.retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	smoothed=false;
	if size(resultslist,1)>6 %filtered exists
		if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
			u=resultslist{10,currentframe};
			v=resultslist{11,currentframe};
			smoothed=true;
		else
			u=resultslist{7,currentframe};
			if size(u,1)>1
				v=resultslist{8,currentframe};
			else
				%filter was applied to some other frame than this
				%load unfiltered results
				u=resultslist{3,currentframe};
				v=resultslist{4,currentframe};
			end
		end
	else
		u=resultslist{3,currentframe};
		v=resultslist{4,currentframe};
	end
	w=stereo.w_of_frame(currentframe,smoothed); %stereo-PIV, [] in 2D
	calu=gui.retr('calu');calv=gui.retr('calv');
	u=reshape(u,size(u,1)*size(u,2),1);
	v=reshape(v,size(v,1)*size(v,2),1);
	h=figure;
	axh=axes(h);
	screensize=get( 0, 'ScreenSize' );
	%rect = [screensize(3)/2-300, screensize(4)/2-250, 600, 500];
	rect = [screensize(3)/4-300, screensize(4)/2-250, 600, 500];
	set(h,'position', rect);
	if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
		unit=' [px/frame]';
	else
		displacement_only=gui.retr('displacement_only');
		if ~isempty(displacement_only) && displacement_only == 1
			unit=' [m/frame]';
		else
			unit=' [m/s]';
		end
	end
	if isempty(w)
		set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',['Scatter plot u & v, frame ' num2str(currentframe)],'tag', 'derivplotwindow');
		h2=scatter(u*calu-gui.retr('subtr_u'),v*calv-gui.retr('subtr_v'),'r.');
		set (axh, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
		xlabel(['u' unit]);
		ylabel(['v' unit]);
	else %stereo-PIV: 3D scatter plot of u, v, w
		set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',['Scatter plot u, v, w, frame ' num2str(currentframe)],'tag', 'derivplotwindow');
		w=reshape(w,numel(w),1);
		h2=scatter3(axh,u*calu-gui.retr('subtr_u'),v*calv-gui.retr('subtr_v'),w*abs(calu),'r.'); %|calu|: an axis flip of x or y does not flip w
		set (axh, 'xgrid', 'on', 'ygrid', 'on', 'zgrid', 'on', 'TickDir', 'in')
		xlabel(['u' unit]);
		ylabel(['v' unit]);
		zlabel(['w' unit]);
		view(axh,3);
		rotate3d(h,'on');
	end
end
