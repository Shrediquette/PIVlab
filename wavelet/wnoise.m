function [x,xn] = wnoise(num,n,sqrtSNR,init)
%WNOISE Generate noisy wavelet test data.
%   X = WNOISE(FUN,N) returns values of the test function
%   given by FUN, on a 2^N sample of [0,1].
%
%   [X,XN] = WNOISE(FUN,N,SQRT_SNR) returns the previous vector X
%   rescaled such that std(x) = SQRT_SNR. The returned vector XN
%   contains the same test vector X corrupted by an
%   additive Gaussian white noise N(0,1). Then XN has a
%   signal-to-noise ratio of (SQRT_SNR^2).
%
%   [X,XN] = WNOISE(FUN,N,SQRT_SNR,INIT) returns previous
%   vectors X and XN, but the generator seed is set to INIT
%   value.
%
%   The six functions below are based on: D. Donoho and I. Johnstone
%   in "Adapting to Unknown Smoothness via Wavelet Shrinkage"
%   Preprint Stanford, January 93, p 27-28.
%   FUN = 1 or FUN = 'blocks'
%   FUN = 2 or FUN = 'bumps'
%   FUN = 3 or FUN = 'heavy sine'
%   FUN = 4 or FUN = 'doppler'
%   FUN = 5 or FUN = 'quadchirp'
%   FUN = 6 or FUN = 'mishmash'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

nbIn = nargin;
narginchk(2,4)
% Convert string to char array
if isStringScalar(num)
    num = convertStringsToChars(num);
end

if nbIn==2 && nargout>1
    error(message('Wavelet:FunctionOutput:TooMany_ArgNum'));
end

t = [0.1  0.13  0.15  0.23  0.25  0.40  0.44  0.65  0.76  0.78  0.81];
h = [4      -5     3    -4     5  -4.2   2.1   4.3  -3.1   5.1  -4.2];

len = 2^n;
switch num
    case {1,'blocks'}       % blocks.
        tt = linspace(0,1,len);  x = zeros(1,len);
        for j=1:11
            x = x + ( h(j)*(1+sign(tt-t(j)))/2 );
        end
        
    case {2,'bumps'}        % bumps.
        h  = abs(h);
        w  = 0.01*[0.5 0.5 0.6 1 1 3 1 1 0.5 0.8 0.5];
        tt = linspace(0,1,len);  x = zeros(1,len);
        for j=1:11
            x = x + ( h(j) ./ (1+ ((tt-t(j))/w(j)).^4));
        end
        
    case {3,'heavy sine'}   % heavy sine.
        x = linspace(0,1,len);
        x = 4*sin(4*pi*x) - sign(x-0.3) - sign(0.72-x);
        
    case {4,'doppler'}      % doppler.
        x = linspace(0,1,len);
        epsil = 0.05;
        x = sqrt(x.*(1-x)) .* sin( 2*pi*(1+epsil) ./ (x+epsil) );
        
    case {5,'quadchirp'}    % quadchirp.
        t = linspace(0,1,len);
        x = sin( (pi/3) * t .* (len * t.^2) );
        
    case {6,'mishmash'}     % mishmash.
        t = linspace(0,1,len);
        x = sin( (pi/3) * t .* (len * t.^2) );
        x = x + sin( pi * (len * 0.6902) * t );
        x = x + sin( pi * t .* (len * 0.125 * t) );
        
    otherwise
        errargt(mfilename, ...
            getWavMSG('Wavelet:FunctionArgVal:Invalid_ArgVal'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

if nargin>=3
    x = (x * (sqrtSNR/std(x)));
    if nargin==4
        validateattributes(init,{'numeric'},{'nonnegative','integer','scalar'});
        rng(init);
        
    end
    wn = randn(1,len);
    xn = x + wn;
end
