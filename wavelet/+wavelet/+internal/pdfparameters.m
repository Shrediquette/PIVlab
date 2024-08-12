function [mu,sigma] = pdfparameters(t,x,dim,type)
% This function is for internal use only, it may change in a future
% release.
% [mu,sigma] = pdfparameters(t,x,dim,type)

%   Copyright 2017-2020 The MathWorks, Inc.

% Determine if x is already a PDF
tf = isPDF(t,x,dim);
% Normalize data if the data is not a PDF
if ~tf
    x = wavelet.internal.normalize(t,x,dim,type);
    magsqx = abs(x).^2;
else
    magsqx = x;
end

if dim == 1
    t = t(:);
elseif dim == 2
    t = t(:)';
end
% Find the mean by trapezoidal integration
mu = trapz(t,t.*magsqx,dim);
% Find the variance by trapezoidal integration
sigma2 = trapz(t,abs(t).^2.*magsqx,dim)-abs(mu).^2;
sigma = sqrt(sigma2);

%-------------------------------------------------------------------------
function tf = isPDF(t,x,dim)
% trapz() won't integrate normpdf() output to 1
tol = 1e-1;
allNonNeg = all(x(:)>=0);
y = trapz(t,x,dim);
absdiff = abs(y-ones(size(y)));
if all(absdiff<tol) && allNonNeg
    tf = true;
else
    tf = false;
end





