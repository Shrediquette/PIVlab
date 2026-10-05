%% This script can be used to check whether PIVlab generates high quality results on a specific harware / OS / MATLAB combination
% (note that we are sure that it always does)
close all;clear all; clc;drawnow
addpath(fileparts(fileparts(mfilename('fullpath'))));

%% Generate random artificial particle images
img_size=600;
partAm=120000;
Z=0.333; %sheet thickness
disp(['Generating random artificial PIV images with ' num2str(partAm) ' particles...'])
flow.type='rotation';
flow.imageSize=[img_size img_size];
flow.rotation=5; %maximum displacement of the rotation
[x_real,y_real]=meshgrid(1:img_size);
[u_real,v_real]=simulate.flow_field(flow, x_real, y_real);
[A,B] = simulate.gui_images(x_real, y_real, u_real, v_real, Particles=partAm, SheetThickness=Z, Diameter=3, DiameterVariation=0);

clearvars -except A B u_real v_real x_real y_real
fprintf('\n\n');

%% Analyze the image with piv_FFTmulti
disp('Performing PIV analysis with deforming windows and 4 passes...')
% Standard PIV Settings
s = cell(15,2); % To make it more readable, let's create a "settings table"
%Parameter                       %Setting           %Options
s{1,1}= 'Int. area 1';           s{1,2}=32;         % window size of first pass
s{2,1}= 'Step size 1';           s{2,2}=16;         % step of first pass
s{3,1}= 'Subpix. finder';        s{3,2}=1;          % 1 = 3point Gauss, 2 = 2D Gauss
s{4,1}= 'Mask';                  s{4,2}=[];         % If needed, generate via: imagesc(image); [temp,Mask{1,1},Mask{1,2}]=roipoly;
s{5,1}= 'ROI';                   s{5,2}=[];         % Region of interest: [x,y,width,height] in pixels, may be left empty
s{6,1}= 'Nr. of passes';         s{6,2}=4;          % 1-4 nr. of passes
s{7,1}= 'Int. area 2';           s{7,2}=32;         % second pass window size
s{8,1}= 'Int. area 3';           s{8,2}=32;         % third pass window size
s{9,1}= 'Int. area 4';           s{9,2}=32;         % fourth pass window size
s{10,1}='Window deformation';    s{10,2}='*spline'; % '*spline' is more accurate, but slower
s{11,1}='Repeated Correlation';     s{11,2}=0;         % 0 or 1 : Repeat the correlation four times and multiply the correlation matrices.
s{12,1}='Disable Autocorrelation';  s{12,2}=0;         % 0 or 1 : Disable Autocorrelation in the first pass. 
s{13,1}='Correlation style';  s{13,2}=0;         % 0 or 1 : Use circular correlation (0) or linear correlation (1).
s{14,1}='Repeat last pass';   s{14,2}=0; % 0 or 1 : Repeat the last pass of a multipass analyis
s{15,1}='Last pass quality slope';   s{15,2}=0.025; % Repetitions of last pass will stop when the average difference to the previous pass is less than this number.

% Standard image preprocessing settings
p = cell(8,1);
%Parameter                       %Setting           %Options
p{1,1}= 'ROI';                   p{1,2}=s{5,2};     % same as in PIV settings
p{2,1}= 'CLAHE';                 p{2,2}=1;          % 1 = enable CLAHE (contrast enhancement), 0 = disable
p{3,1}= 'CLAHE size';            p{3,2}=50;         % CLAHE window size
p{4,1}= 'Highpass';              p{4,2}=0;          % 1 = enable highpass, 0 = disable
p{5,1}= 'Highpass size';         p{5,2}=15;         % highpass size
p{6,1}= 'Clipping';              p{6,2}=0;          % 1 = enable clipping, 0 = disable
p{7,1}= 'Wiener';                p{7,2}=0;          % 1 = enable Wiener2 adaptive denaoise filter, 0 = disable
p{8,1}= 'Wiener size';           p{8,2}=3;          % Wiener2 window size
p{9,1}= 'Minimum intensity';     p{9,2}=0.0;          % Minimum intensity of input image (0 = no change) 
p{10,1}='Maximum intensity';     p{10,2}=1.0;         % Maximum intensity on input image (1 = no change)


% PIV analysis:

image1 = preproc.PIVlab_preproc( ...
    in=A, roirect=p{1,2}, clahe=p{2,2}, clahesize=p{3,2}, highp=p{4,2}, ...
    highpsize=p{5,2}, intenscap=p{6,2}, wienerwurst=p{7,2}, ...
    wienerwurstsize=p{8,2}, minintens=p{9,2}, maxintens=p{10,2}); %preprocess images
