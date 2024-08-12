function y = normalize(t,x,dim,type)
%   This function is for internal use only. The function normalizes a matrix
%   x along the specified dimension to have unit l2 norm.
%   The option 'vector' normalizes the N-dimensional vectors in C^N
%   The option 'pdf' normalizes the integral of the N-dimensional vectors
%   with respect to t using trapezoidal integration.
%   y = wavelet.internal.normalize(t,x,2,'vector');
%   y = wavelet.internal.normalize(t,x,2,'pdf');

%   Copyright 2017-2020 The MathWorks, Inc.

if dim == 2
    % Transpose matrix (not Hermitian transpose)
    xtmp = x.';
    t = t(:)';
else
    xtmp = x;
    t = t(:);
end
if strcmpi(type,'vector')
    colnorm = sqrt(sum(abs(xtmp).^2));
    xtmp = normalizecolumns(xtmp,colnorm);
elseif strcmpi(type,'pdf')
    colnorm = sqrt(trapz(t,abs(xtmp).^2));
    xtmp = normalizecolumns(xtmp,colnorm);
    
end
if dim == 2
    y = xtmp';
else
    y = xtmp;
end

%-------------------------------------------------------------------------
function y = normalizecolumns(x,colnorms)
idxzero = (colnorms == 0);
if any(idxzero)
    x(:,idxzero) = 0;
end
y = bsxfun(@rdivide,x,colnorms);
