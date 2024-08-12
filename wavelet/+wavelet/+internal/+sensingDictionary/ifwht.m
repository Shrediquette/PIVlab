function y = ifwht(varargin)
% This function is for internal use only, it may change or be removed in a
% future release.
%IFWHT Fast Inverse Discrete Walsh-Hadamard Transform
%   Y = IFWHT(X) returns the inverse discrete Walsh-Hadamard transform of
%   X. The inverse transform values are stored in Y. If X is a matrix, the
%   function operates on each column.
%
%   % EXAMPLE:
%      x = rand(16);
%      y = fwht(x);
%      xHat = ifwht(y); % Inverse transformation should reproduce x
%
%   See also FWHT, FFT, IFFT, DCT, IDCT, DWT, IDWT.

%   Copyright 2021 The MathWorks, Inc.

narginchk(1,1)
% Since the forward and inverse transforms are exactly identical
% operations, FWHT is used to perform inverse transform
y = wavelet.internal.sensingDictionary.fwht(varargin{:});
% Perform scaling
[m,n] = size(y);
if m == 1 % column vector
    m = n;
end
y = y .* m;

% LocalWords:  sequency fwht walsh inp
