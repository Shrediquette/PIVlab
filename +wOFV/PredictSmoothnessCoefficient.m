function [EtaPred,PatchSizePred] = PredictSmoothnessCoefficient(x,y,u_filt,v_filt,I0Org,I1Org,roirect)

%takes in an image pair, along with the correlation
%velocity field, and returns the smoothness parameter eta
%EtaPred is the etaUnScaled variable in PIVLab
%note roirect should select a square region -- preferrably of size 256x256
%(but it would work otherwise)

%I think PIVLab always returns cells, so just converting those to simple
%double arrays here to avoid any complications
%{
x = double(x{1});
y = double(y{1});
u_filt = double(u_filt{1});
v_filt = double(v_filt{1});
%}


%crop the images according to ROI -- ROI needs to be squared. 
I0 = I0Org(roirect(2):roirect(2)+roirect(4)-1,roirect(1):roirect(1)+roirect(3)-1);
I1 = I1Org(roirect(2):roirect(2)+roirect(4)-1,roirect(1):roirect(1)+roirect(3)-1); 

%interpolate the results to the full image size
[X,Y] = ndgrid(1:size(I0,1),1:size(I0,2));
InterpObju = griddedInterpolant(x',y',u_filt,'linear','linear');
InterpObjv = griddedInterpolant(x',y',v_filt,'linear','linear');
VInt = double(cat(3,InterpObjv(X,Y),InterpObju(X,Y)));

%if the image isn't square, crop the image and velocties to be square
NearImSqSize = nextpow2(min(size(I0)));
if (size(I0,1) == size(I0,2)) && (size(I0,1) == 2^NearImSqSize)
    I0 = I0(1:2^NearImSqSize,1:2^NearImSqSize);
    I1 = I1(1:2^NearImSqSize,1:2^NearImSqSize);
    VInt = VInt(1:2^NearImSqSize,1:2^NearImSqSize,:);
else
    I0 = I0(1:2^(NearImSqSize-1),1:2^(NearImSqSize-1));
    I1 = I1(1:2^(NearImSqSize-1),1:2^(NearImSqSize-1));
    VInt = VInt(1:2^(NearImSqSize-1),1:2^(NearImSqSize-1),:);
end

[Grid.n,Grid.m] = size(VInt(:,:,1));
[Grid.X,Grid.Y] = meshgrid(1:Grid.n,1:Grid.m); Grid.X=Grid.X';Grid.Y=Grid.Y'; Grid.n=Grid.n+1; Grid.m = Grid.m+1;


%% check if the filter matrix exists, if it doesn't generate them
[filepath,~,~]=  fileparts(which('PIVlab_GUI.m'));
if ~exist(fullfile(filepath,'+wOFV','Filter matrices','bior6.8',num2str(size(I0,1)) ,'Fmats.mat'),'file')
    wOFV.FetchFilterMatrices();
end



%% Load the Ni's and Fmat for JD and JR Computation
%JR
%FMat = load(['Filter matrices/bior6.8/' num2str(size(I0,1)) '/Fmats.mat']);

FMat  = load(fullfile(filepath,'+wOFV','Filter matrices','bior6.8',num2str(size(I0,1)) ,'Fmats.mat'));


Ni = cat(3,FMat.N0,FMat.N1,FMat.N2,FMat.N3,FMat.N4);
Fw = FMat.Fw;

JR = wOFV.RegComputeFromVel(VInt,Fw,Ni,log2(size(I0,1)) - 1);

%JD
n = size(VInt,1);
%Create a gridded interpolant object for I1
[X1,Y1]=ndgrid(1:n+1,1:n+1);
%Extend I1 by one pixel (using symmetric BC) to avoid boundary issues
I1Mod=[I1,I1(:,end)]';
I1Mod=[I1Mod,I1Mod(:,end)]';
I1Int=griddedInterpolant(X1,Y1,double(I1Mod),'spline');

%Create a gridded interpolant object for I0
[X1,Y1]=ndgrid(1:n+1,1:n+1);
%Extend I1 by one pixel (using symmetric BC) to avoid boundary issues
I0Mod=[I0,I0(:,end)]';
I0Mod=[I0Mod,I0Mod(:,end)]';
I0Int=griddedInterpolant(X1,Y1,double(I0Mod),'spline');

%Motion-compensated image (Org)
% IwF = wOFV_warpS(I0Int,VInt/2);
% IwR = wOFV_warpS(I1Int,-VInt/2);
IwF = wOFV.warpS(I0Int,VInt/2,Grid);
IwR = wOFV.warpS(I1Int,-VInt/2,Grid);
sigma=2;
JD = trapz(trapz(log(1+.5*(IwF-IwR).^2/sigma^2)));

%% Compute n (filter size estimate) -- based on the spacing between vectors
VecSpacing = x(1,2) - x(1,1);
n = log2(VecSpacing); %for testing, n = 3 for 16x16 final window size with 50% overlap

%% Prediciton
%predict the smoothness coefficient
EtaPred = wOFV.OrderOfMag(JD) - wOFV.OrderOfMag(JR) - n; 
EtaPred = round(10*(EtaPred + 5)); %scaling eta to [0,100]

%predict patch size
mag = sqrt(u_filt.^2 + v_filt.^2);
MostProbableVectorMag = round(mode(mag,'all'),0);

if MostProbableVectorMag > 14
    PatchSizePred = 512;
else
    PatchSizePred = 256;
end
