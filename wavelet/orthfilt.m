function [Lo_D,Hi_D,Lo_R,Hi_R] = orthfilt(W,P)
%ORTHFILT Orthogonal wavelet filter set.
%   [LO_D,HI_D,LO_R,HI_R] = ORTHFILT(W) computes the
%   four filters associated with the scaling filter W 
%   corresponding to a wavelet:
%   LO_D = decomposition low-pass filter
%   HI_D = decomposition high-pass filter
%   LO_R = reconstruction low-pass filter
%   HI_R = reconstruction high-pass filter.
%
%   See also BIORFILT, QMF, WFILTERS.

%   Copyright 1995-2021 The MathWorks, Inc.

%#codegen

% Check arguments.
if nargin<2 
    P = 0;
end

% Normalize filter sum.
W = W/sum(W);

% Associated filters.
Lo_R = sqrt(2)*W;
Hi_R = qmf(Lo_R,P);
Hi_D = flip(Hi_R);
Lo_D = flip(Lo_R);
