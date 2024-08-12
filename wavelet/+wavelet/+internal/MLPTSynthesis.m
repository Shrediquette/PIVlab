function sj = MLPTSynthesis(tfine,tcoarse,wcoarse,scoarse,Mfine,Mcoarse,ndual) %#ok<INUSL>
%

%   Copyright 2016-2020 The MathWorks, Inc.

EvenIdx = 1:2:length(tfine);
NumEvens = length(EvenIdx);
NumOdds = length(tfine);
% Initialize sparse identity matrix NumEvens x NumEvens
V = sparse(eye(NumEvens));

% Allocate wcoarse -- wcoarse is a vector or matrix
wfine = zeros(NumEvens+NumOdds,size(wcoarse,2));


% Set the odds to the all of wcoarse. MLPT is an overcomplete transform
Odds = wcoarse;
xeven = tfine(EvenIdx);
x = tfine;
yEvens = scoarse;
NumOdds = size(wcoarse,1);
P = wavelet.internal.MLPTpredict(x,xeven,ndual);
%Update the scaling moments using the initial prediction operator
Mcoarse = P*Mfine;


% Apply update operator to evens
U = wavelet.internal.updateoperator(x,xeven,Mfine,Mcoarse);
% Start reversing the lifting
scalingCoefs = scoarse - U*Odds;
wcoarse(EvenIdx,:) = scalingCoefs;
wcoarse = Odds+P'*wcoarse(EvenIdx,:);
sj = wcoarse;



