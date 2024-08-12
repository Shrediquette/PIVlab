function y = Batchcolfilter(x,h)
% This function is for internal use only, it may change or be removed in a
% future release.
%
% y = colfilter(x,h) where x is the input signal, signal matrix, or image.
% If the size of x in the 3rd dimension is 3, we expect this is an RGB
% image.
% Each column of x is filtered separately. Output size is the same as the
% input. x is extended symmetrically so that filtered outputs have the same
% row (or column) dimension as input. For the high pass output, we decimate
% the highpass output.
%
% % Example:
% load woman
% load antonini;
% y = wavelet.internal.colfilter(X,LoD);

%   Copyright 2019-2020 The MathWorks, Inc.



%#codegen

Sx = size(x);
% Row dimension of the input data
Nr = Sx(1);
% Number of filter coefficients
Nh = numel(h);

% Obtain indices to extend data. Data is symmetrically extended at the
% beginning and end by fix(length(h)/2)
% The extension is here is so that the valid convolution with the filter h
% returns N elements where N is the length of the input. This means the 
% extended length must be N+Nh-1 where Nh is the number of filter taps

% For odd-length biorthogonal filters used in the first level, adding
% fix(Nh/2) elements to both sides of the input gives this length.
ridx = wavelet.internal.reflectIdx(Nr,fix(Nh/2));
%Nidx = (1:Nx)';
%ridx = wextend('ar','symh',Nidx,fix(Nh/2),'b');
% Sample x at those indices. Convolve each column with h and return the
% valid elements
Sx = size(x);
x = reshape(x,[Nr prod(Sx(2:end))]);
y = conv2(x(ridx,:),h,'valid');
y = reshape(y,Sx);
