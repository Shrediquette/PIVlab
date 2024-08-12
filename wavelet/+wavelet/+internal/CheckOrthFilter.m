function [tf,allChecks,observedTol] = CheckOrthFilter(Lo,HiCol, varargin)
% This function is for internal use only. It may change or be removed in a
% future release.

%#codegen

%   Copyright 2017-2021 The MathWorks, Inc.
if nargin == 1
    HiCol = qmf(Lo);
end
% IsOrthogonal() method on dwtfilterbank uses 1e-5 as default tolerance
dataType = underlyingType(Lo);
if underlyingType(HiCol) ~= dataType
    HiCast = cast(HiCol,dataType);
else
    HiCast = HiCol;
end
tol = cast(1e-8,dataType);
if ~isempty(varargin)
    tol = cast(varargin{1},dataType);
end
% Constants needed
sqrt2 = cast(sqrt(2),dataType);
oneOversqrt2 = 1/sqrt2;
unity = cast(1.0,dataType);
zro = cast(0.0,dataType);

%Code generation does not support string arrays. You must first create a
%cell array of character vectors and then convert those to categorical().
allChcksCellstr = {'fail';'fail';'fail';'fail';'fail';'fail';'fail'};

% For a user-supplied scaling and wavelet filter, check that
% both correspond to an orthogonal wavelet
LoCol = Lo(:);
HiCol = HiCast(:);
Lscaling = length(Lo);
Lwavelet = length(HiCol);
equallen = Lscaling == Lwavelet;
if equallen
    % Equal Length
    allChcksCellstr{1} = 'pass';
end
evenlengthLo = ~(rem(Lscaling,2));
evenlengthHi = ~(rem(Lwavelet,2));
evenlength = all([evenlengthLo evenlengthHi]);
if evenlength
    % Even Length
    allChcksCellstr{2} = 'pass';
end

% Sums and norms
normLo = norm(LoCol,2);
sumLo = sum(LoCol);
normHi = norm(HiCol,2);
sumHi = sum(HiCol);
EvenSum = sum(LoCol(1:2:Lscaling));
OddSum = sum(LoCol(2:2:Lscaling));

% Checking tolerances
evenTol = abs(EvenSum-oneOversqrt2);
oddTol = abs(OddSum-oneOversqrt2);
alternateSumTol = max(evenTol,oddTol);
loNormTol = abs(normLo - unity);
hiNormTol = abs(normHi - unity);
unitNormTol = max(loNormTol,hiNormTol);
sumEvenOdd = alternateSumTol < tol;
unitnorm = unitNormTol < tol;
if unitnorm
    allChcksCellstr{3} = 'pass';
end

% For orthogonal wavelet sum of scaling filter should be equal to sqrt(2)
% and sum of wavelet filter should be zero
sumLoTol = abs(sumLo - sqrt2);
sumHiTol = abs(sumHi - zro);
sumFilterTol = max(sumLoTol,sumHiTol);
sumfilters = sumFilterTol < tol;
if sumfilters
    allChcksCellstr{4} = 'pass';
end

if sumEvenOdd
    % Even and Odd Sums 1/sqrt(2)
    allChcksCellstr{5} = 'pass';
end

L = Lscaling;
% Initialize zeroevenlags to false. Any valid scaling filter or wavelet
% filter must have at least two elements, but we ensure that this code will
% not error out if an invalid filter is provided

if L > 2
    xcorrHi = conv(HiCol,flip(HiCol));
    xcorrLo = conv(LoCol,flip(LoCol));
    xcorrLoHi = conv(LoCol,flip(HiCol));
    xcorrLoEvenlag = xcorrLo(L+2:2:end);
    xcorrHiEvenlag = xcorrHi(L+2:2:end);
    xcorrLoHiEvenlag = xcorrLoHi(L:2:end);    
    xcorrLoTol = max(abs(xcorrLoEvenlag));
    xcorrHiTol = max(abs(xcorrHiEvenlag));
    xcorrLoHiTol = max(abs(xcorrLoHiEvenlag));
    xcorrTol = max(xcorrLoTol,xcorrHiTol);
    zeroevenlags = xcorrTol < tol; 
    lohiorth = xcorrLoHiTol < tol;
else
    zeroevenlags = true;
    xcorrTol = zro;
    lohiorth = true;
    xcorrLoHiTol = zro;
end
if zeroevenlags
    allChcksCellstr{6} = 'pass';
end
if lohiorth 
    allChcksCellstr{7} = 'pass';
end
tf = all([evenlength equallen unitnorm sumfilters sumEvenOdd ...
    zeroevenlags lohiorth]);
observedTol = [zro ; zro ; unitNormTol ; sumFilterTol ; alternateSumTol;...
    xcorrTol; xcorrLoHiTol];
allChecks = categorical(allChcksCellstr);