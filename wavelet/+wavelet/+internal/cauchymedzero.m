function z = cauchymedzero(muhat,x,weight)
% This function is for internal use. It may change in a future release.
% This is the posterior median density given the data and the weights.
% muhat and x are either column vector or matrices

%   Copyright 2016-2020 The MathWorks, Inc.

% muhat are the parameters, x is the data 

%#codegen

y = x-muhat;
fx = wavelet.internal.gausspdf(y,0,1);
yr = wavelet.internal.gausscdf(y,0,1,'lower')-x.*fx+((x.*muhat-1).*...
    fx.*wavelet.internal.gausscdf(-muhat,0,1,'lower')./wavelet.internal.gausspdf(muhat,0,1));
if isempty(coder.target)
    temp = (x.^2.*(1./weight-1)-1);
else
    temp = bsxfun(@times,(x.^2),(bsxfun(@rdivide,1,weight)-1))-1;
end
yl = 1+exp(-x.^2./2).*temp;

z = yl./2-yr ;





