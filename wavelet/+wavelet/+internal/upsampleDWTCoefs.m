function [coefsorig,coefsdenoised] = upsampleDWTCoefs(data,wname)
% This function upsamples the DWT coefficients for plotting
% coefsmat = upsampleDWTCoefs(C,L,wname)

%   Copyright 2017-2020 The MathWorks, Inc.

origsignal = data.SignalDataInternal(:);

% Currently the data handler is storing the coefficients so this is
% recomputing the wavelet transform
origwt = mdwtdec('c',origsignal,data.Level,wname);
% Create delta functions for reconstruction filters
origwt.dwtFilters.HiR(:) = 0;
origwt.dwtFilters.LoR(:) = 0;
origwt.dwtFilters.HiR(1) = 1;
origwt.dwtFilters.LoR(1) = 1;
denoisedwt = origwt;
denoisedwt.cd = data.DenoisedCoefficients(1:end-1);
denoisedwt.ca = data.DenoisedCoefficients{end};


coefsorig = zeros(data.Level+1,numel(data.SignalDataInternal));
coefsdenoised = zeros(data.Level+1,numel(data.SignalDataInternal));

% Obtain approximation 
% These should be the same for the original and denoised
Aorig = mdwtrec(origwt,'a',data.Level);
Adenoised = mdwtrec(denoisedwt,'a',data.Level);
coefsorig(data.Level+1,:) = Aorig;
coefsdenoised(data.Level+1,:) = Adenoised;

% Obtain details
for lev = data.Level:-1:1
    coefsorig(lev,:) = mdwtrec(origwt,'d',lev);
    coefsdenoised(lev,:) = mdwtrec(denoisedwt,'d',lev);
end

% Transpose for stem plotting -- The coefficients should be real-valued,
% but use .'

coefsorig = coefsorig.';
coefsdenoised = coefsdenoised.';
    
    
    








