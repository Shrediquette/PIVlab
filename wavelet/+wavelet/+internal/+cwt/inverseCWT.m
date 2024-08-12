function [xrec,dw] = inverseCWT(cfs,sigtype,params)
% This function is for internal use only. It may change or be removed in a
% future release.
%
% [xrec,fb,rankS] = inverseCWT(cfs,scalcfs,afb)

%   Copyright 2017-2021 The MathWorks, Inc.
%#codegen
DataType = underlyingType(cfs);
afb = cast(params.AnalysisFilters,DataType);
% Needed for code generation
if isempty(afb)
    xrec = zeros(0,0,DataType);
    dw = zeros(0,0,DataType);
    return;
end
Nt = size(afb,2);
if ~isempty(params.LPcfs)
    scalcfs = params.LPcfs;
else
    scalcfs = zeros(1,Nt,'like',cfs);
end

Na = size(afb,1);
phif = afb(Na,:);
psif = afb(1:Na-1,:);

if startsWith(sigtype,'r')
    isReal = true;
else
    isReal = false;
end

if ~isempty(params.f)
    coder.internal.errorIf(~isvector(params.f),'Wavelet:cwt:InvalidFreqPeriodInput');
    if isReal
        idxZeroPos = wavelet.internal.cwt.findFreqIndices(Na,params.f,params.freqrange,true);
        cfs(idxZeroPos,:,:) = cast(0.0,'like',cfs);
    else
        [idxZeroPos,idxZeroNeg] = wavelet.internal.cwt.findFreqIndices(Na,params.f,params.freqrange,false);
        cfs(idxZeroPos,:,1) = cast(0.0,'like',cfs);
        cfs(idxZeroNeg,:,2) = cast(0.0,'like',cfs);
    end

elseif ~isempty(params.periods)

    coder.internal.errorIf(~isvector(params.periods),'Wavelet:cwt:InvalidFreqPeriodInput');
    
    if isReal
        idxZeroPos = wavelet.internal.cwt.findPeriodIndices(Na,params.periods,params.periodrange,true);
        cfs(idxZeroPos,:) = cast(0.0,'like',cfs);
    else
        [idxZeroPos,idxZeroNeg] = wavelet.internal.cwt.findPeriodIndices(Na,params.periods,params.periodrange,false);
        cfs(idxZeroPos,:) = cast(0.0,'like',cfs);
        cfs(idxZeroNeg,:) = cast(0.0,'like',cfs);
    end

end

if startsWith(sigtype,'r')
    isReal = true;
    cfsN = cat(1,cfs,scalcfs);    
else    
    cfs = 2*cfs;
    cfsN = cat(1,scalcfs,flip(cfs(:,:,1),1),cfs(:,:,2));
end

if isReal 
   ufbf = cat(1,psif,phif);
else
    phif = phif+wavelet.internal.cwt.involution(phif);
    psiftilde = wavelet.internal.cwt.involution(psif);
    ufbf = cat(1,phif,flip(psif,1),psiftilde);    
end


dw = dualweights(ufbf,isReal);
if isReal
    Fk = 2*ufbf./dw;
else
   Fk = ufbf./dw; 
end

cfsDFT = fft(cfsN,[],2);
xdft = cfsDFT.*Fk;
xrec = ifft(xdft,[],2);
if isReal
    xrec = real(sum(xrec));
else
    xrec = sum(xrec); 
end


function dw = dualweights(ufbf,isReal)
Ns = size(ufbf,1);
if isReal
    gf = ufbf(1,:).*ufbf(1,:);
else
    gf = ufbf(1,:);
end

for ii = 2:Ns
    gf = gf+ufbf(ii,:).*ufbf(ii,:);
end
if isReal
    dw = gf+wavelet.internal.cwt.involution(gf);
else
    dw = gf;
end





