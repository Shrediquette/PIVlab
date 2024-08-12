function im = pca2color(im,V,mu)
% This function is for internal use only. It may change or be removed in a 
% future release.
% im = wavelet.internal.pca2color(im,V,mu);

%   Copyright 2018-2020 The MathWorks, Inc.

%#codegen
[m,n,~] = size(im);
im = reshape(im,[m*n 3]);
im = reshape(im*V',[m n 3]);
im = im+repmat(mu,[m n 1]);

