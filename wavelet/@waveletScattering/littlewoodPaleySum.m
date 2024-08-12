function [lpsum,f] = littlewoodPaleySum(self,fb)
%Littlewood-Paley sum
%   LPSUM = LITTLEWOODPALEYSUM(SN) returns the Littlewood-Paley sum for the
%   filter banks in the scattering network, SN. LPSUM is an M-by-L matrix
%   where M is the number of elements in the Fourier transform of the
%   scattering filters and L is the number of scattering filter banks. The
%   columns of LPSUM are ordered by the position of the filter bank in the
%   scattering decomposition. For example, the first column of LPSUM
%   corresponds to the filter bank used for the first-order scattering
%   coefficients.
%
%   LPSUM = LITTLEWOODPALEYSUM(SN,FB) returns the Littlewood-Paley sum for
%   the specified filterbank, FB. FB is a positive integer between 1 and
%   the number of filter banks in the scattering network. The number of
%   filter banks in the scattering decomposition is equal to the number of
%   specified QualityFactors in SN.
%
%   [LPSUM,F] = LITTLEWOODPALEYSUM(...) returns the frequencies for the
%   Littlewood-Paley sum. If you specify a sampling frequency in the
%   scattering decomposition, F is in hertz. If you do not specify a
%   sampling frequency, F is in units of cycles/sample.
%
%   % Example: Return and plot the Littlewood-Paley sums for the scattering
%   %   network with two filter banks and quality factors of 8 and 1 
%   %   respectively.
%
%   sn = waveletScattering('QualityFactors',[8 1]); 
%   lpsum = littlewoodPaleySum(sn); plot(lpsum); 
%   legend('1st filter bank','2nd filter bank');
%   grid on;

%   Copyright 2018-2022 The MathWorks, Inc.

%#codegen
narginchk(1,2)
Nfb = numel(self.filters);
if nargin == 2
    validateattributes(fb,{'numeric'},{'vector','integer',...
        '<=',Nfb,'nonempty','positive'},'littlewoodPaleySum','FB');
elseif nargin == 1
    fb = 1:Nfb;
end
% Number of frequencies in filters
Nomega = size(self.filters{1}.phift,1);
lpsum = zeros(Nomega,numel(fb),'like',self.filters{1}.phift);
for nl = 1:numel(fb)
    phift = self.filters{fb(nl)}.phift;
    psift = self.filters{fb(nl)}.psift;
    % Obtain wavelet filters
    positiveMag2Psift = psift.*conj(psift);
    negativeMag2Psift = circshift(flip(positiveMag2Psift),1);
    positiveMag2Psift = sum(positiveMag2Psift,2);
    negativeMag2Psift = sum(negativeMag2Psift,2);
    Mag2Phift = phift.*phift;
    lpsum(:,nl) = Mag2Phift+1/2*(positiveMag2Psift+negativeMag2Psift);
end
f = 0:1/Nomega:1-1/Nomega;
if ~self.normfreqflag
    f = f.*self.SamplingFrequency;
end
f = f(:);

