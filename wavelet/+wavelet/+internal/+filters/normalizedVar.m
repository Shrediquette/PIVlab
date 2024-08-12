function Varg = normalizedVar(g)
% This function is for internal use only. It may change or be removed in a
% future release.

% Han, Bin (2017) Framelets and Wavelets, p. 70-71. Springer.
%   Copyright 2022 The MathWorks, Inc.

narginchk(1,1);
validateattributes(g,{'numeric'},{'vector','finite'},'normalizedMean','g');
if ~isrow(g)
    grow = g(:).';
else
    grow = g;
end
Eg = wavelet.internal.filters.normalizedMean(grow);
% For current use cases, grow is real-valued so conj() is overkill.
abssqG = grow.*conj(grow);
sqNormg = sum(abssqG);
k = 0:length(g)-1;
Varg = sum((k-Eg).*(k-Eg).*abssqG)/sqNormg;
