function [XSize,YSize] = imagepadSz(origsize,log2maxDS,maxSupport)
% This function is for internal use only. It may change or be removed in a
% future release.
% Smallest multiple of 2^log2maxScale larger than origsize in both the row
% and column dimensions. 

%   Copyright 2018-2020 The MathWorks, Inc.

% Take the original size of the image and adding the invariant scale of the
% scaling function
minSz = origsize+maxSupport;
% Determine how many times 2^log2maxDS goes into that size
C = ceil(minSz/2^log2maxDS);
% Multiply that by 2^log2maxDS to obtain the padded sizes in the X and Y
% directions
pdSz = 2^log2maxDS*C;
XSize = pdSz(1);
YSize = pdSz(2);
