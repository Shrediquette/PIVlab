function [phicoefs,psicoefs,phimeta,psimeta] = ...
    wavelet2D(im,res,phift,psift,filterparams,vwav,path,type,OSFactor)
% This function is for internal use only. It may change or be removed in a
% future release.

%   Copyright 2018-2020 The MathWorks, Inc.

phids = waveletScattering2.log2DecimationFactor(filterparams,res,OSFactor);
% Size of the input image
ImSize = size(im);
filtSize = size(phift);
% Symmetrically extend image to size of filter. Should we be symmetrically
% extending on both sides? Depends on how we unpad
im = waveletScattering2.padimage(im,filtSize*2^res);
Ndims = ndims(im);
% Convert data from spatial domain
if Ndims > 2
    imDFT = ColorDFT(im);
else
    imDFT = GrayDFT(im);
end

% Get the scaling coefficients
phicoefs = ...
    real(waveletScattering2.convdown2(imDFT,phift,phids,res));

phicoefs = waveletScattering2.unpadimage(phicoefs,phids,ImSize);

% log2 resolution
phimeta.resolution = res-phids;
% We are using the same scaling function in each wavelet transform
phimeta.bandwidth = filterparams.phiftsupport;

% Allocate arrays to update resolutions, bandwidths, and center frequencies
Nwav = numel(vwav);
psicoefs = cell(Nwav,1);
psimeta.resolution = [];
psimeta.bandwidth = [];
psimeta.psi3db = [];
psimeta.path = [];

if strcmpi(type,'highpass')

[~,psids] = ...
    waveletScattering2.log2DecimationFactor(filterparams,res,OSFactor,vwav);
psiftsupport = repelem(filterparams.psiftsupport,numel(filterparams.rotations));
psi3db = repelem(filterparams.psi3dBbw,numel(filterparams.rotations));

for nf = 1:Nwav
    psimeta.resolution(nf) = res-psids(nf);
    psimeta.bandwidth(nf) = psiftsupport(vwav(nf));
    psimeta.psi3db(nf) = psi3db(vwav(nf));
    psicfs = ...
        waveletScattering2.convdown2(imDFT,psift(:,:,vwav(nf)),psids(nf),res);
    psicoefs{nf} = waveletScattering2.unpadimage(psicfs,psids(nf),ImSize);
    psimeta.path(:,nf) = [path ; vwav(nf)];
    
end

elseif strcmpi(type,'lowpass')
    return;
end




%-------------------------------------------------------------------------
function imDFT = GrayDFT(im)
imDFT = fft2(im);

%--------------------------------------------------------------------------
function imDFT = ColorDFT(im)
imDFT = zeros(size(im),'like',im);
for nchan = 1:3
    imDFT(:,:,nchan) = fft2(im(:,:,nchan));
end
