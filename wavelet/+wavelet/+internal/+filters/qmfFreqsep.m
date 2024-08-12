function fsep = qmfFreqsep(Lo,Hi)
% This function is for internal use only. It may change or be removed in a
% future release.

% Han, Bin (2017) Framelets and Wavelets, p. 70-71. Springer.
% Note we are using 1-FSEP as defined by Han.
%   Copyright 2022 The MathWorks, Inc.

narginchk(2,2);
validateattributes(Lo,{'numeric'},{'vector','finite'},'qmfFreqsep','Lo');
validateattributes(Hi,{'numeric'},{'vector','finite'},'qmfFreqsep','Hi');
if nargin == 1
    Hi = qmf(Lo);
end
Lorow = Lo(:).';
Hirow = Hi(:).';
Npow2Lo = nextpow2(length(Lo));
Npow2Hi = nextpow2(length(Hi));
Npow2 = max(Npow2Lo,Npow2Hi);
Npad = max(512,2^Npow2);
LoDFT = fft(Lorow,Npad).*conj(fft(Lorow,Npad));
HiDFT = fft(Hirow,Npad).*conj(fft(Hirow,Npad));
fsep = 1-sum(LoDFT.*HiDFT)/(norm(LoDFT,2)*norm(HiDFT,2));
