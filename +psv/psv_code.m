function [xq,yq,uq,vq,typevector,no_streaks] = psv_code(img, binsize,roirect,converted_mask)
% identify objects
img=bitand(img,~converted_mask); %make masked area black
if numel(roirect)>0
    xroi=roirect(1);
    yroi=roirect(2);
    widthroi=roirect(3);
    heightroi=roirect(4);
    img_roi=img(yroi:yroi+heightroi,xroi:xroi+widthroi);
	converted_mask_roi=converted_mask(yroi:yroi+heightroi,xroi:xroi+widthroi);
else
	xroi=0;
	yroi=0;
	img_roi=img;
	converted_mask_roi=converted_mask;
end

object_info = regionprops(img_roi, 'BoundingBox', 'Centroid', 'Area', 'Eccentricity', 'Orientation');

% filter out identified objects to remain with line streaks then extract displacement data
% during filtering, check for circular/square objects (using eccentricity)
% during filtering, check for objects that are over-size (fused streaks) or under-size
min_size_threshold = 10;   % minimum size of objects in pixels
[mean_area, std_area] = psv.get_stats(object_info);
no_std = 2;
max_size_threshold = mean_area + no_std * std_area;  % maximum size of object in pixels
eccentricity_threshold = 0.75;  % criteria for identifying line objects from circular/square objects - e=1 for line while e=0 for circle


counter = 1;
for i = 1:length(object_info)
	x_disp = object_info(i).BoundingBox(3);   % x displacement/length
	y_disp = object_info(i).BoundingBox(4);   % y displacement/width
	centroid = object_info(i).Centroid;  % [x,y] coordinates of centroid
	area = object_info(i).Area;               % area of bounding box
	eccentricity = object_info(i).Eccentricity;  % eccentricity
	orientation = object_info(i).Orientation;  % orientation - angle between the horizontal and the major axis of ellipse around object
	if area > min_size_threshold && area < max_size_threshold  % filter out small objects based on acceptable size limits
		if eccentricity > eccentricity_threshold  % filter out circular objects based on eccentricity
			streaks.posn.x(counter, 1) = centroid(1, 1);   % x-coordinate of centroid of streak (pixel units)
			streaks.posn.y(counter, 1) = centroid(1, 2);   % y-coordinate of centroid of streak (pixel units)
			% orientation based on a horizontal datum and left endpoint of major axis of ellipse surrounding streak
			% orientation varies from -90 to 90 deg with positive being anticlockwise
			% negative orientation angle indicates velocity/displacement in +x,+y directions since (0,0) coordinate is at top left corner of image such that +y is downwards and +x is right

			if orientation > 0
				streaks.disp.x(counter, 1) = x_disp;   % x-displacement in pixel units
				streaks.disp.y(counter, 1) = -y_disp;   % y-displacement in pixel units
			else
				streaks.disp.x(counter, 1) = x_disp;   % x-displacement in pixel units
				streaks.disp.y(counter, 1) = y_disp;   % y-displacement in pixel units
			end
			counter = counter + 1;
		end
	end
end
if counter == 1
	disp('No streaks found. Change image settings or preprocessing.')
end

%% display particle streaks
%{
cla
hold on
imshow(img); % inverse image
quiver(streaks.posn.x(:,1), streaks.posn.y(:,1), streaks.disp.x(:,1), streaks.disp.y(:,1), 3, 'Linewidth', 0.25, 'color', 'g'); % velocity vectors
hold off
pause(2)
%}

%{
% Interpolate scattered data onto rectilinear grid
[xq,yq] = psv.generate_grid(img,binsize,roirect); %generate a grid just as in my PIV code
%griddata is much faster than manual method
% per-particle information is interpolated to a grid. This is currently necessary, as PIVlab expects gridded data.

uq = griddata(streaks.posn.x+xroi,streaks.posn.y+yroi,streaks.disp.x,xq,yq,'cubic');
vq = griddata(streaks.posn.x+xroi,streaks.posn.y+yroi,streaks.disp.y,xq,yq,'cubic');

%Remove areas that were masked
typevector=ones(size(xq));
for i = 1:size(xq,1)
	for j=1:size(xq,2)
		idx1=yq(i,j);
		idx2=xq(i,j);
		if converted_mask(idx1,idx2)==1
			uq(i,j)=nan;%remove velocity information (it exists, because this location was interpolated)
			vq(i,j)=nan;
			typevector(i,j)=0; %indicates that this location is masked
		end
	end
end

%}

%% alternative way to bin data:
% reduce displacement data based on binning

no_bins.x = binsize;
no_bins.y = binsize;
total_bins = no_bins.x * no_bins.y;
bins.centroid.x = zeros(total_bins, 1);  % x coordinate of center of bin
bins.centroid.y = zeros(total_bins, 1);  % y coordinate of center of bin
bins.disp.x = zeros(total_bins, 1);  % representative x-displacement at center of bin
bins.disp.y = zeros(total_bins, 1);  % representative y-displacement at center of bin
bins.std_disp.x = zeros(total_bins, 1);  % standard deviation of x-displacement based on number of streaks within bins
bins.std_disp.y = zeros(total_bins, 1);  % standard deviation of y-displacement based on number of streaks within bins
bins.no_streaks = zeros(total_bins, 1);  % number of streaks within bin


bins = psv.perform_data_reduction(img_roi, streaks, no_bins);

%reformat output matrices
xq=round(reshape(bins.centroid.x,[no_bins.y,no_bins.x])');
yq=round(reshape(bins.centroid.y,[no_bins.y,no_bins.x])');
uq=reshape(bins.disp.x,[no_bins.y,no_bins.x])';
vq=reshape(bins.disp.y,[no_bins.y,no_bins.x])';
typevector=ones(size(xq));
no_streaks=reshape(bins.no_streaks,[no_bins.y,no_bins.x])';

%Remove areas that were masked


for i = 1:size(xq,1)
	for j=1:size(xq,2)
		idx1=yq(i,j);
		idx2=xq(i,j);
		if converted_mask_roi(idx1,idx2)==1
			uq(i,j)=nan;%remove velocity information (it exists, because this location was interpolated)
			vq(i,j)=nan;
			typevector(i,j)=0; %indicates that this location is masked
		end
	end
end
xq=xq+xroi;
yq=yq+yroi;