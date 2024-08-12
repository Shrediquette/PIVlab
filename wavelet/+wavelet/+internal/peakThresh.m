function DFTKeptBins = peakThresh(x,BW,alpha,tflog)
% This function is for internal use only. It may change or be removed in a
% future release
% DFTKeptBins = peakThresh(x,f,BW,alpha,tflog)

% Copyright 2020 The MathWorks, Inc.

%#codegen
DFTBins = cast(1:length(x),'like',x);
DFTBins = DFTBins(:);
if tflog
    TF = islocalmax(log(x),'MinSeparation',BW);
else
    TF = islocalmax(x,'MinSeparation',BW);
end
pkst = x(TF);
if isempty(pkst)
    DFTKeptBins = cast([],'like',x);
    
else
    DFTBinPKS = DFTBins(TF);
    % Normalize to lie in [0,1]
    pkst = pkst./max(pkst);
    % Locations in frequency.
    [sortpks,sortlocs] = sort(pkst,'descend');
    DFTBinPKS = DFTBinPKS(sortlocs);
    MaxPeak = sortpks(1);
    % Choose peak by proportion of maximum peak
    thresh = alpha*MaxPeak;
    IKeptPKS = sortpks > thresh;
    DFTKeptBins = sort(DFTBinPKS(IKeptPKS));
end







