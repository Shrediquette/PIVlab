function [XGrid,YGrid,vHorz,vVert,Typevector]=RunMain_Parallel_DatasetProc(I0Org,I1Org,mask,roirect,eta,vartheta,MedFiltFlag,MedFiltSize,PyramidLevels,Fmats,M)


%Wavelet optical flow function, required inputs are I0 and I1 to be
%analyzed for velocimetry, and lambda is the (scalar) regularization
%parameter. The images (inputs I0 and I1) must be the same size, (Nr x Nc) where Nr is the
%number of rows and Nc is the number of columns. The primary output is v1,
%the estimated velocity field, which is an (Nr x Nc x 2) array. The
%x-velocity (positive down) is contained in the 1st 2D array along
%dimension 3 of v1, and the y-velocity (positive right) is contained in the
%2nd 2D array along dimension 3 of v1.
%
%The function uses a separable wavelet transform with symmetric
%biorthogonal wavelets implemented with matrix multiplication. The
%regularization is performed using continuous approximation (via Derian,
%2012). Non-square images and images where the image size N is not a power
%of 2 are handled by subdividing the domain into square regions of size
%2^M, with mx and my regions in each dimension (the overlap is computed
%automatically). The results from each region are combined with weighting
%by a 2-D, separable Nuttall window to avoid sharp transitions at subdomain
%boundaries.
%
%There is an optional input structure called 'options'. This is a structure
%that can contain any or all of these optional fields:
%- C - the coarsest scale solved. Must be an integer between 0 and the scale
%of the subwindows F, F=log2(M). (default 0)
%- L - the finest scale solved. Must be an integer between C and F.
%(default F-1)
%- v0 - initial guess of the velocity field, typically an average velocity.
%Must be an (Nr x Nc x 2) array (default 0's).
%- regscheme - scheme for regularization. Must be a string, selected from
%the following list:
%   - 'HS': Horn and Schunck (1st order, Horn & Schunck, 1984)
%   - 'lap': Laplacian of u and v
%   - '2Tik': 2nd order Tikhonov
%   - 'divcurl': Gradient of divergence and curl (Corpetti et al., 2002)
%   - 'visc' (default): Viscosity-based regularization (Schmidt & Sutton,
%2021)
%- M - scale of the subwindows. Each subwindow is (2^M x 2^M) in size. Must
%be an integer between 1 and min(nextpow2([Nr,Nc])
%(default min(nextpow2([Nr,Nc]))
%- mx - number of subwindows in the x (vertical) direction. Must be an
%integer greater than or equal to 1. If an insufficient number of
%subwindows are specified in order to cover the image based on M and Nr,
%the code will produce an error. Similarly, if an insufficient number of
%subwindows are specified to cover the image without producing significant
%overlap artifacts, the code will produce a warning but proceed. (default
%is minimum possible of subwindows based on M, Nr, and an anti-artifact
%criteria, which is that the overlap between subwindows must be at least
%10% of M)
%- my - number of subwindows in the y (horizontal) direction. Must be an
%integer greater than or equal to 1. If an insufficient number of
%subwindows are specified in order to cover the image based on M and Nc,
%the code will produce an error. Similarly, if an insufficient number of
%subwindows are specified to cover the image without producing significant
%overlap artifacts, the code will produce a warning but proceed. (default
%is minimum possible of subwindows based on M, Nc, and an anti-artifact
%criteria, which is that the overlap between subwindows must be at least
%10% of M)
%- mask - a logical matrix with ones where the computation is desired and
%zero where it is not. mask must be the same size as the input images.
%
%An optional parameter is specified by creating a variable called 'options'
%prior to the function call of wOFV_run and giving it an entry for each
%desired option. For example, to specify C as 1 and regscheme as 'lap', the
%following lines should precede the call of wOFV_run (in any order):
%options.C=1;
%options.regscheme='lap';
%
%Optional outputs are subOut and minOut.
%subOut is a structure containing M, mx, and my, hence describing how the
%image was subdivided.
%minOut is an array of structures of the output data from minFunc, the
%minimization function used to solve the DFD equation. This can be useful
%for testing. minOut contains an output structure for each subwindow,
%organized in row-major order (I know, MATLAB usually uses column-major
%order. My bad.)

M = min(M,2048); %cap M

if isempty(roirect)
    roirect = [1,1,size(I0Org,2)-1,size(I0Org,1)-1];
end

mask = ~mask; %PIVLab seems to use an inverted mask

%To use with gridded interpolant, we need these to be single/double
I0Org = im2double(I0Org);
I1Org = im2double(I1Org);


%cut image according to ROI
I0 = I0Org(roirect(2):roirect(2)+roirect(4)-1,roirect(1):roirect(1)+roirect(3)-1);
I1 = I1Org(roirect(2):roirect(2)+roirect(4)-1,roirect(1):roirect(1)+roirect(3)-1); 
mask = mask(roirect(2):roirect(2)+roirect(4)-1,roirect(1):roirect(1)+roirect(3)-1); 

%Typevector matrix -  2D matrix with the same size as x: 1 where data is valid, 0 where a mask is applied
Typevector = ones(size(I0)).*mask;

%create a mesh grid to list where the vectors are placed
RegionX = roirect(1):(roirect(1)+roirect(3)-1);
RegionY = roirect(2):(roirect(2)+roirect(4)-1);
[XGrid,YGrid] = meshgrid(RegionX,RegionY);

% Default median filtering
MedianFilter.Flag = MedFiltFlag;
MedianFilter.Size = MedFiltSize;

% Default iamge filtering when building a pyramid
FiltImg.Flag = true;
FiltImg.Type = 'spline';

% Default initial solution guess
v0=zeros(size(I0,1),size(I0,2),2);

% Cut down size of images if possible based on the mask
[X,Y]=meshgrid(1:size(I0,2),1:size(I0,1));
xlims=[min(nonzeros(Y.*mask)),max(nonzeros(Y.*mask))];
ylims=[min(nonzeros(X.*mask)),max(nonzeros(X.*mask))];

%% Additional options
options.regscheme = 'visc';

%Default coarsest/finest scales
%Default coarsest/finest scales
C=0;
L=log2(M)-1;

%compute number of patches in vert
mx=ceil(size(I0,1)/M);

%Compute overlaps
totolapx=mx*M-size(I0,1);
while totolapx/(mx-1)<max(.15*M,34)
    mx=mx+1;
    totolapx=mx*M-size(I0,1);
end

%compute number of patches in horz
my=ceil(size(I0,2)/M);

%Compute overlaps
totolapy=my*M-size(I0,2);
while totolapy/(my-1)<max(.15*M,34)
    my=my+1;
    totolapy=my*M-size(I0,2);
end

%Set regularization scheme
if ~isfield(options,'regscheme')
    regscheme='visc';
else
    regscheme=options.regscheme;
end

%% patch size compatibility
if diff(xlims)+1<M
    if xlims(1)>size(I0,1)-M+1
        xlims(1)=size(I0,1)-M+1;
        xlims(2)=size(I0,1);
    elseif xlims(2)<M
        xlims(1)=1;
        xlims(2)=M;
    else
        xcent=floor(mean(xlims));
        xlims(1)=xcent-M/2+1;
        xlims(2)=xcent+M/2;
    end

    if ylims(1)>size(I0,2)-M+1
        ylims(1)=size(I0,2)-M+1;
        ylims(2)=size(I0,2);
    elseif ylims(2)<M
        ylims(1)=1;
        ylims(2)=M;
    else
        ycent=floor(mean(ylims));
        ylims(1)=ycent-M/2+1;
        ylims(2)=ycent+M/2;
    end
end

I0=I0(xlims(1):xlims(2),ylims(1):ylims(2));
I1=I1(xlims(1):xlims(2),ylims(1):ylims(2));
mask=mask(xlims(1):xlims(2),ylims(1):ylims(2));
v0=v0(xlims(1):xlims(2),ylims(1):ylims(2),:);


%Arrange sub-domains in row-major order

%Compute overlaps
totolapx=mx*M-size(I0,1);
totolapy=my*M-size(I0,2);

%Issue a warning if the sub-domains don't cover the entire domain
if totolapx<0 || totolapy<0
    error(['Warning: the specified subdomains do not cover the entire'...
        ' domain!'])
end

%As evenly as possible, distribute overlaps. Append a zero at the end of
%the overlap vectors so the loops don't throw a fit when incrementing the
%upper-left corner of each subdomain

switch mx
    case 1
        olapx=0;
    otherwise
        %Issue a warning if windows may not overlap enough
        if totolapx/(mx-1)<max(.15*M,34)
            warning(['Warning: There may not be enough subdomains in '...
                'the x-direction. Artifacts from edges may be visible.'])
        end

        olapx=ones(mx-1,1)*(totolapx-rem(totolapx,mx-1))/(mx-1)+[ones(...
            rem(totolapx,mx-1),1);zeros(mx-1-rem(totolapx,mx-1),1)];

        t1=wOFV.upsample(olapx(1:ceil((mx-1)/2)),2);
        t2=[0;wOFV.upsample(olapx(ceil((mx-1)/2):end),2)];
        olapx=[t1(1:mx-1)+t2(1:mx-1);0];
end
switch my
    case 1
        olapy=0;
    otherwise
        %Issue a warning if windows may not overlap enough
        if totolapy/(my-1)<max(.15*M,34)
            warning(['Warning: There may not be enough subdomains in '...
                'the y-direction. Artifacts from edges may be visible.'])
        end

        olapy=ones(my-1,1)*(totolapy-rem(totolapy,my-1))/(my-1)+[ones(...
            rem(totolapy,my-1),1);zeros(my-1-rem(totolapy,my-1),1)];

        t1=wOFV.upsample(olapy(1:ceil((my-1)/2)),2);
        t2=[0;wOFV.upsample(olapy(ceil((my-1)/2):end),2)];
        olapy=[t1(1:my-1)+t2(1:my-1);0];
end

%Loop through subdomains, performing wOFV for each one
domnum=1;
%Track the upper-left corner
UL=[1,1];

%May as well build the inverse Nuttall window while we're at it, and weight
%and combine v1's from the subdomains. We'll also make a normalization
%matrix to convert a sum to an average.

%Compute 2D Nuttall window of size M^2
windM=wOFV.nuttall(M)*wOFV.nuttall(M)';
invwind=zeros(size(I0));



%% Parallel processing 
%Divide into subdomains that we can feed into the optimizer
I0sub = zeros(M^2,mx*my);
I1sub = I0sub;
varthetaSub = I0sub;
masksub = I0sub;
v0sub = zeros(2*M^2,mx*my);
%assemble the patches in a matrix
for k=1:mx
    UL(2)=1;
    for j=1:my
        I0sub(:,domnum)=reshape(I0(UL(1):UL(1)+M-1,UL(2):UL(2)+M-1),[M^2,1]);
        I1sub(:,domnum)=reshape(I1(UL(1):UL(1)+M-1,UL(2):UL(2)+M-1),[M^2,1]);
        varthetaSub(:,domnum)=reshape(vartheta(UL(1):UL(1)+M-1,UL(2):UL(2)+M-1),[M^2,1]);
        v0sub(:,domnum)=reshape(v0(UL(1):UL(1)+M-1,UL(2):UL(2)+M-1,:),[2*M^2,1]);
        masksub(:,domnum)=reshape(mask(UL(1):UL(1)+M-1,UL(2):UL(2)+M-1),[M^2,1]);

        UL(2)=UL(2)+M-olapy(j);
        domnum=domnum+1;
    end
    UL(1)=UL(1)+M-olapx(k);
end

%Run the parfor loop to compute patches at the same time
v1Patches = zeros(2*M^2,1,mx*my); %create a matrix to store all the velocity patches
alphaPatches = zeros(M^2,1,mx*my); %create a matrix to store all the alphafield patches

parfor domnum = 1:mx*my
    [v1tmp,minOut(domnum),alphatmp]=wOFV.BayesPyd_sub(reshape(I0sub(:,domnum),[M,M]),reshape(I1sub(:,domnum),[M,M]),C,L,eta,reshape(varthetaSub(:,domnum),[M,M]),reshape(v0sub(:,domnum),[M,M,2]),...
        regscheme,reshape(masksub(:,domnum),[M,M]),Fmats,PyramidLevels,MedianFilter,FiltImg);

    v1Patches(:,domnum) = v1tmp(:);
    alphaPatches(:,domnum) = alphatmp(:);
end

clear alphatmp v1tmp

%Stitching the field back together
%Loop through subdomains, stitching them together
v1=zeros(size(v0));
alphafield=zeros(size(I0));
domnum = 1;
%Track the upper-left corner
UL=[1,1];
for k=1:mx
    UL(2)=1;
    for j=1:my
        v1tmp = reshape(v1Patches(:,domnum),[M,M,2]);

        alphafield(UL(1):UL(1)+M-1,UL(2):UL(2)+M-1)=alphafield(UL(1):UL(1)+M-1,...
            UL(2):UL(2)+M-1)+reshape(alphaPatches(:,domnum),[M,M]).*windM;

        for c=1:2
            v1(UL(1):UL(1)+M-1,UL(2):UL(2)+M-1,c)=v1(UL(1):UL(1)+M-1,...
                UL(2):UL(2)+M-1,c)+v1tmp(:,:,c).*windM;
        end

        invwind(UL(1):UL(1)+M-1,UL(2):UL(2)+M-1)=invwind(UL(1):UL(1)+...
            M-1,UL(2):UL(2)+M-1)+windM;

        UL(2)=UL(2)+M-olapy(j);
        domnum = domnum + 1;
    end
    UL(1)=UL(1)+M-olapx(k);
end

%Re-normalize v1 using the inverse of the windows
for c=1:2
    v1(:,:,c)=v1(:,:,c)./invwind;
end

alphafield = alphafield./invwind;

%Restore zeros around the border if parts of the domain were erased prior
%to computation based on the mask
v1=cat(1,zeros(xlims(1)-1,size(v1,2),2),v1,zeros(max(Y(:))-xlims(2),...
    size(v1,2),2));
v1=cat(2,zeros(size(v1,1),ylims(1)-1,2),v1,zeros(size(v1,1),max(X(:))-...
    ylims(2),2));


subOut.M=M;
subOut.mx=mx;
subOut.my=my;

vHorz = v1(:,:,2);
vVert = v1(:,:,1);