image2 = preproc.PIVlab_preproc( ...
    in=B, roirect=p{1,2}, clahe=p{2,2}, clahesize=p{3,2}, highp=p{4,2}, ...
    highpsize=p{5,2}, intenscap=p{6,2}, wienerwurst=p{7,2}, ...
    wienerwurstsize=p{8,2}, minintens=p{9,2}, maxintens=p{10,2});
tic % start timer for PIV analysis only
[x y u v typevector,~,~] = piv.piv_FFTmulti( ...
	image1=image1, image2=image2, interrogationarea=s{1,2}, step=s{2,2}, ...
	subpixfinder=s{3,2}, mask_inpt=s{4,2}, roi_inpt=s{5,2}, passes=s{6,2}, ...
	int2=s{7,2}, int3=s{8,2}, int4=s{9,2}, imdeform=s{10,2}, ...
	repeat=s{11,2}, mask_auto=s{12,2}, do_linear_correlation=s{13,2}, ...
	do_correlation_matrices=0, repeat_last_pass=s{14,2}, ...
	delta_diff_min=s{15,2});
clearvars -except x y u v typevector image1 image2 u_real v_real x_real y_real A B
elapsedtime=toc;
fprintf('\n\n');

%% Compare the real velocities from the synthetic images with the calculated velocities.
disp('Plotting figures with comparisons of real and calculated velocities...')
for i=1:size(x,1)
    for j=1:size(x,2)
        u_real_reduced(i,j)=u_real(y(i,j),x(i,j)); %pick real velocities from those points where velocities were calculated via PIV
        v_real_reduced(i,j)=v_real(y(i,j),x(i,j));
    end
end
%Remove values at the borders of the analysis: These are always less
%reliable (because a part of the interrogation area is just blank), and
%they deteriorate the result of this comparison without legal cause.
u(:,1)=[];u(:,end)=[];u(1,:)=[];u(end,:)=[];
v(:,1)=[];v(:,end)=[];v(1,:)=[];v(end,:)=[];
x(:,1)=[];x(:,end)=[];x(1,:)=[];x(end,:)=[];
y(:,1)=[];y(:,end)=[];y(1,:)=[];y(end,:)=[];
u_real_reduced(:,1)=[];u_real_reduced(:,end)=[];u_real_reduced(1,:)=[];u_real_reduced(end,:)=[];
v_real_reduced(:,1)=[];v_real_reduced(:,end)=[];v_real_reduced(1,:)=[];v_real_reduced(end,:)=[];

%Plotting figures

figure;imshow(A,'initialmagnification', 100);title('Artificial PIV image A')
figure;imshow(B,'initialmagnification', 100);title('Artificial PIV image B')

f1=figure;
axh1=axes(f1);
image((double(image1)+double(image2))/10);colormap('gray');
hold on
quiver(x,y,u_real_reduced,v_real_reduced,'g','AutoScaleFactor', 1.5);
hold off;
axis image;
set(axh1,'ytick',[])
set(axh1,'xtick',[])
title('Vector map of real velocities')

f2=figure;
axh2=axes(f2);
image((double(image1)+double(image2))/10);colormap('gray');
hold on
quiver(x,y,u,v,'g','AutoScaleFactor', 1.5);
hold off;
axis image;
set(axh2,'xtick',[],'ytick',[])
title('Vector map of PIV analysis')

figure;imagesc(sqrt(u_real_reduced.^2+v_real_reduced.^2));title('Real displacement magnitude');
figure;imagesc(sqrt(u.^2+v.^2));title('Calculated displacement magnitude');

figure;scatter(reshape(u_real_reduced,size(x,1)*size(x,2),1),reshape(u,size(x,1)*size(x,2),1),'g.')% plots real vs calculated u displacements
xlabel('Real displacement in x-direction [px]');ylabel('Measured displacement in x-direction [px]');title('Real vs. calculated displacements in x-direction')
figure;scatter(reshape(v_real_reduced,size(x,1)*size(x,2),1),reshape(v,size(x,1)*size(x,2),1),'b.')% plots real vs calculated v displacements
xlabel('Real displacement in y-direction [px]');ylabel('Measured displacement in y-direction [px]');title('Real vs. calculated displacements in y-direction')

fprintf('\n\n');
disp(['Accuracy tests finished. Elapsed time: ' num2str(elapsedtime) ' seconds.'])
disp([ 'Mean (n = ' num2str(numel(x)) ') error u displacement: ' num2str(abs(mean2(u-u_real_reduced))) ' +- ' num2str(std2(u-u_real_reduced)) ' px'])
disp([ 'Mean (n = ' num2str(numel(x)) ') error v displacement: ' num2str(abs(mean2(v-v_real_reduced))) ' +- ' num2str(std2(v-v_real_reduced)) ' px'])
disp(['See figures for the detailed results.'])
clear i j typevector