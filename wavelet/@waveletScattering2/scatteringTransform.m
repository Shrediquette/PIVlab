function [S,U] = scatteringTransform(self,im)
% Scattering transform
%   S = SCATTERINGTRANSFORM(SF,IM) returns the wavelet 2-D scattering
%   transform of IM for the scattering decomposition framework, SF. IM is a
%   real-valued 2-D matrix or 3-D matrix. If IM is 3-D, the size of the
%   third dimension must equal 3. The row and column sizes of IM must match
%   the ImageSize property of SF. S is a cell array with Nfb+1 elements
%   where Nfb is the number of filter banks in the scattering decomposition
%   framework and is equal to the number of elements in the QualityFactors
%   property of SF. Equivalently, the number of elements in S is equal to
%   the number of orders in the scattering decomposition. Each element of S
%   is a MATLAB table with the following variables:
%
%   images: A cell array of scattering coefficients. Each element of
%   images is a M-by-N or M-by-N-by-3 matrix. 
%   
%   path: The scattering path used to obtain the scattering
%   coefficients. path is a row vector with one column for each element
%   of the path. The scalar 0 denotes the original image. Positive
%   integers in the L-th column denote the corresponding wavelet filter
%   in the (L-1)-th filter bank. Wavelet bandpass filters are ordered by
%   decreasing center frequency. Note there are NumRotations wavelets per 
%   center frequency pair.
%
%   bandwidth: The bandwidth of the scattering coefficients. 
% 
%   resolution: The log2 resolution of the scattering coefficients.
%
%   [S,U] = SCATTERINGTRANSFORM(SF,IM) returns the wavelet scalogram
%   coefficients for IM. U is a cell array with Nfb+1 elements where Nfb is
%   the number of filter banks in the scattering decomposition framework
%   and is equal to the number of elements in the QualityFactors property
%   of SF. Equivalently, the number of elements in U is equal to the number
%   of orders in the scattering decomposition. Each element of U is a
%   MATLAB table with the following variables:
%
%   coefficients: A cell array of scalogram coefficients. Each element of
%   coefficients is a M-by-N or M-by-N-by-3 matrix. 
%   
%   path: The scattering path used to obtain the scalogram
%   coefficients. path is a row vector with one column for each element
%   of the path. The scalar 0 denotes the original image. Positive
%   integers in the L-th column denote the corresponding wavelet filter
%   in the (L-1)-th filter bank. Wavelet bandpass filters are ordered by
%   decreasing center frequency. Note there are NumRotations wavelets per 
%   center frequency pair.
%
%   bandwidth: The bandwidth of the scalogram coefficients. 
% 
%   resolution: The log2 resolution of the scalogram coefficients.
%
%   % Example: Obtain 2-D scattering transform of xbox image.
%   load xbox;
%   sf = waveletScattering2('ImageSize',size(xbox));
%   [S,U] = scatteringTransform(sf,xbox);

%   Copyright 2018-2020 The MathWorks, Inc.

OSFactor = self.OversamplingFactor;
narginchk(2,2)
nargoutchk(0,2);
% Check the input, we handle a 2D image or an RGB image
sz = [self.YSize self.XSize];
im = checkInput(sz,im);
im = cast(im,self.Precision);

% Number of filter banks
filterparams = self.filterparams;
Nfb = self.nFilterBanks;

% Filters
phift = self.PhiFilter;

% Optimize path
optpath = self.OptimizePath;
% We need to have the zero-th order scattering and wavelet moduli
% coefficients.
U = cell(Nfb+1,1);
S = cell(Nfb+1,1);


% Initial U value is just the image. 
U{1}.coefficients{1} = im;
% Initialize the log2 resolution to 0
U{1}.meta.resolution = 0;
% Initialize path variable to 0
U{1}.meta.path = 0;
U{1}.meta.OSFactor = OSFactor;
U{1}.meta.bandwidth = 2*pi;
U{1}.meta.psi3db = Inf;

type = 'highpass';

% Begin actually scattering transform
for nwt = 0:Nfb-1
    if self.EqualFB && nwt > 0
        psift = cell2mat(self.PsiFilters);
    else
        psift = self.PsiFilters{nwt+1};
    end
   [S{nwt+1},WT] = ...
        waveletScattering2.Cascade2(U{nwt+1},phift,psift,filterparams{nwt+1},type,OSFactor,optpath);
    U{nwt+2} = waveletScattering2.apply_nonlinearity('modulus',WT);

    
end
type = 'lowpass';
S{nwt+2} = waveletScattering2.Cascade2(U{Nfb+1},phift,psift,filterparams{Nfb},type,OSFactor,optpath);

[S,U] = createTables(S,U);

%--------------------------------------------------------------------------
function im = checkInput(sz,im)
% First check that the image has less than or equal to three dimensions, is
% finite, and is real-valued.
validateattributes(im,{'numeric'},{'3d','finite','real'},'scatteringTransform','IM');
SzIM = size(im);
Nd = ndims(im);
if any(SzIM(1:2) ~= sz)
    error(message('Wavelet:scattering:InvalidImageSZ'));
end


% Now ensure that a 3D image has only three channels
if Nd == 3 && SzIM(3) ~= 3
    error(message('Wavelet:scattering:InvalidRGB',SzIM(3)));
end

%--------------------------------------------------------------------------
%-------------------------------------------------------------------------
function [Stable,Utable] = createTables(S,U)
SVariableNames = {'images','path','bandwidth','resolution'};
UVariableNames = {'coefficients','path','bandwidth',...
    'resolution'};
NL = numel(S);
Stable = cell(NL,1);
Utable = cell(NL,1);
for nL = 1:NL
    Stable{nL} = table(S{nL}.coefficients.',S{nL}.meta.path',...
        S{nL}.meta.bandwidth',S{nL}.meta.resolution','VariableNames',...
        SVariableNames);
        
    Utable{nL} = table(U{nL}.coefficients.',U{nL}.meta.path',...,
        U{nL}.meta.bandwidth', U{nL}.meta.resolution',...
        'VariableNames',UVariableNames);
end








