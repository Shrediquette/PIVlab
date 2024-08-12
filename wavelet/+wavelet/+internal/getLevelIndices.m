function Idx = getLevelIndices(S,level)
%   This function is for internal use only. It may change or be removed in a
%   future release.
%
%   % Example: determine the indices for the wavelet coefficients for
%   % 1st level (finest scale) of the wavelet transform for an RGB image.
%   im = imread('woodsculp256.jpg');
%   [C,S] = wavedec2(im,3,'bior4.4');
%   Idx = wavelet.internal.getLevelIndices(S,1);
%   d1 = C(Idx);
%   D_1 = detcoef2('compact',C,S,1);
%   isequal(d1,D_1)

%   Copyright 2018-2020 The MathWorks, Inc.

%#codegen

% Determine if we want the 1D or 2D indices
if isrow(S) || iscolumn(S)
    is1D = true;
else
    is1D = false;
end

if is1D
    Idx = get1DIndices(S,level);
else
    Idx = get2DIndices(S,level);  
end

%--------------------------------------------------------------------------
function Idx = get1DIndices(S,level)

numlevels = numel(S)-2;
cumIdx = cumsum(S);
begin = mod(numlevels-level,numlevels)+1;
Idx = cumIdx(begin)+1:cumIdx(begin+1);


%--------------------------------------------------------------------------
function Idx = get2DIndices(S,level)
numlevels = size(S,1)-2;
% For RGB images
LevelIdx = prod(S,2);
detIdx = LevelIdx(2:end-1);
detIdx = 3*detIdx;
LevelIdx(2:end-1) = detIdx;
LevelIdx = cumsum(LevelIdx);
begin = mod(numlevels-level,numlevels)+1;
Idx = LevelIdx(begin)+1:LevelIdx(begin+1);
