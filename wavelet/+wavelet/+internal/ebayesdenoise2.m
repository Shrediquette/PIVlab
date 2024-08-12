function [imden,denoisedcfs,origcfs,S] = ebayesdenoise2(x,Lo_D,Hi_D,Lo_R,Hi_R,level,noiseestimate,threshold,noisedir,ns)
%   This function is for internal use only. It may change or be removed 
%   in a future release.

%   Copyright 2018-2020 The MathWorks, Inc.

%#codegen

% If using cycle spinning, obtain the shifts
if ns ~= 0
    shifts = wavelet.internal.getCycleSpinShifts2(ns);
% If not using cycle spinning, shift vector is [0 0 0]'
else
    shifts = [0 ; 0 ; 0];
end

% Total number of shifts
N = size(shifts,2);
imden = zeros(size(x));
denoisedcfs = [];
origcfs = [];

if ~isempty(coder.target)
    coder.varsize('denoisedcfs',Inf(1,2));
    coder.varsize('origcfs',Inf(1,2));
    vscale = 0;
    temp = zeros(N+2,2);
end

for nt = 1:N
    % Shift the image if using cycle spinning
    imcs = circshift(x,shifts(:,nt));
    [C,tempS] = wavedec2(imcs,level,Lo_D,Hi_D);
    wthr = C;
    % Finest-scale coefficients with given noise direction
    d1 = wavelet.internal.getdetcoef2(wthr,tempS,noisedir,1);
    if strcmpi(noiseestimate,'levelindependent')
        normfac = 1/(-sqrt(2)*erfcinv(2*0.75));
        vscale = normfac*median(abs(d1));
    end

    for lev = 1:level
        Idx = wavelet.internal.getLevelIndices(tempS,lev);
        cfs = wthr(Idx)';
        if strcmpi(noiseestimate,'leveldependent')
            wthr(Idx) = wavelet.internal.ebayesthresh(cfs,'leveldependent',threshold,'decimated');
        elseif strcmpi(noiseestimate,'levelindependent')
            wthr(Idx) = wavelet.internal.ebayesthresh(cfs,vscale,threshold,'decimated');
        end
    end
    
    imcurr = waverec2(wthr,tempS,Lo_R,Hi_R);
    % Shift the reconstructed image back
    imcurr = circshift(imcurr,-shifts(:,nt));
    imden =  imden*(nt-1)/nt + imcurr/nt;
    denoisedcfs = [denoisedcfs;wthr]; %#ok<AGROW>
    origcfs = [origcfs;C]; %#ok<AGROW>
    if nt == N
        temp = tempS;
    end
end
S = temp;
