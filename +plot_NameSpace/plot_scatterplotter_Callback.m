function plot_scatterplotter_Callback(~, ~, ~)
handles=gui_NameSpace.gui_gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=gui_NameSpace.gui_retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	if size(resultslist,1)>6 %filtered exists
		if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
			u=resultslist{10,currentframe};
			v=resultslist{11,currentframe};
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
	calu=gui_NameSpace.gui_retr('calu');calv=gui_NameSpace.gui_retr('calv');
	u=reshape(u,size(u,1)*size(u,2),1);
	v=reshape(v,size(v,1)*size(v,2),1);
	h=figure;
	screensize=get( 0, 'ScreenSize' );
	%rect = [screensize(3)/2-300, screensize(4)/2-250, 600, 500];
	rect = [screensize(3)/4-300, screensize(4)/2-250, 600, 500];
	set(h,'position', rect);
	set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',['Scatter plot u & v, frame ' num2str(currentframe)],'tag', 'derivplotwindow');
	h2=scatter(u*calu-gui_NameSpace.gui_retr('subtr_u'),v*calv-gui_NameSpace.gui_retr('subtr_v'),'r.');
	set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
	if (gui_NameSpace.gui_retr('calu')==1 || gui_NameSpace.gui_retr('calu')==-1) && gui_NameSpace.gui_retr('calxy')==1
		xlabel('u [px/frame]');
		ylabel('v [px/frame]');
	else
		xlabel('u [m/s]');
		ylabel('v [m/s]');
	end
end
