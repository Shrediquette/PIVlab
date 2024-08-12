function X = apply_nonlinearity(option,X)
% This function is for internal use only, it may change or be removed in a
% future release.
% X = apply_nonlinearity('modulus',X);

%   Copyright 2018-2022 The MathWorks, Inc.

%#codegen 
% Modulus is the only option in 18b
if strcmpi(option,'modulus') && isstruct(X) && iscell(X.signals)
    X.signals = cellfun(@(x)abs(x),X.signals,'uniformoutput',false);
elseif strcmpi(option,'modulus') && ismatrix(X)
    X = abs(X);
else
    error(message('Wavelet:scattering:OnlyModulus'));
end
