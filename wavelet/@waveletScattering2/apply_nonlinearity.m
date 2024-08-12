function X = apply_nonlinearity(option,X)
% This function is for internal use only, it may change or be removed in a
% future release.
% X = apply_nonlinearity('modulus',X);

%   Copyright 2018-2020 The MathWorks, Inc.

% Modulus is the only option in 18b
if strcmpi(option,'modulus') && isstruct(X) && iscell(X.coefficients)
    X.coefficients = cellfun(@(x)abs(x),X.coefficients,'uniformoutput',false);
elseif strcmpi(option,'modulus') && ...
        (ismatrix(X) || (ndims(X) == 3 && size(X,3) == 3)) 
    X = abs(X);
else
    error(message('Wavelet:scattering:OnlyModulus'));
end
