%% This script can be used to check whether PIVlab generates high quality results on a specific harware / OS / MATLAB combination
% (note that we are sure that it always does)
close all;clear all; clc;drawnow

%% Generate random artificial particle images
size=600;
partAm=120000;
Z=0.333; %0.25 sheet thickness
dt=3; %particle diameter
ddt=0; %particle diameter variation
disp(['Generating random artificial PIV images with ' num2str(partAm) ' particles...'])
[v,u] = meshgrid(-size/2:1:size/2-1,-size/2:1:size/2-1);
u=u/max(max(u));
v=-v/max(max(v));
u=u*5;
v=v*5;
[x,y]=meshgrid(1:1:size);
i=[];
j=[];
sizey=size;
sizex=size;
A=zeros(sizey,sizex);
B=A;
z0_pre=randn(partAm,1); %normal distributed sheet intensity
randn('state', sum(100*clock)); %#ok<*RAND>
z1_pre=randn(partAm,1); %normal distributed sheet intensity

z_move=0; %out-of-plane-movement

z0=z0_pre*(z_move/200+0.5)+z1_pre*(1-((z_move/200+0.5)));
z1=z1_pre*(z_move/200+0.5)+z0_pre*(1-((z_move/200+0.5)));

I0=255*exp(-(Z^2./(0.125*z0.^2))); %particle intensity
I0(I0>255)=255;
I0(I0<0)=0;

I1=255*exp(-(Z^2./(0.125*z1.^2))); %particle intensity
I1(I1>255)=255;
I1(I1<0)=0;

randn('state', sum(100*clock));
d=randn(partAm,1)/2; %particle diameter distribution
d=dt+d*ddt;
d(d<0)=0;
rand('state', sum(100*clock));
x0=rand(partAm,1)*sizex;
y0=rand(partAm,1)*sizey;
rd = -8.0 ./ d.^2;
offsety=v;
offsetx=u;

xlimit1=floor(x0-d/2); %x min particle extent image1
xlimit2=ceil(x0+d/2); %x max particle extent image1
ylimit1=floor(y0-d/2); %y min particle extent image1
ylimit2=ceil(y0+d/2); %y max particle extent image1
xlimit2(xlimit2>sizex)=sizex;
xlimit1(xlimit1<1)=1;
ylimit2(ylimit2>sizey)=sizey;
ylimit1(ylimit1<1)=1;

%calculate particle extents for image2 (shifted image)
x0integer=round(x0);
x0integer(x0integer>sizex)=sizex;
x0integer(x0integer<1)=1;
y0integer=round(y0);
y0integer(y0integer>sizey)=sizey;
y0integer(y0integer<1)=1;

xlimit3=zeros(partAm,1);
xlimit4=xlimit3;
ylimit3=xlimit3;
ylimit4=xlimit3;
for n=1:partAm
    xlimit3(n,1)=floor(x0(n)-d(n)/2-offsetx((y0integer(n)),(x0integer(n)))); %x min particle extent image2
    xlimit4(n,1)=ceil(x0(n)+d(n)/2-offsetx((y0integer(n)),(x0integer(n)))); %x max particle extent image2
    ylimit3(n,1)=floor(y0(n)-d(n)/2-offsety((y0integer(n)),(x0integer(n)))); %y min particle extent image2
    ylimit4(n,1)=ceil(y0(n)+d(n)/2-offsety((y0integer(n)),(x0integer(n)))); %y max particle extent image2
end
xlimit3(xlimit3<1)=1;
xlimit4(xlimit4>sizex)=sizex;
ylimit3(ylimit3<1)=1;
ylimit4(ylimit4>sizey)=sizey;

ctr=0;
for n=1:partAm
    ctr=ctr+1;
    if ctr==10000
        ctr=0;
        fprintf('.')
    end
    r = rd(n);
    for j=xlimit1(n):xlimit2(n)
        rj = (j-x0(n))^2;
        for i=ylimit1(n):ylimit2(n)
            A(i,j)=A(i,j)+I0(n)*exp((rj+(i-y0(n))^2)*r);
        end
    end
    for j=xlimit3(n):xlimit4(n)
        for i=ylimit3(n):ylimit4(n)
            B(i,j)=B(i,j)+I1(n)*exp((-(j-x0(n)+offsetx(i,j))^2-(i-y0(n)+offsety(i,j))^2)*-rd(n)); %place particle with gaussian intensity profile
        end
    end
end

A(A>255)=255;
B(B>255)=255;
A=uint8(A);
B=uint8(B);

x_real=x;
y_real=y;
u_real=u;
v_real=v;

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

image1 = PIVlab_preproc (A,p{1,2},p{2,2},p{3,2},p{4,2},p{5,2},p{6,2},p{7,2},p{8,2},p{9,2},p{10,2}); %preprocess images
image2 = PIVlab_preproc (B,p{1,2},p{2,2},p{3,2},p{4,2},p{5,2},p{6,2},p{7,2},p{8,2},p{9,2},p{10,2});
tic % start timer for PIV analysis only
[x y u v typevector,~,~] = piv_FFTmulti (image2,image1,s{1,2},s{2,2},s{3,2},s{4,2},s{5,2},s{6,2},s{7,2},s{8,2},s{9,2},s{10,2},s{11,2},s{12,2},s{13,2},0,s{14,2},s{15,2});
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

figure
image((double(image1)+double(image2))/10);colormap('gray');
hold on
quiver(x,y,u_real_reduced,v_real_reduced,'g','AutoScaleFactor', 1.5);
hold off;
axis image;
set(gca,'xtick',[],'ytick',[])
title('Vector map of real velocities')

figure
image((double(image1)+double(image2))/10);colormap('gray');
hold on
quiver(x,y,u,v,'g','AutoScaleFactor', 1.5);
hold off;
axis image;
set(gca,'xtick',[],'ytick',[])
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

