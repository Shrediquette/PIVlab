function [T,delta] = intervalsolve(zf,fun,lo,hi,maxiter,varargin)
%   This function is for internal use only. It may change in a future
%   release.
%
%   The empirical Bayes method used here is a MATLAB implementation of the
%   R package.
% 
%   Silverman, B. (2012) EbayesThresh: Empirical Bayes Thresholding and
%   Related Methods, http://CRAN.R-project.org/package=EbayesThresh.
%
%   References:
%   Johnstone, I. & Silverman, B. (2005). EbayesThresh: R Programs for 
%   Empirical Bayes Thresholding, Journal of Statistical Software, 12,1,
%   pp. 1-38.
%
%   fun should be a monotone function. Here we are using
%   wavelet.internal.betacauchy or wavelet.internal.cauchymedzero

%   Copyright 2016-2020 The MathWorks, Inc.

% zf can be a scalar or vector
[m,~] = size(zf);


% lo is a scalar. We wil replicate the scalar in a vector to length zf
lo = repmat(lo,m,1);
hi = repelem(hi,m,1);

% If varargin is not empty, we are calling cauchymedzero
Tol = 1e-9;

numiter = 0;
conTol = Inf;
while conTol > Tol
    numiter = numiter+1;
    midpoint = (lo+hi)./2;
    fmidpoint = feval(fun,midpoint, varargin{:});
    idx = fmidpoint <= zf;
    lo(idx) = midpoint(idx);
    hi(~idx) = midpoint(~idx);
    delta(numiter,:) = max(abs(hi-lo));
    conTol = max(delta(numiter,:));
    if numiter > maxiter
        break;
    end
end


T = (lo+hi)./2;




