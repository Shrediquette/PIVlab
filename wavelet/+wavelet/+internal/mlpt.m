function [w,t,nj,scalingMoments] = mlpt(x,t,L,nd,np,prefilter)
% This is an internal version of MLPT. This is to avoid unnecessary
% double validation and parsing of inputs. 
% This is not intended to be called directly, use MLPT instead.
% This function may change in a future release.

%   Copyright 2016-2020 The MathWorks, Inc.

% Get the scaling moments
M = wavelet.internal.scalingMoments(t,0:np-1);

% In the MLPT, we use the entire signal as the odds, this is different
% than usual lifting where we try to predict just half the samples

% Preparing to enter decomposition loop
wfine = x;
tfine = t;
nj = zeros(L,1);
w = [];
scalingMoments = M;

for jj = 1:L
    
    
    [wcoarse,tcoarse,Mcoarse] = ...
        wavelet.internal.MLPTAnalysis(tfine,wfine,M,nd,prefilter);
    Neven = length(tcoarse);
    Nodd = size(wcoarse,1)-Neven;
    nj(L-jj+1) = Nodd;
    w = [wcoarse(Neven+1:Neven+Nodd,:) ; w];
    % Iterate on the scaling coefficients
    wfine = wcoarse(1:Neven,:);
    tfine = tcoarse;
    scalingMoments = [Mcoarse ; scalingMoments];
    M = Mcoarse;
    
    
end

w = [wfine ; w];
nj = [Neven ; nj];


















