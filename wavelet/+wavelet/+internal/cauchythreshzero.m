function y = cauchythreshzero(z,w)
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

%   Copyright 2016-2020 The MathWorks, Inc.


% This is obtained from the same root-finding operation of the posterior
% median except now we set \hat{\mu} equal to zero and x=t to solve for the
% threshold.

%#codegen

 znorm = wavelet.internal.gausscdf(z,0,1,'lower');
 dnorm = wavelet.internal.gausspdf(z,0,1);
 d1 = sqrt(2*pi)*dnorm;
 y = znorm-z.*dnorm-1/2-(z.^2.*d1.*(1./w-1))/2;

