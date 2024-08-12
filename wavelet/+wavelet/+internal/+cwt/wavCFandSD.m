function [FourierFactor,sigmaT, cf] = wavCFandSD(wname,varargin)
%   This function is for internal use only. It may change or be removed
%   in a future release.

%#codegen
%   Copyright 2017-2020 The MathWorks, Inc.

narginchk(1,3);
coder.internal.prefer_const(wname);
ga = 0;
be = 0;

if ~isempty(varargin)
    ga = varargin{1};
    be = varargin{2};
end
% Initialize cf and sigmaT so they are defined on all execution paths for 
% code generation
% We error if these zero upon executing the function.
cf = 0;
sigmaT = 0;

% cf is wavelet center frequency in radians / second, sigmaT is the wavelet
% standard deviation
wname = wname(1);
switch lower(wname)
    case 'm'
        % Morse
        cf = wavelet.internal.cwt.morsepeakfreq(ga,be);
        [~,~,~,sigmaT,~] = ...
            wavelet.internal.cwt.morseproperties(ga,be);

    case 'a'
        % amor / Analytic Morlet
        cf = 6;
        sigmaT = sqrt(2);

    case 'b'
        % bump
        cf = 5;
        % Measured standard deviation of bump wavelet
        sigmaT = 5.847705;

end

if coder.target('MATLAB')
    if cf == 0 || sigmaT == 0
        error(message('Wavelet:cwt:CFSigmaZero'));
    end
else
    coder.internal.assert(cf ~=0 && sigmaT ~= 0, 'Wavelet:cwt:CFSigmaZero');
end
% Convert scale from center frequency reference to sampling frequency ref.
FourierFactor = (2*pi)/cf;
