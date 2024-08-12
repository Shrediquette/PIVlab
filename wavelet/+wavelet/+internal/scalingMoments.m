function M = scalingMoments(xgrid,moments)
%   This function is for internal use only. It may change in a future
%   release.
%   
%   The MLPT is due to Maarten Jansen. The algorithms used here for
%   the computation of the scaling moments are due to Dr. Jansen.
%
%   References: 
%   Jansen, M. (2016) ThreshLab: Matlab algorithms for wavelet noise 
%   reduction, http://homepages.ulb.ac.be/~majansen/software/index.html
%
%   Jansen, M. (2013). Multiscale local polynomial smoothing in a lifted 
%   pyramid for non-equispaced data. IEEE Transactions on Signal
%   Processing, 61(3), 545-555.
%   

%   Copyright 2016-2020 The MathWorks, Inc.

% This function returns a matrix of scaling moments. 
% At the highest resolution, the scaling functions are characteristic
% functions on the intervals defined by the grids.

N = length(xgrid);
% Take the grid as a row vector
X = xgrid(:)';
% Create a matrix with two rows. Stack adjacent elements for finding the 
% midpoints
X = [X(1:end-1) ; X(2:end)];
% Find the midpoints
X = mean(X);
% To determine the intervals, place the original endpoints in place
Intervals = [xgrid(1) X xgrid(N)];
Intervals = repmat(Intervals,length(moments),1);
moments = repmat(moments(:),1,N)+1;
M = (Intervals(:,2:end).^moments-Intervals(:,1:end-1).^moments)./moments;
M = M';
