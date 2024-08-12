function [bw, flo, fhi, pwr] = obw(x, fs, P)
% This function is for internal use only and may be removed in a future 
% release.

%   Copyright 2018-2020 The MathWorks, Inc.

narginchk(2,3);

%Compute PSD
[Pxx, F] = computepsd(x,fs);

% use full range
Frange = [F(1) F(end)];

% check if a percentage is specified
if nargin < 3
    P = 99;
else
    validateattributes(P,{'numeric'},{'real','positive','scalar','<',100});
end

% compute the median frequency and power within the specified range
[bw,flo,fhi,pwr] = signalwavelet.internal.computeOBW(Pxx, F, Frange, P);


function [Pxx, F] = computepsd(x,fs)


if isvector(x)
    % force column vector
    x = x(:);
end

validateattributes(x,{'numeric'},{'2d','finite'});
validateattributes(fs, {'numeric'},{'real','finite','scalar','positive'});

n = size(x,1);

% Take the onesided DFT, then convert to PSD

Sxx2 = fft(x);
inds = 1:(floor(n/2)+1);
Sxx2 = Sxx2(inds,:);
Pxx = wavelet.internal.psdfrommag(Sxx2,fs,1,n);
F = psdfreqvec('npts',n,'Fs',fs);
F = F(inds);

