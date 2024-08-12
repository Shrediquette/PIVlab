function Eg = normalizedMean(g)
% This function is for internal use only. It may change or be removed in a
% future release.
%
% [Lo,Hi] = wfilters('db4');
% Eg = wavelet.internal.filters.normalizedMean(Lo);

% Han, Bin (2017) Framelets and Wavelets, p. 70-71. Springer.
%   Copyright 2022 The MathWorks, Inc.

narginchk(1,1);
validateattributes(g,{'numeric'},{'vector','finite'},'normalizedMean','g');
if ~isrow(g)
    grow = g(:).';
else
    grow = g;
end
% For current use cases these are all real-valued so conj() is overkill.
abssqG = grow.*conj(grow);
sqNormg = sum(abssqG);
k = 0:length(g)-1;
Eg = sum(k.*abssqG)/sqNormg;
