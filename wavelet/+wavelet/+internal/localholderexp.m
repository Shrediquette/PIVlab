function [hexp,samp] = localholderexp(chainNum,chains,wt,wavscales)
%Local Holder Exponent using WTMM
% [HEXP,SAMP] = LOCALHOLDEREXP(LINENUM,MAXIMALINES,WT,WAVSCALES) returns an
% estimate of the Holder exponent HEXP for the wavelet maxima line
% specified by LINENUM. LINENUM is a positive integer between 1 and the
% number of elements of the cell array, MAXIMALINES. The Holder exponent is
% calculated by fitting a robust regression model to the log of the
% absolute value of the CWT coefficients obtained from the time-scale
% indices of the  maxima line. SAMP is the position where the maxima line
% converges at the finest scale.
%
% [HEXP,SAMP,HEXPCI] = LOCALHOLDEREXP(...) returns an approximate 95%
% confidence interval for the local Holder exponent.

%   Copyright 2016-2020 The MathWorks, Inc.

wt = flipud(wt);
abswtlog2 = log2(abs(wt'));
chain = chains{chainNum};
amp = zeros(size(chain,1),1);
for kk = 1:numel(chain(:,1))
    amp(kk) = abswtlog2(chain(kk,2),chain(kk,1));
end
scales = flipud(chain(:,1));
scales = log2(wavscales(scales));
scales = scales(:);
maximalines = [scales amp];
amp = amp(:);
hexp = wavelet.internal.bisquareregress(scales,amp);
hexp = hexp(2);
samp = chain(end,2);
















