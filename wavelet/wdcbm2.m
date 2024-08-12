function [thr,nkeep] = wdcbm2(c,s,alpha,m)
%WDCBM2 Thresholds for wavelet 2-D using Birge-Massart strategy.
%   [THR,NKEEP] = WDCBM2(C,S,ALPHA,M) returns level-dependent 
%   thresholds THR and numbers of coefficients to be kept NKEEP,
%   for de-noising or compression. THR is obtained using a wavelet 
%   coefficients selection rule based on Birge-Massart strategy.
%
%   [C,S] is the wavelet decomposition structure of the image
%   to be denoised or compressed, at level j = size(S,1)-2.
%   ALPHA and M must be real numbers greater than 1.  
%
%   THR is a matrix 3 by j, THR(:,i) contains the level
%   dependent thresholds in the three orientations
%   horizontal, diagonal and vertical, for level i.
%   NKEEP is a vector of length j, NKEEP(i) 
%   contains the number of coefficients to be kept at level i. 
%
%   j, M and ALPHA define the strategy:
%   - at level j+1 (and coarser levels), everything is kept.
%   - for level i from 1 to j, the n_i largest coefficients
%   are kept with n_i = M/(j+2-i)^ALPHA. 
%
%   Typically ALPHA = 1.5 for compression and ALPHA = 3 for de-noising.
%   A default value for M is M = prod(S(1,:)) the number of 
%   the coarsest approximation coefficients, since the previous 
%   formula leads for i = j+1, to n_(j+1) = M = prod(S(1,:)).
%   Recommended values for M are from prod(S(1,:)) to 6*prod(S(1,:)).
%
%   WDCBM2(C,S,ALPHA) is equivalent to WDCBM2(C,S,ALPHA,PROD(S(1,:))). 
%
%   See also WDENCMP, WPDENCMP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 25-Apr-98.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
nbIn = nargin;
if nbIn < 3
    error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
end
if errargt(mfilename,alpha-1,'rep')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
if nbIn==4
    if errargt(mfilename,m-1,'rep')
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
    end
else
    m = prod(s(1,:));
end
m = max(m,1);
J = size(s,1)-2;   % low frequency cutoff. 
thr = zeros(3,J);  
nkeep = zeros(1,J);  

% Wavelet coefficients selection.
for j=1:J
    % number of coefs to be kept.
    n = m/(J+2-j)^alpha;   
    n = min(round(n),prod(s(J-j+2,:)));
    % thresholds.
    if n == prod(s(J-j+2,:))
        thr(:,j) = zeros(3,1);
    else
        d = detcoef2('compact',c,s,j);
        d = sort(abs(d));
        thr(:,j) = ones(3,1)*d(end-n);
    end
    nkeep(j) = n;
end
if size(s,2)>2  % for true color images.
    nkeep = 3*nkeep;
end
