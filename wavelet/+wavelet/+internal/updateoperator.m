function U = updateoperator(xfine,xeven,MomentFine,MomentCoarse)
%   This function is for internal use only. It may change in a future
%   release.
%
%   The MLPT is due to Maarten Jansen. The algorithm used here for
%   the computation of the update operator is due to Dr. Jansen.
%
%   References:
%   Jansen, M. (2016) ThreshLab: Matlab algorithms for wavelet noise
%   reduction, http://homepages.ulb.ac.be/~majansen/software/index.html
%
%   Jansen, M. (2013). Multiscale local polynomial smoothing in a lifted
%   pyramid for non-equispaced data. IEEE Transactions on Signal
%   Processing, 61(3), 545-555.

%   Copyright 2016-2020 The MathWorks, Inc.


% Row dimension of update operator
M = length(xeven);
% Column dimension of update operator
N = length(xfine);
% Obtain the number of primal moments used
nprimal = size(MomentFine,2);
NL = ceil(nprimal/2);
NR = nprimal - NL;

U = zeros(ceil(N/2),N);

for ii = 1:N
   xo = xfine(ii);
   [~,idx] = max(xeven(xeven<=xo));
   idx = (idx-NL+1:idx+NR); idx = idx((idx>0)&(idx < M+1));
   xe = xeven(idx); 
   kk = length(idx);
   U(idx,ii) = pinv(MomentCoarse(idx,1:kk)')*MomentFine(ii,1:kk)';

  
end



    





