function wthr = movmedianthresh(w,nj)
%   This function is for internal use only. It may change in a future
%   release.
%   This function calculates the standard deviation of the coefficients
%   as a moving median of the absolute values of  the coefficients at
%   each level of the multiresolution analysis. 
%   This estimate is then used with the universal threshold and hard
%   thresholding.

%   Copyright 2016-2020 The MathWorks, Inc.

minstd = 1e-9;
L = length(nj)-1;
Numscaling = nj(1);
% normfac = 1/norminv(0.75,0,1);
normfac = 1/(-sqrt(2)*erfcinv(2*0.75));
wthr = w;
Numcoefs = cumsum(nj);
NumDetails = Numcoefs(end)-Numscaling;
stdevest = zeros(size(w));


for j = L:-1:1
   B = max(10,floor(nj(j+1)/10));
   stdevest(Numcoefs(j)+1:Numcoefs(j+1),:) = ...
  normfac*movmedian(abs(wthr(Numcoefs(j)+1:Numcoefs(j+1),:)),B,'Endpoints','shrink');
  
end

stdevest(stdevest< minstd) = minstd;
thr = sqrt(2*log(NumDetails))*stdevest;
wthr = wthresh(wthr,'h',thr);





