function fx = gausspdf(x,mu,sigma)
% This function returns the value of the Gaussian probability density
% function at the value x. x can be a vector, or scalar. The Gaussian
% PDF is parameterized by \mu and \sigma.
%
% This function is for internal use only. It may change in a future
% release.

%   Copyright 2016-2020 The MathWorks, Inc.

%#codegen

sigma2 = sigma.^2;
Xvec = abs((x-mu).^2);
normconstants = 1/(sqrt(2*pi)*sigma);
fx = normconstants.*exp(-Xvec./(2*sigma2));
