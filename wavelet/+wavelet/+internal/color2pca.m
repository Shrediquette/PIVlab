function [imout,V,mu] = color2pca(im)
% This function is for internal use only. It may change or be removed in
% a future release.
%
% [imout,V,mu] = color2pca(im);

%   Copyright 2018-2020 The MathWorks, Inc.

%#codegen

[m,n,~] = size(im);
N = m*n;

% Cast input image to double precision
temp_im = double(im);

% Take the mean along the rows, then take the mean along columns
% MeanChan is 1x1x3 and get Zero mean image
temp_im_rs = reshape(temp_im,[m*n 3]);
temp_mu = mean(temp_im_rs,1);
temp_im_rs = bsxfun(@minus,temp_im_rs,temp_mu);
mu = reshape(temp_mu,1,1,3);

% Empirical covariance matrix
C = 1/N*(temp_im_rs'*temp_im_rs);

% Compute eigenvectors and eigenvalues of covariance matrix
[temp_V,D] = eig(C,'vector');
[~,I] = sort(D, 'descend');
V = temp_V(:,I);

imout = reshape(temp_im_rs*V,[m n 3]);


