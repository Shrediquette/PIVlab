function waveinfo(wav)
%WAVEINFO Information on wavelets.
%   WAVEINFO provides information for all the wavelets
%   within the toolbox.
%
%   WAVEINFO('wname') provides information for the wavelet
%   family whose short name is specified by the string 
%   'wname'.
%
%   Available family short names are:
%   'haar'   : Haar wavelet
%   'db'     : Daubechies wavelets
%   'sym'    : Symlets
%   'coif'   : Coiflets
%   'bior'   : Biorthogonal wavelets
%   'rbio'   : Reverse biorthogonal wavelets
%   'meyr'   : Meyer wavelet
%   'dmey'   : Discrete Meyer wavelet
%   'gaus'   : Gaussian wavelets
%   'mexh'   : Mexican hat wavelet
%   'morl'   : Morlet wavelet
%   'cgau'   : Complex Gaussian wavelets
%   'cmor'   : Complex Morlet wavelets
%   'shan'   : Complex Shannon wavelets
%   'fbsp'   : Complex Frequency B-spline wavelets
%   'fk'     : Fejer-Korovkin orthogonal wavelets
%   'bl'     : Best-localized Daubechies wavelets
%   'han'    : Han real orthogonal scaling filters with sum and linear-phase
%              moments
%   'beyl'   : Beylkin orthogonal wavelet
%   'vaid'   : Vaidyanathan orthogonal wavelet
%
%   or user-defined short names for their own wavelet
%   families (see WAVEMNGR). If the user-defined short name 
%   is 'mywa' the information file must be named mywainfo.m.
%   (See HAARINFO, SYMINFO ... as example of such file).
%
%   WAVEINFO('wsys') provides information on wavelet packets.
%
%   See also WAVEMNGR.

%   Copyright 1995-2021 The MathWorks, Inc.


if nargin > 0 && isStringScalar(wav)
    wav = convertStringsToChars(wav);
end

if nargin==0
    infoName = 'infowave';
elseif strcmp(wav,'wsys')
    infoName = 'infowsys';
else
    ind = wavemngr('indf',wav);
    if isempty(ind)
        error(message('Wavelet:moreMSGRF:Invalid_WaveSName',wav));
    else
        infoName = fullfile(matlabroot,'toolbox','wavelet','wavelet',...
            '+wavelet','+internal','+wavinfo',[wav 'info']);
    end
end
FileExist = exist(infoName,'file');
if ~FileExist
    localFileExist = exist([wav 'info'],'file');
end
 
if ~FileExist && ~localFileExist
    error(message('Wavelet:moreMSGRF:File_not_found_2',[infoName '.m']));
else
    S = help(infoName, '-noDefault');
    if ~isempty(S)
        S(1:length([wav 'info'])+1) = '';
    else
        error(message('Wavelet:moreMSGRF:ErrFile',[infoName '.m']));
    end
end
disp(S)

