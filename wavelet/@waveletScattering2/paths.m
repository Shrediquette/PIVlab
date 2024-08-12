function [spaths,npaths] = paths(self)
% Scattering paths
%   SPATHS = PATHS(SF) returns the scattering paths for all orders of the
%   scattering framework, SF. SPATHS is cell array of MATLAB tables with NO
%   elements where NO is the number of orders in the scattering framework.
%   Each MATLAB table in SPATHS contains a single variable, path. The
%   variable path is a row vector with one column for each element of the
%   path. The scalar 0 denotes the original image. Positive integers in the
%   L-th column denote the corresponding wavelet filter in the (L-1)-th
%   filter bank. Wavelet bandpass filters are ordered by decreasing center
%   frequency. Note there are NumRotations wavelets per center frequency
%   pair.
%
%   [SPATHS,NPATHS] = PATHS(SF) returns the number of paths in each order
%   as a NO-by-1 column vector where NO is the number of orders in the
%   scattering framework. The sum of the elements in NPATHS is the total
%   number of scattering paths.
%
%   % Example: Compare the number of paths in the scattering framework with 
%   %   three orders. The two filter banks both have quality factors of 1. 
%   %   The invariance scale is equal to the minimum of the image size. 
%   %   First determine the number of paths with the default 
%   %   'OptimizePath',true and then 'OptimizePath',false.
%
%   sf = waveletScattering2('ImageSize',[256 256],'OptimizePath',true,...
%       'QualityFactors',[1 1],'InvarianceScale',256);
%   [spaths,npaths] = paths(sf);
%   sum(npaths)
%   sf.OptimizePath = false;
%   [spaths,npaths] = paths(sf);
%   sum(npaths)

%   Copyright 2018-2020 The MathWorks, Inc.

narginchk(1,1);
nargoutchk(0,2);
no = numorders(self);
spaths = cell(no,1);
% The path for the zero-th order scattering coefficients is trivially 0
spaths{1} = table(0,'VariableNames',{'path'});
% path vector consists of NumRotations*number frequencies
N = self.NumRotations(1)*numel(self.filterparams{1}.omegapsi);
path = zeros(N,2);
% At the first filter bank, the scattering transform goes through all the
% filters
path(:,2) = 1:self.NumRotations(1)*numel(self.filterparams{1}.omegapsi);
spaths{2} = table(path,'VariableNames',{'path'});
% save the current path
cp = path;

for k = 2:no-1
   path = [];
   % Obtain filter parameters from previous and current filter banks
   prevparams = self.filterparams{k-1};
   % Current number of filters
   Ncurrent = self.NumRotations(k)*numel(self.filterparams{k}.omegapsi);
   currwav = 1:Ncurrent;
   % 3-dB bandwidths of previous filter bank
   prev3dB = repelem(self.filterparams{k-1}.psi3dBbw,self.NumRotations(k-1));
   % Obtain current filter bank parameters
   currparams = self.filterparams{k};
   % Frequency support of current filter banks
   psiftsupport = repelem(currparams.psiftsupport,self.NumRotations(k));
   % Resolution of previous filter bank
   prevres = repelem(prevparams.PsiLog2DS,self.NumRotations(k-1));
   
   % For each of the previous filters
   for npsi = 1:size(cp,1)
       
       validwav = psiftsupport.*2^(max(0,prevres(cp(npsi,end))-self.OversamplingFactor)) < 2*pi;   
       validwav = currwav(validwav);
             
       if self.OptimizePath
           validwav = waveletScattering2.optimizePath(validwav,prev3dB(cp(npsi,end)),currparams);
       end
       if ~isempty(validwav)
        tmpath = repmat(cp(npsi,:),numel(validwav),1);
        tmpath = [tmpath validwav']; %#ok<AGROW>
        path = [path ; tmpath]; %#ok<AGROW>
       end
   
   end
   cp = path;
   spaths{k+1} = table(path,'VariableNames',{'path'});

end

npaths = cell2mat(cellfun(@numel,spaths,'uni',false));
