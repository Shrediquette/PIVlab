%[text] # This script will load a previously saved PIVlab session file, process the data, and then plot the ***mean velocity*** and the ***temporal standard deviation***.
%[text] This could e.g. be helpful if you need to prepare a lot of figures for publication, or if you need to perform custom measurements on your PIV data that is not available directly i n PIVlab.
clc
clear variables
close all
%%
%[text] ## Load and process a PIVlab session file that was saved in PIVlab
filename_to_process='PIVlab_session.mat'; % Select your session file here. Note that this script will only work with PIVlab session files.
load(filename_to_process); %load an analysis
x_px=resultslist{1,1}; %load x position data (will not change over time, therefore only loaded once
y_px=resultslist{2,1}; %same for y position
u_px=zeros(size(x_px,1),size(x_px,2),size(resultslist,2)); %initialize variable with expected size
v_px=u_px; %same for u velocity

origin_x_px = offset_x_true /calxy; %Origin of the coordinate system in pixel units
origin_y_px = offset_y_true /calxy; %Origin of the coordinate system in pixel units
%[text] Here, you can select which kind of velocity data to extract from the session file: raw, validated or smoothed:
velocity_data_to_extract='raw';
%velocity_data_to_extract='validated';
%velocity_data_to_extract='smoothed';
%[text] Data is then loaded in a loop and reshaped.
for i = 1:size(resultslist,2)
	switch velocity_data_to_extract %data is stored in diffrent places for the different kinds of velocity data.
		case 'raw'
			vector_type=resultslist{5,i}; %Vector type (masked = 0)
			u_px_temp = resultslist{3,i};
			v_px_temp = resultslist{4,i};
		case 'validated'
			vector_type=resultslist{9,i}; %Vector type (masked = 0)
			u_px_temp = resultslist{7,i};
			v_px_temp = resultslist{8,i};
		case 'smoothed'
			vector_type=resultslist{9,i}; %Vector type (masked = 0)
			u_px_temp = resultslist{10,i};
			v_px_temp = resultslist{11,i};
	end	
%[text] Data that is behind a mask should be removed
	u_px_temp(vector_type==0)=nan;
	v_px_temp(vector_type==0)=nan;
%[text] Data is re-organized in a 3D matrix. The first dimension is x direction, second dimension is  y direction, third dimension is time (or sample nr.)
	u_px(:,:,i) = u_px_temp;
	v_px(:,:,i) = v_px_temp;
end
%[text] Here, we convert the units to meters (per second) by multiplying the velocity data with the calibration constants.
%[text] These must have been applied in PIVlab. If the user didn't calibrate, then the units will still be px respectively px/m
%[text] (note that for plotting the graphs, we need to still use pixel units for x and y to align them properly to the pixel image)
if calxy == 1 || calu == 1 || calv == 1
	disp('No calibration performed, units we be px and px per image pair.')
end
x_m=x_px*calxy;
y_m=y_px*calxy;
u_m=u_px * calu;
v_m=v_px * calv;
%[text] Calculate velocity magnitude
magnitude_m = (u_m.^2+v_m.^2).^0.5;
%[text] Calculate mean over time and standard deviation over time
mean_u_m=mean(u_m,3,'omitnan');
mean_v_m=mean(v_m,3,'omitnan');
mean_magnitude_m=mean(magnitude_m,3,'omitnan');

std_u_m=std(u_m,0,3,'omitnan');
std_v_m=std(v_m,0,3,'omitnan');
std_magnitude_m=std(magnitude_m,0,3,'omitnan');
%[text] Prepare plots
fig1=figure;
t=tiledlayout(3,1);
t.TileSpacing = 'compact';
t.Padding = 'compact';
title(t,[velocity_data_to_extract ' velocity data'],'interpreter','none')
%[text] Prepare the pixel images for a better display. If the user calculated a background image, then enhance the image. If the user didn't, then load the first image from the PIVlab session.
if ~isempty(bg_img_A)
	background_image=imadjust(adapthisteq(bg_img_A,'NumTiles',[24 24]),[0.0 0.5]); % enhance contrast of background image for better display
else
	background_image=imread(filepath{1});
end
%[text] Generate vector plot, overlay over background image
nexttile
imshow(background_image);hold on; % display the background image
%[text] Skip vectors in the displayed image? Sometimes the vector density is too high and the graphics look better when not all vectors are displayed.
vec_skip = 1; %plot only every nth vector
%[text] Plot the vectors
quiver(x_px(1:vec_skip:end,1:vec_skip:end),y_px(1:vec_skip:end,1:vec_skip:end),mean_u_m(1:vec_skip:end,1:vec_skip:end),mean_v_m(1:vec_skip:end,1:vec_skip:end),'y');hold off % plot vectors over image
hold on
%[text] Plot the origin of the coordinate system
plot(origin_x_px,origin_y_px,'r+','MarkerSize',25,'LineWidth',1.5) % plot origin in graph if it exists.
hold off
%[text] Generate a mean velocity magnitude plot, overlaid over background image
nexttile
imshow(cat(3,background_image,background_image,background_image));hold on; % show background image
contourf(x_px,y_px,mean_magnitude_m,64,'LineColor','none');hold off %use 64 contours
c=colorbar;
if calxy == 1 || calu == 1 || calv == 1
	c.Label.String = 'Mean velocity magnitude in px/image pair';
else
	c.Label.String = 'Mean velocity magnitude in m/s';
end
%[text] Generate a temporal stdeviation velocity magnitude plot, overlaid over background image
nexttile
imshow(cat(3,background_image,background_image,background_image));hold on; % show background image
contourf(x_px,y_px,std_magnitude_m,64,'LineColor','none');hold off
c1=colorbar;
if calxy == 1 || calu == 1 || calv == 1
	c1.Label.String = 'Standard deviation velocity magnitude in px/image pair';
else
	c1.Label.String = 'Standard deviation velocity magnitude in m/s';
end
%[text] That's it, this example has shown how to get the relevant data from a PIVlab session and do your own processing on it.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":40}
%---
