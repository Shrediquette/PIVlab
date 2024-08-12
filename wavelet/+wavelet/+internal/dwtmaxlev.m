function lev = dwtmaxlev(sizeX,filtlen)
% This function is for internal use only. It may change or be removed in a
% future release.
% lev = dwtmaxlev(sizeX,filtlen)

% Copyright 2019-2020 The MathWorks, Inc.

%#codegen

% Determine number of elements in the size vector.
Ns = numel(sizeX);
% Error out if we have more than 3 elements in the size vector
coder.internal.errorIf(Ns > 3, 'Wavelet:FunctionInput:InvalidSizeVector');
% Error out if we have 3 elements and the third dimension is not 3.
coder.internal.errorIf(Ns == 3 && sizeX(3) ~= 3,...
    'Wavelet:FunctionInput:InvalidImageType');

if length(sizeX) == 1
    lx = sizeX;
elseif (length(sizeX) == 2) && (min(sizeX) == 1)
    % columns or rows, choose the largest non-singular dimension for a
    % vector
    lx = max(sizeX);
% Handle RGB image
elseif length(sizeX) == 3
    lx = min(sizeX(1:2));
else
    lx = min(sizeX);
end

% Determine maximum level.
lev = fix(log2(lx/(filtlen-1)));
% Guard against edge case.
if lev < 1
    lev = 0;
end
