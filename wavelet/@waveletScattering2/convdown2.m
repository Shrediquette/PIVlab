function  [imout,dsfilter] = convdown2(imdft,filter,dsfactor,res)
% This function is for internal use only. It may change or be removed in a
% future release.
% imout = convdown2(imdft,filter,log2dsfactor,res)

%   Copyright 2018-2020 The MathWorks, Inc.

szim = size(imdft);
Ndims = ndims(imdft);
if (Ndims == 3) && (szim(3) == 3)
    [imout,dsfilter] = colorConvDown2(imdft,filter,dsfactor,res);
else 
    
    [imout,dsfilter] = grayConvDown2(imdft,filter,dsfactor,res);
end

%-------------------------------------------------------------------------
function [imout,dsfilter] = grayConvDown2(imdft,filter,dsfactor,res)
% Downsampled convolution of gray-scale image with filter

% Prevent downsampling factor from being less than 1.
DSfactorIM = max(1,2^dsfactor);
% Obtain size of filter
[MF,NF] = size(filter);
% Obtain size of image
[M,N] = size(imdft);
% First reshape filter to match image resolution
DSfactorF = 2.^(-res);
% Periodize filter 
periodSZF = [MF./DSfactorF DSfactorF NF./DSfactorF DSfactorF];
filter = reshape(filter,periodSZF);
filter = sum(filter,2);
dsfilter = squeeze(sum(filter,4));
% Multiplication in Fourier domain takes place at resolution of image
convDFT = imdft.*dsfilter;
% Downsample convolution
periodOUT = [M/DSfactorIM DSfactorIM N/DSfactorIM DSfactorIM];
% Periodize convolution
convDFT = reshape(convDFT,periodOUT);
imout = sum(convDFT,2);
imout = sum(imout,4);
imout = squeeze(imout);
% This should be 2D. downsampling factors are already expressed as powers
% of two
imout = ifft2(imout)./DSfactorIM.^2;

%--------------------------------------------------------------------------
function [imout,dsfilter] = colorConvDown2(imdft,filter,dsfactor,res)
% Downsampled convolution of color (3 dims) image with filter
% Filter is always 2D and we use MATLAB's implicit expansion
DSfactorIM = max(1,2.^dsfactor);
DSfactorF = 2.^(-res);
[M,N,P] = size(imdft);
[MF,NF] = size(filter);
% Periodize filter to resolution of data
periodSZF = [MF./DSfactorF DSfactorF NF./DSfactorF DSfactorF];
filter = reshape(filter,periodSZF);
filter = sum(filter,2);
dsfilter = squeeze(sum(filter,4));
convDFT = imdft.*dsfilter;
periodOUT = [M/DSfactorIM DSfactorIM N/DSfactorIM DSfactorIM P];
convDFT = reshape(convDFT,periodOUT);
imout = sum(convDFT,2);
imout = squeeze(sum(imout,4));
for nd = 1:3
    imout(:,:,nd) = ifft2(imout(:,:,nd))./DSfactorIM.^2;
end
