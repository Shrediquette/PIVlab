function [wcoarse,xcoarse,Mcoarse] = MLPTAnalysis(x,y,Moments,ndual,prefiltertype)
%

%   Copyright 2016-2020 The MathWorks, Inc.

NumOdds = length(x);
EvenIdx = 1:2:length(x);
NumEvens = length(EvenIdx);

% Allocate wcoarse -- wcoarse is a vector or matrix
wcoarse = zeros(NumEvens+NumOdds,size(y,2));


% Set the odds to the all of y. MLPT is an overcomplete transform
Odds = y;
xeven = x(EvenIdx);
P = wavelet.internal.MLPTpredict(x,xeven,ndual);

%Update the scaling moments using the initial prediction operator
Mcoarse = P*Moments;

%Prefilter the odds.  
H = wavelet.internal.prefiltermatrix(prefiltertype,x,Moments);


%Pre-filter before subsampling
PreFilteredOdds = H*Odds;
% Subsample
PreFilteredOdds = PreFilteredOdds(EvenIdx,:);
% Find difference between predicted and observed

details = Odds-P'*PreFilteredOdds;
% Apply update operator to evens
% Check whether any of the moment inputs to the update step are not
% finite
if any(~isfinite(Moments(:))) || any(~isfinite(Mcoarse(:)))
    error(message('Wavelet:mlpt:MLPTNotFinite'));
end
U = wavelet.internal.updateoperator(x,xeven,Moments,Mcoarse);
scalingCoefs = PreFilteredOdds + U*details;

% Prepare outputs -- Mcoarse has already been constructed
xcoarse = xeven;
wcoarse(1:NumEvens,:) = scalingCoefs;
wcoarse(NumEvens+1:NumEvens+NumOdds,:) = details;









