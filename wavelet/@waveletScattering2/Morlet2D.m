function fourierpsi = Morlet2D(Nx,Ny,sigma,slant,omegaC,theta,offset,precision)
% This function is for internal use only. It may change or be removed in a
% future release.

%   Copyright 2018-2020 The MathWorks, Inc.

% Create mesh grid. Result is Ny-by-Nx matrices for both X and Y
% X has Ny rows where the elements of X are repeated across the columns
% Y as Nx columns where the elements of Y are repeated in each column
[X,Y] = meshgrid(1:Nx,1:Ny);
[M,N] = size(X);
X = X - ceil(Nx/2) - 1;
Y = Y - ceil(Ny/2) - 1;
X = X - offset(1);
Y = Y - offset(2);
% Allocate LittleWood-Paley sum
LPSum = zeros(M,N);
NumberFilters = numel(omegaC)*numel(theta);
spatialpsi = cell(NumberFilters,1);
fourierpsi = cell(NumberFilters,1);
nf = 1;
for no = 1:numel(omegaC)
    for ntheta = 1:numel(theta)
        [R,Rinv] = waveletScattering2.rotmat2d(theta(ntheta));
        % Sifre, equation 2.41
        % curv = np.dot(R, np.dot(D, R_inv)) / ( 2 * sigma * sigma)
        D = [1/sigma(no)^2, 0 ; 0 slant^2/sigma(no)^2];
        eParams = (Rinv*D)*R;
        S = X.* (eParams(1,1)*X + eParams(1,2)*Y) + Y.*(eParams(2,1)*X + eParams(2,2)*Y);
        % Normalization
        Gaussian = exp(-S/2);
        modulatedWave = Gaussian.*exp(1j*(X*omegaC(no)*cos(theta(ntheta)) + Y*omegaC(no)*sin(theta(ntheta))));
        K = real(sum(modulatedWave(:))./ sum(Gaussian(:)));
        psi = modulatedWave - K*Gaussian;
        normfactor = 2*pi*sigma(no)*sigma(no)/slant;
        psi = 1/normfactor*fftshift(psi);
        
        if (strcmp(precision, 'single'))
            psi = single(psi);
        end
        % Wavelets are real-valued in the Fourier domain
        psif = real(fft2(psi));
        spatialpsi{nf} = psi;
        fourierpsi{nf} = psif;
        % Checking
        mag2psif = abs(psif).^2;
        rotmag2psif = circshift(rot90(mag2psif,2),[1 1]);
        LPSum = LPSum+1/2*(mag2psif+rotmag2psif);
        nf = nf+1;
    end
    
end

% Value to normalize wavelets by for contractive property
MaxLPValue = max(LPSum(:));
% Scale the wavelets
fourierpsi = cellfun(@(x)x/sqrt(MaxLPValue),fourierpsi,'uni',0);
fourierpsi = cat(3,fourierpsi{:});


