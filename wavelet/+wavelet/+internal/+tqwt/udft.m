function xdft = udft(x)
% This function is for internal use only. It may change or be removed in a
% future release.

% Copyright 2021 The MathWorks, Inc.

%#codegen
N = size(x,1);
xdft = 1/sqrt(N)*fft(x);