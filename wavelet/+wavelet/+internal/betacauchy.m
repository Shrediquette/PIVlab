function beta = betacauchy(x)
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


% Given a vector or scalar x, return g(x)/phi(x)-1 where g(x) is the
% convolution of the quasi-cauchy PDF with the standard normal PDF
% The g(x) function is explicitly given by:
% g(x) = \dfrac{1}{\sqrt{2\pi}} x^{-2}(1-e^{-x^2/2})
% This is equation (9) in the (2005) paper. 
% With \beta(x) = g(x)/\phi(x)-1 with \phi(x) the standard normal density,
% the posterior probability P(\mu_i \neq 0 | X=x) depends only on \beta(x)
% and the weight function.
%
% Note that the above is not defined at x=0, but the limit exists and is
% equal to -1/2. We set any values of \beta(x)  to -1/2 where x=0
% Note that \beta(x) can be parameterized as well by the anonymous function
% fx = @(x)(exp(x.^2/2)-1)./x.^2-1; 

%#codegen

coder.gpu.internal.kernelfunImpl(false);
coder.inline('never');

beta = coder.nullcopy(x);

phix = wavelet.internal.gausspdf(x,0,1);

% The value of beta to approach -1/2 as x goes to 0. However, phix will
% stop changing as x gets very close to 0 (less than around 1e-8) where the
% value of x^2 in the denomonator continues to change. This causes a
% mis-calculation, so when phix is sufficiently close to phix where x=0,
% don't compute.
dnorm0 = wavelet.internal.gausspdf(0,0,1);

J = abs(phix - dnorm0) > 1000*eps(dnorm0);

% Check if GPU is enabled.
if coder.gpu.internal.isGpuEnabled
    coder.gpu.kernel;
    for i = 1:numel(J)
        if J(i)
            beta(i) = (dnorm0./phix(i)-1)./x(i).^2-1;
        else
            beta(i) = -1/2;
        end
    end
else
    % Values when we do not have a zero
    beta(J) = (dnorm0./phix(J)-1)./x(J).^2-1;

    % Limiting value if we have a zero. If notJ is empty, this will not change
    % any value in beta
    beta(~J) = -1/2;
end
