function [v1,output,alpha]=BayesPyd_sub(I0Org,I1Org,C,LOrg,eta,varthetaOrg,v0,regscheme,maskOrg,Fmats,PyramidLevels,MedianFilter,FiltImg)

%Wavelet optical flow function, inputs are I0 and I1 to be analyzed for
%velocimetry. Output is v1, the estimated velocity field. C and L are the
%coarsest and finest scales solved, respectively. Lambda is the strength of
%the regularization term. v0 is the initial guess of the velocity field
%(typically an average velocity). The function uses a separable wavelet
%transform with symmetric biorthogonal wavelets implemented with matrix
%multiplication. The regularization is performed using continuous
%approximation (via Derian) according to the scheme specified by regscheme.
%Choices are:
%'HS': Horn and Schunck (1st order)
%'2Tik': 2nd order Tikhonov
%'lap': Laplacian of u and v
%'divcurl': Gradient of divergence and curl (Corpetti 2002)
%'visc' (default): regularization enters as viscosity in N-S equations


FmatPy = Fmats.FmatPy;
DmatPy = Fmats.DmatPy;
NiPy = Fmats.NiPy;

% Need it for initialization
v1 = v0;

minOptions.DISPLAY='off';
minOptions.DERIVATIVECHECK='off';
minOptions.METHOD='lbfgs';
minOptions.MAXITER=100;
minOptions.MAXFUNEVALS=300;
minOptions.Corr=8;
minOptions.progTol=1e-5;
minOptions.optTol=1e-5;
minOptions.LS_type=0;
minOptions.useMex=0;

%% Generate the Image Pyramid
ImPy0 = wOFV.GenerateImPyramid(I0Org,PyramidLevels,FiltImg);
ImPy1 = wOFV.GenerateImPyramid(I1Org,PyramidLevels,FiltImg);
MaskPy = wOFV.GenerateImPyramid(maskOrg,PyramidLevels,FiltImg);
VarThetaPy = wOFV.GenerateImPyramid(varthetaOrg,PyramidLevels,FiltImg);


%% Loop over the pyramids
for Level = PyramidLevels:-1:1
%     disp(['Pyramid Level: ' num2str(Level) ' out of ' num2str(PyramidLevels)])
    % Switch the image, transform and the finite difference matrices according to the
    % pyramid level
    Fmat = FmatPy{Level};
    Fw = Fmat(:,:,1); FwInv = Fmat(:,:,2);
    Ni = NiPy{Level};
    Dmat = DmatPy{Level};
    I0 = ImPy0{Level};
    I1 = ImPy1{Level};
    vartheta = VarThetaPy{Level};
    mask = MaskPy{Level};
    n=size(I0,1);
    sz = size(I0);

    %Create a gridded interpolant object for I1
    [X1,Y1]=ndgrid(1:n+1,1:n+1);
    %Extend I1 by one pixel (using symmetric BC) to avoid boundary issues
    I1=[I1,I1(:,end)]';
    I1=[I1,I1(:,end)]';
    I1int=griddedInterpolant(X1,Y1,I1,'spline');

    %Create a gridded interpolant object for I0
    [X1,Y1]=ndgrid(1:n+1,1:n+1);
    %Extend I1 by one pixel (using symmetric BC) to avoid boundary issues
    I0=[I0,I0(:,end)]';
    I0=[I0,I0(:,end)]';
    I0int=griddedInterpolant(X1,Y1,I0,'spline');

    %resample the flow field
    v0 = cat(3,imresize(v1(:,:,1),sz,'bilinear'),imresize(v1(:,:,2),sz,'bilinear'))*sz(1)/size(v1,1);
    %Initialize wavelet transform of velocity field
    Theta=cat(3,wOFV.Psitrunc_mat(v0(:,:,1),Fw(1:2^C,:)),wOFV.Psitrunc_mat(v0(:,:,2),...
        Fw(1:2^C,:)));

    %Initialize grid to use with the warping function
    [Grid.n,Grid.m] = size(v0(:,:,1));
    [Grid.X,Grid.Y] = meshgrid(1:Grid.n,1:Grid.m); Grid.X=Grid.X';Grid.Y=Grid.Y'; Grid.n=Grid.n+1; Grid.m = Grid.m+1;

    %Finest scale
    if PyramidLevels ~= 1
        L = log2(n) - 1;
    else
        L = LOrg;
    end

    %Loop over scales
    for scale=C:L
        Theta=Theta(:);

        %Call WOF caller function to establish persistent variables
        wOFV.call_Bayes(Theta,I0int,I1int,scale,eta,vartheta,Fw(1:2^scale,:),FwInv(:,...
            1:2^scale),Ni(1:2^scale,1:2^scale,:),regscheme,Dmat,mask,Grid);

        %Use l-BFGS algorithm via function minFunc

        %Citation for minFunc: M. Schmidt. minFunc: unconstrained
        %differentiable multivariate optimization in Matlab.
        %http://www.cs.ubc.ca/~schmidtm/Software/minFunc.html, 2005.

        [Theta,~,~,output]=minFunc(@wOFV.call_Bayes,Theta,minOptions);

        Theta=reshape(Theta,[2^scale,2^scale,2]);

        Theta=cat(1,cat(2,Theta,zeros(2^scale,2^scale,2)),zeros(2^scale,2^(...
            scale+1),2));
    end

    if 2^L<n
        v1=cat(3,wOFV.Psitrunc_mat(Theta(:,:,1),FwInv(:,1:2^(L+1))).*mask,...
            wOFV.Psitrunc_mat(Theta(:,:,2),FwInv(:,1:2^(L+1))).*mask);
    else
        Theta=Theta(1:n,1:n,:);

        v1=cat(3,wOFV.Psitrunc_mat(Theta(:,:,1),FwInv).*mask,wOFV.Psitrunc_mat(Theta(...
            :,:,2),FwInv).*mask);
    end
    %apply median filter to the solution
    if (MedianFilter.Flag == true)
        v1 = cat(3,medfilt2(v1(:,:,1),MedianFilter.Size,'symmetric'),medfilt2(v1(:,:,2),MedianFilter.Size,'symmetric'));
    end

    C = L; %set next C to L of the previos solution

end
%evaluate the alpha field to return it back
alpha = wOFV.getalphafield(I0int,I1int,v1,mask,eta,vartheta,Grid);

