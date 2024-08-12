function DFTKeptBins = maxnumpeaks(x,N,BW,tflog)  
% This function is for internal use only. It may change or be removed in a
% future release.
% DFTKeptBins = maxnumpeaks(x,N,BW,tflog)  

% Copyright 2020 The MathWorks, Inc.

%#codegen
Npad = length(x);
% For MATLAB coder
DFTKeptBins = cast((1:Npad)','like',x);
if tflog
    TF = islocalmax(log(x),'MinSeparation',BW);
else
    TF = islocalmax(x,'MinSeparation',BW);
end
keptbins = DFTKeptBins(TF);
pks = x(TF);
if isempty(pks)
    DFTKeptBins = cast([],'like',x);
else
    [~,idx] = sort(pks,'descend');
    % For MATLAB coder
    idx = cast(idx,'like',x);
    % Adjust N if necessary
    N = min(N,length(idx));
    keptidx = idx(1:N);
    DFTKeptBins = sort(DFTKeptBins(keptbins(keptidx)));
end
