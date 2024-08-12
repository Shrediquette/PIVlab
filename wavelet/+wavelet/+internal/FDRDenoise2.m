function [imden,denoisedcfs,origcfs,S] = FDRDenoise2(im,Lo_D,Hi_D,Lo_R,Hi_R,level,...
    qvalue,noiseestimate,noisedir,ns)
%   This function is for internal use only. It may change or be removed in a
%   future release.
%   [imden,denoisedcfs,origcfs] = wavelet.internal.FDRDenoise2(im,wname,level,...
%        params.NoiseEstimate,noisedir,Ns);

%   Copyright 2018-2020 The MathWorks, Inc.
%#codegen

imden = zeros(size(im));
sigma = [];
normfac = 1/(-sqrt(2)*erfcinv(2*0.75));
if ns ~= 0
    shifts = wavelet.internal.getCycleSpinShifts2(ns);
else
    shifts = [0 ; 0 ; 0];
end
N = size(shifts,2);
denoisedcfs = [];
origcfs = [];
if ~isempty(coder.target)
    coder.varsize('denoisedcfs',Inf(1,2));
    coder.varsize('origcfs',Inf(1,2));
    S = zeros(N+2,2);
end

 for nt = 1:N
    % Shift image
    imcs = circshift(im,shifts(:,nt));
    % Obtain wavelet transform
    [C,temp] = wavedec2(imcs,level,Lo_D,Hi_D);
    if strcmpi(noiseestimate,'levelindependent')
        d1 = wavelet.internal.getdetcoef2(C,temp,noisedir,1);
        sigma = normfac*median(abs(d1-median(d1)));
    elseif strcmpi(noiseestimate,'leveldependent')
        sigma = [];
    end
    Cden = wavelet.internal.fdrthreshcfs2(C,temp,qvalue,sigma,noisedir);
    imcurr = waverec2(Cden,temp,Lo_R,Hi_R);
    imcurr = circshift(imcurr,-shifts(:,nt));
    imden =  imden*(nt-1)/nt + imcurr/nt;
    denoisedcfs = [denoisedcfs;Cden]; %#ok<AGROW>
    origcfs = [origcfs;C]; %#ok<AGROW>  
    if nt == N
        S = temp;
    end
end
