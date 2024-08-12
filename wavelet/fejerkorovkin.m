function F = fejerkorovkin(w)
%FEJERKOROVKIN Fejer-Korovkin wavelets.
%   F = fejerkorovkin(W) returns the scaling filter
%   associated with Fejer-Korovkin wavelet specified by the character vector W where
%   W = 'fkN'.
%   Supported values for N are:
%   N = 4, 6, 8, 14, 18, 22.
%
%   %Example:
%   %   Obtain the scaling and wavelet filters for the Fejer-Korovkin
%   %   filter with 14 coefficients.
%   Lo = fejerkorovkin('fk14');
%   Hi = qmf(Lo);

%   Copyright 2015-2020 The MathWorks, Inc.


narginchk(1,1)
if isStringScalar(w)
    w = convertStringsToChars(w);
end
% Transfer character vector to lower case for matching
wname = lower(w);

% Supported wavelets
SupportedWavelets = {'fk4','fk6','fk8','fk14','fk18','fk22'};

% Check for supported wavelet and error if not supported
tf = strcmpi(wname,SupportedWavelets);
if all(~tf)
    error(message('Wavelet:moreMSGRF:Invalid_fk'));
end


switch wname
    case 'fk4'
        
        F = [0.653927555569765, 0.753272492839487, 0.0531792287790598, ...
            -0.0461657148152177];
        
    case 'fk6'
        
        F = [0.42791503242231, 0.812919643136907, 0.356369511070187, ...
            -0.146438681272577, -0.0771777574069701, 0.0406258144232379];
        
    case 'fk8'
        
        F = [0.3492381118638, 0.782683620384065, 0.475265135079471, ...
            -0.0996833284505732, -0.15997809743403, 0.0431066681065162, ...
            0.0425816316775818, -0.0190001788537359];
        
    case 'fk14'
        
        F = [0.260371769291396, 0.686891477239599, 0.611554653959511, ...
            0.0514216541421191, -0.245613928162192, -0.0485753390858553, ...
            0.124282560921513, 0.0222267396224631, -0.0639973730391417, ...
            -0.00507437254997285, 0.029779711590379, -0.00329747915270872, ...
            -0.00927061337444824, 0.00351410097043596];
        
    case 'fk18'
        
        F = [0.2214515194360345  0.6335563639152345  0.6509831067841178 ...
            .1423451789259654 -.2461979800493986  -.1136225515492217 ...
            .1278484507573520 .7070292322194529e-1 -.7524062280870671e-1...
            -.3972386789549200e-1  .4593660448589165e-1 ...
            .1869540067916261e-1  -.2663249564356005e-1  ...
            -.6157329255229687e-2 .1363931324915134e-1  ...
            -.3263608423390426e-3  -.4679884925355524e-2 ...
            .1635793887541839e-2];
        F = F(:)';
        
        
    case 'fk22'
        
        F = [0.19389610780,0.58945219090,0.67008496290,...
            0.21562984910, -0.22802885580,-0.16446571530,0.11154914370,...
            0.11015526490,-0.06608451680,-0.07184168190,0.04354236760,...
            0.04477521220, -0.02974288070,-0.02597087310,0.02028448610,...
            0.01296424940,-0.01288599060,-0.00483843260,0.00717380320,...
            0.00036128560,-0.00267699160,0.00088057740];
        
end

% [EOF]
