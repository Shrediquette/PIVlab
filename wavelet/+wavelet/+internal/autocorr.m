function [acf,lags,acffbounds,pacf,pacfbounds] = autocorr(y,NVargs)
% This function is for internal use only. It may change or be removed in a
% future release.
%
%   %Example: Show case whitening property of wavelet coefficients.
%   load kobe
%   [C,L] = wavedec(kobe,4,'coif4');
%   % MA order 
%   numMA = 5;
%   D1 = detcoef(C,L,1);
%   [acf,lags,confbounds] = wavelet.internal.autocorr(D1,"NumMA",numMA,...
%       "NumLags",50);
%   numLags = numel(lags);
%   ax = newplot;
%   hPlot = stem(ax,lags,acf,'filled','r-o','MarkerSize',4,'Tag','ACF');
%   set(ax,'NextPlot','add');
%   hBounds = plot(ax,[numMA+0.5 numMA+0.5; numLags numLags],...
%                       [confbounds([1 1]) confbounds([2 2])],'-b',...
%                       'Tag','Confidence Bound');
%   xlim([0 numLags])
%   grid on

% Copyright,2022 The MathWorks, Inc.

arguments
    y {mustBeNumeric} = []
    NVargs.NumLags {mustBeScalarOrEmpty} = 20
    NVargs.NumMA {mustBeScalarOrEmpty} = 0
    NVargs.NumSTD {mustBeScalarOrEmpty} = 2

end
numMA = NVargs.NumMA;
numSTD = NVargs.NumSTD;
IsReal = isreal(y);
numLags = NVargs.NumLags;
y = y(:);
y = y - mean(y,"omitnan");
% Effective sample size
N = sum(~isnan(y));
numLags = min(N-1,numLags);
nFFT = 2^(nextpow2(length(y))+1);
F = fft(y,nFFT);
F = F.*conj(F);
if IsReal
    acf = ifft(F,'symmetric');
    acf = acf(1:numLags+1);
    acf = acf./acf(1);
    lags = (0:numLags)';
else
    acf = ifft(F);
    acf = acf./acf(1);
    acf = [acf(nFFT/2+2:nFFT/2+1+numLags) ; acf(1:numLags)];
    lags = -numLags:numLags;

end

sigmaNMA = sqrt((1+2*(acf(2:numMA+1)'*acf(2:numMA+1)))/N);
acffbounds = sigmaNMA*[numSTD; -numSTD];

% PACF
pacf = [1;zeros(numLags,1)];
for L = 1:numLags
    AR        = toeplitz(acf(1:L))\acf(2:(L+1));
    pacf(L+1) = AR(end);
end
pacfbounds = [numSTD;-numSTD]./sqrt(N);





