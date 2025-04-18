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
			limit_figure = figure('Tag','limit_figure','MenuBar','none','DockControls','off','WindowStyle','modal','ToolBar','Figure','Name','Click + drag to select valid velocities','NumberTitle','off','CloseRequestFcn',@CustomCloseReq);
			limit_ax = axes('Parent',limit_figure);
		else
			figure(limit_figure)
			limit_ax = limit_figure.CurrentAxes;
		end

		%reduce plottable points when too much data
		if size(datau,2)>2000000 %more than two million value pairs are too slow in scatterplot.
			pos=unique(ceil(rand(2000000,1)*(size(datau,2)-1))); %select random entries...
			display_u = datau(pos);
			display_v = datav(pos);
			%disp('size reduction')
		else
			display_u = datau;
			display_v = datav;
		end

		%if strcmpi(caller.Tag,'vel_limit_freehand') || strcmpi(caller.Tag,'vel_limit_auto')
		datau_mod=double(datau');
		datav_mod=double(datav');

		display_u_mod=double(display_u');
		display_v_mod=double(display_v');

		%MUST be double otherwise strange effects.

		datau_mod_nonans=datau_mod;
		datav_mod_nonans=datav_mod;

		display_u_mod_nonans=display_u_mod;
		display_v_mod_nonans=display_v_mod;

		datau_mod_nonans(isnan(datau_mod)|isnan(datav_mod))=[];
		datav_mod_nonans(isnan(datau_mod)|isnan(datav_mod))=[];

		display_u_mod_nonans(isnan(display_u_mod)|isnan(display_v_mod))=[];
		display_v_mod_nonans(isnan(display_u_mod)|isnan(display_v_mod))=[];

		scatplot=scatter(display_u_mod_nonans,display_v_mod_nonans,0.25,'.');
		%else
		%	scatplot=scatter(display_u,display_v, 0.25,'.');
		%end

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

		if strcmpi(caller.Tag,'vel_limit_freehand') || strcmpi(caller.Tag,'vel_limit_auto')
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
			%wie soll sich das verhalten? Auto soll immer das freehand löschen und ein neues zeichnen.
			if strcmpi(caller.Tag,'vel_limit_auto')
				roirect_freehand=[];
			end
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
				if strcmpi(caller.Tag,'vel_limit_auto')

					% Parameters to adjust
					point_amount = numel(datau_mod_nonans);
					if point_amount < 625
						point_amount = 625;
					end

					if point_amount > 30000000
						point_amount = 30000000;
					end

					lowpass_size = ceil(sqrt(point_amount)/25);%15;
					gridSize = ceil(sqrt(point_amount))+30;%500; % larger = more strict

					% Normalize and bin points
					x_norm = rescale(datau_mod_nonans, 1, gridSize);
					y_norm = rescale(datav_mod_nonans, 1, gridSize);
					binX = round(x_norm);
					binY = round(y_norm);

					% Create binary occupancy grid
					mask = accumarray([binY, binX], 1, [gridSize gridSize]) > 0;
					% figure;imagesc(mask)
					se = strel('disk',2);
					mask=imclose(mask, se);
					%figure;imagesc(mask)
					mask=imopen(mask, se);
					%figure;imagesc(mask)
					mask=imgaussfilt(double(mask),lowpass_size);
					%figure;imagesc(mask)
					% pixels = mask(:);
					% sortedPixels = sort(pixels,'descend');
					% sortedPixels(sortedPixels==0)=[]; %remove zeroes
					% numPixels = numel(sortedPixels);
					% indexThreshold = round(0.9 * numPixels);
					%threshold = sortedPixels(indexThreshold)
					threshold= 0.333;

					mask = mask > threshold;
					%figure;imagesc(mask)
					% Get boundary from binary image
					B = bwboundaries(mask);
					%keep only the largest area
					if size(B,1)>1
						for i=1:numel(B)
							B{i,2} = numel (B{i,1});
						end
						B=sortrows(B,2,'descend');
					end
					if numel(B)>0
						boundaryPixels = B{1,1};
						%figure(limit_figure)
						% Convert back to original coordinate scale
						% Define bounds from original data
						x_min = min(datau_mod_nonans);
						x_max = max(datau_mod_nonans);
						y_min = min(datav_mod_nonans);
						y_max = max(datav_mod_nonans);

						% Map back from pixel/grid to original data space
						bx = x_min + (boundaryPixels(:,2) - 1) / (gridSize - 1) * (x_max - x_min);
						by = y_min + (boundaryPixels(:,1) - 1) / (gridSize - 1) * (y_max - y_min);

						% --- 1. Smooth by downsampling input points ---
						%allow 100 steps.
						step=round(numel(bx)/20);
						%step = 25; % adjust for how much simplification you want
						bx_ds = bx(1:step:end);
						by_ds = by(1:step:end);

						% Make sure it closes the loop (optional)
						if ~isequal([bx_ds(1), by_ds(1)], [bx_ds(end), by_ds(end)])
							bx_ds(end+1) = bx_ds(1);
							by_ds(end+1) = by_ds(1);
						end

						% --- 2. Fit spline in arc-length space ---
						dx = diff(bx_ds);
						dy = diff(by_ds);
						s = [0; cumsum(sqrt(dx.^2 + dy.^2))];
						[su, unique_idx] = unique(s); % Remove duplicates if needed

						s_uniform = linspace(0, su(end), 300); % Evaluate at 300 points

						bx_smooth = pchip(su, bx_ds(unique_idx), s_uniform);
						by_smooth = pchip(su, by_ds(unique_idx), s_uniform);

						regionOfInterest = drawfreehand('Position', [bx_smooth(:), by_smooth(:)], 'Color', 'g', 'LineWidth', 2);
						regionOfInterest.Label='Close window when done';
						regionOfInterest.LabelVisible='hover';
						regionOfInterest.FaceAlpha=0.05;
						regionOfInterest.Tag = 'vel_limit_ROI_freehand';
						regionOfInterest.Color = 'g';
						regionOfInterest.StripeColor = 'k';

						reduce(regionOfInterest)
						%roi.Waypoints(:) = true;
						gui.put ('velrect_freehand',regionOfInterest.Position);
						set(limit_figure,'Name','Automatic limits applied.')
					else %no automatic limits possible
						clearvars("regionOfInterest")
						set(limit_figure,'Name','Could not find suitable limits.')
					end
				else
					draw(regionOfInterest);
					if exist ('regionOfInterest','var') && isprop(regionOfInterest,'Position')
						while exist ('regionOfInterest','var') && isprop(regionOfInterest,'Position') && size(regionOfInterest.Position,1)<=1 %user doesnt click + drag
							regionOfInterest.Label='Click and drag to draw freehand shape';
							regionOfInterest.LabelVisible='on';
							pause(1)
							if exist ('regionOfInterest','var') && isprop(regionOfInterest,'Label')
								regionOfInterest.Label='Close window when done';
								regionOfInterest.LabelVisible='hover';
								draw(regionOfInterest);
							end
						end
						if exist ('regionOfInterest','var') && isprop(regionOfInterest,'Position') && regionOfInterest.Position(3)+regionOfInterest.Position(4) >0
							gui.put ('velrect_freehand',regionOfInterest.Position);
						end
					end
				end
			end
			if exist ('regionOfInterest','var') && isprop(regionOfInterest,'Position')
				addlistener(regionOfInterest,'MovingROI',@validate.RegionOfInterestevents);
				addlistener(regionOfInterest,'ROIMoved',@validate.RegionOfInterestevents);
				addlistener(regionOfInterest,'DeletingROI',@validate.RegionOfInterestevents);
				dummyevt.EventName = 'MovingROI';
				validate.RegionOfInterestevents(regionOfInterest,dummyevt); %run the moving event once to update displayed length
				dummyevt.EventName = 'ROIMoved';
				validate.RegionOfInterestevents(regionOfInterest,dummyevt); %run the moving event once to update displayed length
			end
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
				if exist ('regionOfInterest','var') && isprop(regionOfInterest,'Position')
					while exist ('regionOfInterest','var') && isprop(regionOfInterest,'Position') && regionOfInterest.Position(3)+regionOfInterest.Position(4) ==0 %user doesnt click + drag
						regionOfInterest.Label='Click and drag to draw rectangle';
						regionOfInterest.LabelVisible='on';
						pause(1)
						if exist ('regionOfInterest','var') && isprop(regionOfInterest,'Label')
							regionOfInterest.Label='Close window when done';
							regionOfInterest.LabelVisible='hover';
							draw(regionOfInterest);
						end
					end
					if exist ('regionOfInterest','var') && isprop(regionOfInterest,'Position') && regionOfInterest.Position(3)+regionOfInterest.Position(4) >0
						gui.put ('velrect',regionOfInterest.Position);
					end
				end
			end
			if exist ('regionOfInterest','var') && isprop(regionOfInterest,'Position')
				addlistener(regionOfInterest,'MovingROI',@validate.RegionOfInterestevents);
				addlistener(regionOfInterest,'DeletingROI',@validate.RegionOfInterestevents);
				addlistener(regionOfInterest,'ROIMoved',@validate.RegionOfInterestevents);
				dummyevt.EventName = 'MovingROI';
				validate.RegionOfInterestevents(regionOfInterest,dummyevt); %run the moving event once to update displayed length
				dummyevt.EventName = 'ROIMoved';
				validate.RegionOfInterestevents(regionOfInterest,dummyevt); %run the moving event once to update displayed length
			end
			%put ('roirect',roi.Position);
		end
	end
	gui.toolsavailable(1)
end

function CustomCloseReq(A,~,~)
gui.toolsavailable(1)
delete(A)

