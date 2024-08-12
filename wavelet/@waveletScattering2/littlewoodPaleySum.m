function [lpsum,f] = littlewoodPaleySum(self,fb)
% Littlewood-Paley sum
%   LPSUM = LITTLEWOODPALEYSUM(SF) returns the Littlewood-Paley sum for the
%   2-D filter banks in the 2-D wavelet scattering decomposition SF. LPSUM
%   is an M-by-N-by-NFB matrix where M-by-N is the matrix size of the
%   padded filters and NFB is the number of filter banks.
%
%   LPSUM = LITTLEWOODPALEYSUM(SF,FB) returns the Littlewood-Paley sum for
%   the specified filter banks FB. FB is a positive integer or vector of
%   positive integers in the range [1,numfilterbanks(SF)]. LPSUM is a
%   M-by-N-by-L matrix where L is the number of unique elements in FB.
%
%   [LPSUM,F] = LITTLEWOODPALEYSUM(...) returns the spatial frequencies for
%   the Littlewood-Paley sum. F is a two-column matrix with the first
%   column containing the spatial frequencies in the x-direction and the
%   second column containing the spatial frequencies in the y-direction.
%
%   % Example: Return and plot the Littlewood-Paley sums for the scattering
%   %   framework with two filter banks and quality factors of 2 and 1 
%   %   respectively. Note the 2-D Morlet filter bank used in the scattering 
%   %   transform is not designed to capture the highest spatial 
%   %   frequencies jointly in the x- and y-directions.
%
%   sf = waveletScattering2('QualityFactors',[2 1]); 
%   [lpsum,f] = littlewoodPaleySum(sf); 
%   max(max(lpsum(:,:,1)))
%   max(max(lpsum(:,:,2)))
%   surf(f(:,1),f(:,2),lpsum(:,:,2)); shading interp; view(0,90);
%   xlabel('f_x'); ylabel('f_y'); colorbar;
%   title('Q=1');

%   Copyright 2018-2020 The MathWorks, Inc.


narginchk(1,2)
% Number of filter banks in the scattering framework. 
Nfb = self.nFilterBanks;
if nargin == 1
    fb = 1:Nfb;
elseif nargin == 2 
    validateattributes(fb,{'numeric'},{'vector','integer',...
        '<=',Nfb,'nonempty','positive'},'littlewoodPaleySum','FB');
    % Obtain unique specifications
    fb = unique(fb,'stable');    
end


% Number of frequencies in filters
Nomegax = size(self.PhiFilter,2);
Nomegay = size(self.PhiFilter,1);


phift = self.PhiFilter;
psifilters = self.PsiFilters;
if self.EqualFB
    psifilters = repelem(psifilters,Nfb);
    psifilters = psifilters';
end
szphi = size(phift);
lpsum = zeros(szphi(1),szphi(2),numel(fb));
% For the LP sums
for nl = 1:numel(fb)
    psift = psifilters{fb(nl)};
    for nf = 1:size(psift,3)
        mag2psift = abs(psift(:,:,nf)).^2;
        rotmag2psift = circshift(rot90(mag2psift,2),[1 1]);
        lpsum(:,:,nl) = lpsum(:,:,nl)+1/2*(mag2psift+rotmag2psift);
    end
    lpsum(:,:,nl) = abs(phift).^2+lpsum(:,:,nl);
    
end

fx = 0:1/Nomegax:1-1/Nomegax;
fy = 0:1/Nomegay:1-1/Nomegay;
f = [fx' fy'];

