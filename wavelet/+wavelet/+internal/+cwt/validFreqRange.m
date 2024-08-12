function [minfreq,maxfreq] = validFreqRange(N,fs,minfreq,maxfreq,...
    wname,waveletparam,vpOctave)
% This function is for internal use only. It may change or be removed in a
% future release.
% N = 1000;
% wname = 'bump';
% wparam = [3 60];
% fs = 600;
% minfreq = 2/600;
% maxfreq = 3/600;
% vpOctave = 10;
% [minfreq,maxfreq] = validFreqrange(N,fs,minfreq,maxfreq,wname,...
%   wparam,vpOctave);

%   Copyright 2021 The MathWorks, Inc.


arguments
    N (1,1) {mustBeNumeric}
    fs (1,1) {mustBeNumeric}
    minfreq (1,1) {mustBeNumeric}
    maxfreq (1,1) {mustBeNumeric}    
    wname {mustBeMember(wname,{'morse','amor','bump'})}
    waveletparam (1,2) {mustBeNumeric}
    vpOctave (1,1) {mustBeNumeric}
end

NyquistRange = [0 fs/2];
if (maxfreq <= NyquistRange(1)) || ...
        (minfreq >= NyquistRange(2))
    % Here we set the frequency limits to the maximum range
    minfreq = NyquistRange(1);
    maxfreq = NyquistRange(2);
end

if strcmpi(wname,'morse')
    minValidFreq = cwtfreqbounds(N,fs,'Wavelet',wname,...
        'WaveletParameters',waveletparam);
else
    minValidFreq = cwtfreqbounds(N,fs,'Wavelet',wname);
end
% If the minimum frequency is less than the minimum allowable
% frequency, set equal to the minimum.
if minfreq < minValidFreq
    minfreq = minValidFreq;    
end

if maxfreq > fs/2
    maxfreq = fs./2;
end
% Sufficient spacing in frequencies to respect VoicesPerOctave
freqsep = log2(maxfreq)-log2(minfreq) >= ...
    1/vpOctave;
if ~freqsep 
    atUpperBound = 2^(1/vpOctave)*minfreq+sqrt(eps('double')) > fs/2;
    if ~atUpperBound
        maxfreq = 2^(1/vpOctave)*minfreq+sqrt(eps('double'));
    else
        minfreq = maxfreq*2^(-1/vpOctave)-sqrt(eps('double'));
    end
end

