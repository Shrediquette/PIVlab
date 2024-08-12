function [thr,sorh,keepapp,crit] = ddencmp(dorc,worwp,x)
%DDENCMP Default values for de-noising or compression.
%   [THR,SORH,KEEPAPP,CRIT] = DDENCMP(IN1,IN2,X)
%   returns default values for de-noising or compression,
%   using wavelets or wavelet packets, of an input vector
%   or matrix X which can be a 1-D or 2-D signal.
%   THR is the threshold, SORH is for soft or hard
%   thresholding, KEEPAPP allows you to keep approximation
%   coefficients, and CRIT (used only for wavelet packets)
%   is the entropy name (see WENTROPY).
%   IN1 is 'den' or'cmp' and IN2 is 'wv' or 'wp'.
%
%   For wavelets (three output arguments):
%   [THR,SORH,KEEPAPP] = DDENCMP(IN1,'wv',X) 
%   returns default values for de-noising (if IN1 = 'den')
%   or compression (if IN1 = 'cmp') of X.
%   These values can be used for WDENCMP.
%
%   For wavelet packets (four output arguments):
%   [THR,SORH,KEEPAPP,CRIT] = DDENCMP(IN1,'wp',X) 
%   returns default values for de-noising (if IN1 = 'den')
%   or compression (if IN1 = 'cmp') of X.
%   These values can be used for WPDENCMP.
%
%   See also WDENCMP, WENTROPY, WPDENCMP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if nargin > 0
    dorc = convertStringsToChars(dorc);
end

if nargin > 1
    worwp = convertStringsToChars(worwp);
end

nbIn = nargin;
if nbIn<3
    error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
elseif isequal(worwp,'wv')
    if (nargout>3)
        error(message('Wavelet:FunctionOutput:TooMany_ArgNum'));
    end
elseif isequal(worwp,'wp')
    if (nargout>4)
        error(message('Wavelet:FunctionOutput:TooMany_ArgNum'));
    end
else
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end


% Set problem dimension.
if min(size(x))~=1, dim = 2; else dim = 1; end

% Set keepapp default value.
keepapp = 1;

% Set sorh default value.
if isequal(dorc,'den') && isequal(worwp,'wv')
    sorh = 's'; 
else
    sorh = 'h'; 
end

% Set threshold default value.
n = numel(x);

% nominal threshold.
switch dorc
  case 'den'
    switch worwp
      case 'wv' , thr = sqrt(2*log(n));               % wavelets.
      case 'wp' , thr = sqrt(2*log(n*log(n)/log(2))); % wavelet packets.
    end

  case 'cmp' ,  thr = 1;
end

% rescaled threshold.
if dim == 1
    [c,l] = wavedec(x,1,'db1');
    c = c(l(1)+1:end);
else
    [c,l] = wavedec2(x,1,'db1');
    c = c(prod(l(1,:))+1:end);
end

normaliz = median(abs(c));

% if normaliz=0 in compression, kill the lowest coefs.
if strcmp(dorc,'cmp') && normaliz == 0 
    normaliz = 0.05*max(abs(c)); 
end

if strcmp(dorc,'den')
    if strcmp(worwp,'wv')
        thr = thr*normaliz/0.6745;
    else
        crit = 'sure';
    end
else
    thr = thr*normaliz;
    if strcmp(worwp,'wp'), crit = 'threshold'; end
end
