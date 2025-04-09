function vel_limit_Callback(caller, ~, ~)
%if analys existing
resultslist=gui.retr('resultslist');
handles=gui.gethand;
currentframe=2*floor(get(handles.fileselector, 'value'))-1;
if size(resultslist,2)>=(currentframe+1)/2 %data for current frame exists
	gui.toolsavailable(0)
	x=resultslist{1,(currentframe+1)/2};
	if size(x,1)>1
		%oldsize=get(gca,'outerposition');
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


		%problem: wenn nur ein frame analysiert, dann gibts probleme wenn display all frames in scatterplot an.
		datau=reshape(u*calu,1,size(u,1)*size(u,2)*size(u,3));
		datav=reshape(v*calv,1,size(v,1)*size(v,2)*size(v,3));

		limit_figure = findobj('Tag', 'limit_figure');

		if isempty(limit_figure)
			limit_figure = figure('Tag','limit_figure','MenuBar','none','DockControls','off','WindowStyle','modal','ToolBar','Figure','Name','Click + drag to select valid velocities','NumberTitle','off');
			limit_ax = axes('Parent',limit_figure);
		else
			figure(limit_figure)
			limit_ax = limit_figure.CurrentAxes;
		end

		if strcmpi(caller.Tag,'vel_limit_freehand')
			datau_mod=(datau');
			datav_mod=(datav');

			datau_mod=double(datau_mod*1);
			datav_mod=double(datav_mod*1);

			%MUST be double otherwise strange effects.

			datau_mod_nonans=datau_mod;
			datav_mod_nonans=datav_mod;

			datau_mod_nonans(isnan(datau_mod)|isnan(datav_mod))=[];
			datav_mod_nonans(isnan(datau_mod)|isnan(datav_mod))=[];
			scatplot=scatter(datau_mod_nonans,datav_mod_nonans,0.25,'.');
		else
			if size(datau,2)>1000000 %more than one million value pairs are too slow in scatterplot.
				pos=unique(ceil(rand(1000000,1)*(size(datau,2)-1))); %select random entries...
				scatplot=scatter(datau(pos),datav(pos), 0.25,'.'); %.. and plot them
			else
				scatplot=scatter(datau,datav, 0.25,'.');
			end
		end

		if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
			xlabel(limit_ax, 'u velocity [px/frame]', 'fontsize', 12)
			ylabel(limit_ax, 'v velocity [px/frame]', 'fontsize', 12)
		else %calibrated
			displacement_only=gui.retr('displacement_only');
			if ~isempty(displacement_only) && displacement_only == 1
				xlabel(limit_ax, 'u velocity [m/frame]', 'fontsize', 12)
				ylabel(limit_ax, 'v velocity [m/frame]', 'fontsize', 12)
			else
				xlabel(limit_ax, 'u velocity [m/s]', 'fontsize', 12)
				ylabel(limit_ax, 'v velocity [m/s]', 'fontsize', 12)
			end
		end

		%axis equal;
		grid(limit_ax,'on')
		set (limit_ax, 'tickdir', 'in');
		axes(limit_ax)

		if strcmpi(caller.Tag,'vel_limit_freehand')
			delete(findobj('tag', 'vel_limit_ROI_freehand'));
			regionOfInterest = images.roi.Freehand;
			%roi.EdgeAlpha=0.75;
			regionOfInterest.FaceAlpha=0.05;
			regionOfInterest.LabelVisible = 'on';
			regionOfInterest.Tag = 'vel_limit_ROI_freehand';
			regionOfInterest.Color = 'g';
			regionOfInterest.StripeColor = 'k';
			regionOfInterest.Label='Close window when done';
			regionOfInterest.LabelVisible='hover';
			roirect_freehand = gui.retr('velrect_freehand');
			if ~isempty(roirect_freehand)
				regionOfInterest=drawfreehand(limit_ax,'Position',roirect_freehand);
				%roi.EdgeAlpha=0.75;
				regionOfInterest.FaceAlpha=0.05;
				regionOfInterest.LabelVisible = 'off';
				regionOfInterest.Tag = 'vel_limit_ROI_freehand';
				regionOfInterest.Color = 'g';
				regionOfInterest.StripeColor = 'k';
			else
				axes(limit_ax)
				draw(regionOfInterest);
				gui.put ('velrect_freehand',regionOfInterest.Position);
			end
			addlistener(regionOfInterest,'MovingROI',@validate.RegionOfInterestevents);
			addlistener(regionOfInterest,'DeletingROI',@validate.RegionOfInterestevents);
			dummyevt.EventName = 'MovingROI';
			validate.RegionOfInterestevents(regionOfInterest,dummyevt); %run the moving event once to update displayed length

		else %rectangular ROI
			delete(findobj('tag', 'vel_limit_ROI'));
			regionOfInterest = images.roi.Rectangle;
			%roi.EdgeAlpha=0.75;
			regionOfInterest.FaceAlpha=0.05;
			regionOfInterest.Label='Close window when done';
			regionOfInterest.LabelVisible='hover';

			regionOfInterest.Tag = 'vel_limit_ROI';
			regionOfInterest.Color = 'g';
			regionOfInterest.StripeColor = 'k';
			roirect = gui.retr('velrect');
			if ~isempty(roirect)
				regionOfInterest=drawrectangle(limit_ax,'Position',roirect);
				%roi.EdgeAlpha=0.75;
				regionOfInterest.FaceAlpha=0.05;
				regionOfInterest.LabelVisible = 'off';
				regionOfInterest.Tag = 'vel_limit_ROI';
				regionOfInterest.Color = 'g';
				regionOfInterest.StripeColor = 'k';
			else
				axes(limit_ax)
				draw(regionOfInterest);
			end
			addlistener(regionOfInterest,'MovingROI',@validate.RegionOfInterestevents);
			addlistener(regionOfInterest,'DeletingROI',@validate.RegionOfInterestevents);
			dummyevt.EventName = 'MovingROI';
			validate.RegionOfInterestevents(regionOfInterest,dummyevt); %run the moving event once to update displayed length
			%put ('roirect',roi.Position);
		end
	end
	gui.toolsavailable(1)
end