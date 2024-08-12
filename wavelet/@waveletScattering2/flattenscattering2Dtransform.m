function Sflat = flattenscattering2Dtransform(S)
% This function is for internal use only. It may change or be removed in a
% future release.
% SFLAT = WAVELETSCATTERING2.FLATTENSCATTERING2DTRANSFORM(S)

%   Copyright 2018-2020 The MathWorks, Inc.

% Ensure no cells are empty
nonempty = checknonempty(S);
tf = checkresolution(S(nonempty));
if ~tf
     error(message('Wavelet:scattering:equalresolution'));
end

Sflat.images = {};
% Number of filter banks in scattering decomposition
Nfb = numel(S);
startidx = 1;
for nL = 1:Nfb
    numImages = numel(S{nL}.images);
    idx = startidx:startidx+numImages-1;
    Sflat.images(idx) = S{nL}.images;
    startidx = startidx+numImages;
end

%-------------------------------------------------------------------------
function tf = checkresolution(Snonempty)
% This local function checks the resolution of all scattering coefficients
% if the scattering coefficients are not equal in resolution, we error.
tfres = false(numel(Snonempty),1);
tfnumel = false(numel(Snonempty),1);
% Obtain the resolution of the first image
resfirst = Snonempty{1}.resolution;
% Obtain the number of elements in the first image
numelemfirst = cellfun(@numel,Snonempty{1}.images);
if isscalar(resfirst) && isscalar(numelemfirst)
    tfres(1) = true;
    tfnumel(1) = true;
end
for nL = 2:numel(Snonempty)
    resolution = Snonempty{nL}.resolution;
    imagesize = ...
        cell2mat(cellfun(@(x)numel(x),Snonempty{nL}.images,'uni',false));
    if all(resolution == resfirst)
        tfres(nL) = true;
    end
    if all(imagesize == numelemfirst)
        tfnumel(nL) = true;
    end
end
tf = all([tfres ; tfnumel]);

%--------------------------------------------------------------------------
function nonempty = checknonempty(S)
% Check that the cell arrays, coefficients, are nonempty
nonempty = true(numel(S),1);
for nL = 1:numel(S)
    nonempty(nL) = all(cellfun(@(x)~isempty(x),S{nL}.images));
end

















