function [tf,allChecks,observedTol] = CheckBiorthFilter(LoR,LoD,HiR,HiD,varargin)
% This function is for internal use only. It may change or be removed in a
% future release.

%#codegen

%   Copyright 2017-2021 The MathWorks, Inc.

% IsOrthogonal() method on dwtfilterbank uses 1e-5 as default tolerance
dataType = underlyingType(LoR);
if ~isempty(varargin)
    tol = cast(varargin{1},dataType);
else
    tol = cast(1e-8,dataType);
end
% Constants needed
sqrt2 = cast(sqrt(2),dataType);
unity = cast(1.0,dataType);
zro = cast(0.0,dataType);

allChecksCell = {'fail';'fail';'fail';'fail';'fail';'fail';'fail'};

% For a user-supplied scaling and wavelet filter, check that
% both correspond to an orthogonal wavelet
LoColR = LoR(:);
LoColD = LoD(:);
HiColR = HiR(:);
HiColD = HiD(:);
lenLoColR = length(LoColR);
lenLoColD = length(LoColD);
lenHiColR = length(HiColR);
lenHiColD = length(HiColD);
lenLoRHiD = isequal(lenLoColR,lenHiColD);
lenLoDHiR = isequal(lenLoColD,lenHiColR);
correctLengths = all([lenLoRHiD lenLoDHiR]);
if correctLengths
    allChecksCell{1} = 'pass';
end

% Filters should be same lengths in this internal function
L = length(LoR);
% Sums
sumLoR = sum(LoColR);
sumLoD = sum(LoColD);
sumHiR = sum(HiColR);
sumHiD = sum(HiColD);

% For orthogonal wavelet sum of scaling filter should be equal to sqrt(2)
% and sum of wavelet filter should be zero
sumLoRTol = abs(sumLoR - sqrt2);
sumLoDTol = abs(sumLoD-sqrt2);
sumHiRTol = abs(sumHiR - zro);
sumHiDTol = abs(sumHiD-zro);
sumFilterTol = max([sumLoRTol,sumLoDTol,sumHiRTol,sumHiDTol]);
sumfilters = sumFilterTol < tol;
if sumfilters
    allChecksCell{2} = 'pass';
end

% Checking autocorrelation and cross-correlation
% cross-correlate LoR and LoD
xcorrLoRLoD = conv(LoR,flip(LoD));
[LoXCORRzerolag,LoIdx] = max(xcorrLoRLoD(L-1:L+1));
% This might be -1 for the highpass filters so we take abs()
xcorrHiRHiD = abs(conv(HiR,flip(HiD)));
[HiXCORRzerolag,HiIdx] = max(xcorrHiRHiD(L-1:L+1));
LoIdx = LoIdx+L-2;
HiIdx = HiIdx+L-2;
if L > 2
    maxEvenLagLo = max(xcorrLoRLoD(LoIdx+2:2:2*L-1));
    % cross-correlation HiR and HiD
    maxEvenLagHi = max(xcorrHiRHiD(HiIdx+2:2:2*L-1));
    % cross-correlation between scaling and wavelet filters
    LoRHiD = conv(LoR,flip(HiD));
    EvenEntries = max(LoRHiD(1:2:end));
    OddEntries = max(LoRHiD(2:2:end));
    xcorrLoHi1 = min(EvenEntries,OddEntries);

    LoDHiR = conv(LoD,flip(HiR));
    EvenEntries = max(LoDHiR(1:2:end));
    OddEntries = max(LoDHiR(2:2:end));
    xcorrLoHi2 = min(EvenEntries,OddEntries);
    xcorrLoHi = max(xcorrLoHi1,xcorrLoHi2);


else
    maxEvenLagLo = cast(0,'like',LoR);
    maxEvenLagHi = cast(0,'like',LoR);
    xcorrLoHi1 = conv(LoR,flip(HiD));
    xcorrLoHi2 = conv(LoD,flip(HiD));
    xcorrLoHi = max(xcorrLoHi1(2),xcorrLoHi2(2));


end

LoXCORRTol = abs(LoXCORRzerolag-unity);
loxcorrzrolag = LoXCORRTol < tol;
HiXCORRTol = abs(HiXCORRzerolag-unity);
hixcorrzrolag = HiXCORRTol < tol;
evenlagLoTol = abs(maxEvenLagLo-zro);
evenlaglo = evenlagLoTol < tol;
evenlaghiTol = abs(maxEvenLagHi-zro);
evenlaghi = evenlaghiTol < tol;
evenlagxTol = abs(xcorrLoHi-zro);
crossLoHi = evenlagxTol < tol;

if loxcorrzrolag
    allChecksCell{3} = 'pass';
end

if hixcorrzrolag
    allChecksCell{4} = 'pass';
end

if evenlaglo
    allChecksCell{5} = 'pass';
end

if evenlaghi
    allChecksCell{6} = 'pass';
end

if crossLoHi
    allChecksCell{7} = 'pass';
end


tf = all([correctLengths sumfilters loxcorrzrolag hixcorrzrolag evenlaglo...
    evenlaghi crossLoHi]);

observedTol = [zro ; sumFilterTol ; LoXCORRTol; HiXCORRTol; evenlagLoTol; ...
    evenlaghiTol; evenlagxTol];

allChecks = categorical(allChecksCell);


