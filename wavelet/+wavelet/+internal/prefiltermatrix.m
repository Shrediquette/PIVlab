function H = prefiltermatrix(prefiltertype,x,Moments)
%   This function is for internal use only. It may change in a future
%   release.
%   
%   The MLPT is due to Maarten Jansen. The algorithms used here for
%   the computation of the prefilter is due to Dr. Jansen.
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

N = size(x,1);
switch lower(prefiltertype)
    case 'haar'
    H = sparse(1/2*eye(N)+diag(1/2*ones(N-1,1),1));
    H(N,N) = 1;
    case 'unbalancedhaar'
    Mfine = Moments(:,1);
    Mcoarse = Mfine + [Mfine(2:N,:); 0];
    H = sparse(diag(Mfine./Mcoarse)+diag(Mfine(2:N)./Mcoarse(1:N-1),1));
    otherwise 
        H = 1;

end
