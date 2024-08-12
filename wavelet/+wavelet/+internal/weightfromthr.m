function weight = weightfromthr(thr)
% This is an internal function and may change in a future release.
% This routine attempts to find the value of the mixing weight for which
% the threshold is equal to the universal threshold.
% Note we use the usual \sqrt{2\ln{N}} for the decimated wavelet transform
% and make an adjustment to \sqrt(2\ln{(N\log_2{N})} for an undecimated 
% transform. The value \sqrt{2\ln{N}} is standard for the
% critically-sampled wavelet transform.
% In terms of searching for the estimated mixing weight in the maximization
% of the marginal log-likelihood, we can updated the lower bound from
% [0,1] to [w_{lo},1]. 
% For the quasi-cauchy prior supported here.
% For a given threshold, we can solve this exactly as
% -\Phi(t)+t\phi(t)+1/2+[1/2t^2e^{-t^2/2}(1/w-1)] = 0
% Where \Phi(t) is the N(0,1) CDF and \phi(t) is the N(0,1) density.
% thr is a scalar input, it depends only on the column dimension of the
% input

%   Copyright 2016-2020 The MathWorks, Inc.

%#codegen 
fx = wavelet.internal.gausspdf(thr,0,1);
Fx = wavelet.internal.gausscdf(thr,0,1,'lower');
weight = 1 + (Fx - thr.*fx - 1/2)./(sqrt(pi/2)*fx.*thr.^2);
% The following line just guards against the edge case of N=1, in which case the mixing
% weight will just be 1. So we simply set the weight to 1.
weight(~isfinite(weight)) = 1;
weight = 1./weight;


