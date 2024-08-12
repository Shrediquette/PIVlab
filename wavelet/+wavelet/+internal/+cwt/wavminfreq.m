function [minfreq,maxperiod,maxscale] = wavminfreq(WAV,N,ga,be,varargin)
%   This function is for internal use only. It may change or be removed
%   in a future release.

%   Copyright 2017-2020 The MathWorks, Inc.


if isempty(varargin)
    numsd = 2;
    nv = 10;
elseif ~isempty(varargin) && numel(varargin) == 1
    numsd = varargin{1};
elseif ~isempty(varargin) && numel(varargin) == 2
    numsd = varargin{1};
    nv = varargin{2};
end

validateattributes(numsd,{'numeric'},{'integer','positive'});


switch lower(WAV)
    case 'amor'
        % Find the minimum usable scale under the default conditions, this protects
        % against edge cases
        s0 = wavelet.internal.cwt.wavhighfreq(10,'amor',[],[]);
        omega_psi = 6;
        % Standard deviation is sqrt(2), determined by integral of Morlet
        % wavelet
        sigmat = numsd*sqrt(2);
        maxscale = N/sigmat;
        
        
        
    case 'bump'
        % Find the minimum usable scale under the default conditions, this protects
        % against edge cases
        s0 = wavelet.internal.cwt.wavhighfreq(10,'amor',[],[]);
        % Center frequency of bump wavelet
        omega_psi = 5;
        % Time standard deviation of bump wavelet.
        % Obtained by trapezoidal integration
        sigmat = 5.8506;
        sigmat = numsd*sigmat;
        maxscale = N/sigmat;
        
        
    case 'morse'
        % Find the minimum usable scale under the default conditions, this protects
        % against edge cases
        s0 = wavelet.internal.cwt.wavhighfreq(50,'morse',ga,be);
        % Peak in angular frequency
        omega_psi = wavelet.internal.cwt.morsepeakfreq(ga,be);
        [~,~,~,sigmat] = wavelet.internal.cwt.morseproperties(ga,be);
        sigmat = numsd*sigmat;
        maxscale = N/sigmat;

end

% guard against edge case
if maxscale < s0*2^(1/nv)
    maxscale = s0*2^(1/nv);
end

minfreq = omega_psi/maxscale*1/(2*pi);
maxperiod = 1/minfreq;
