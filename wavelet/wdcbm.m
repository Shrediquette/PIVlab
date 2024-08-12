function [thr,nkeep] = wdcbm(c,l,alpha,m)
%WDCBM Thresholds for wavelet 1-D using Birge-Massart strategy.
%   [THR,NKEEP] = WDCBM(C,L,ALPHA,M) returns level-dependent 
%   thresholds THR and numbers of coefficients to be kept NKEEP,
%   for de-noising or compression. THR is obtained using a wavelet 
%   coefficients selection rule based on Birge-Massart strategy.
%
%   [C,L] is the wavelet decomposition structure of the signal
%   to be de-noised or compressed, at level j = length(L)-2.
%   ALPHA and M must be real numbers greater than 1.  
%
%   THR is a vector of length j, THR(i) contains the 
%   threshold for level i.
%   NKEEP is a vector of length j, NKEEP(i) 
%   contains the number of coefficients to be kept at level i.
%
%   j, M and ALPHA define the strategy:
%   - at level j+1 (and coarser levels), everything is kept.
%   - for level i from 1 to j, the n_i largest coefficients
%   are kept with n_i = M/(j+2-i)^ALPHA. 
%
%   Typically ALPHA = 1.5 for compression and ALPHA = 3 for de-noising.
%   A default value for M is M = L(1) the number of the coarsest 
%   approximation coefficients, since the previous formula leads
%   for i = j+1, to n_(j+1) = M = L(1). 
%   Recommended values for M are from L(1) to 2*L(1).
%
%   WDCBM(C,L,ALPHA) is equivalent to WDCBM(C,L,ALPHA,L(1)). 
%   
%   See also WDEN, WDENCMP, WPDENCMP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 06-Feb-2011.
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
    m = l(1);
end
m = max(m,1);
J = length(l)-2;   % low frequency cutoff. 
thr = zeros(1,J);  
nkeep = zeros(1,J);

% Wavelet coefficients selection.
for j=1:J
    % number of coefs to be kept.
    n = m/(J+2-j)^alpha;   
    n = min(round(n),l(J-j+2));
    % threshold.
    if n == l(J-j+2)
        thr(j) = 0;
    else
        d = detcoef(c,l,j);
        d = sort(abs(d));
        thr(j) = d(end-n);
    end
    nkeep(j) = n;
end
