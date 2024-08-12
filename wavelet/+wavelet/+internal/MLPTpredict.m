function P = MLPTpredict(xodd,xeven,ndual)
%   This function is for internal use only. It may change in a future
%   release.
%   
%   The MLPT is due to Maarten Jansen. The algorithms used here for
%   efficient Neville interpolation for possibly matrix-valued inputs was
%   developed by Dr. Jansen.
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

%Initialize the prediction operator to a matrix of zeros with
% size NumEvens x NumOdds
NumEvens = length(xeven);
NumOdds = length(xodd);
P = zeros(NumEvens,NumOdds);
idxEvenOddInterp = repelem(1:NumEvens,2);
idxEvenOddInterp = idxEvenOddInterp(1:NumOdds);
IEvens = sparse(eye(NumEvens));

% Determine the number of even sample on the left and right to used in the
% prediction of the "odd" sample.
nl = ceil(ndual/2);
nr = ndual-nl;


if NumEvens < ndual
    P = neville(xeven,IEvens,xodd);
else
    


% This for loop executes only if NdualMoments > 2
for ii = 1:nl-1
    oddIdx = idxEvenOddInterp == ii;
    if any(oddIdx)
        P(:,oddIdx) = ...
            neville(xeven(1:ndual),IEvens(:,1:ndual),xodd(oddIdx));
    end
end

for ii = nl:NumEvens-nr
    oddIdx = idxEvenOddInterp == ii;
    if any(oddIdx)
        P(:,oddIdx) = ...
            neville(xeven(ii-nl+1:ii+nr),IEvens(:,ii-nl+1:ii+nr),xodd(oddIdx));
        
    end
end



for ii = NumEvens-nr+1:NumOdds
    oddIdx = idxEvenOddInterp == ii;
    if any(oddIdx)
        P(:,oddIdx) = ...
            neville(xeven(NumEvens-ndual+1:NumEvens),IEvens(:,NumEvens-ndual+1:NumEvens),xodd(oddIdx));
        
    end
end
end



%------------------------------------------------------------------------
function Vq = neville(X,V,Xq)
% This function implements polynomial interpolation using the Neville
% algorithm.
% This implementation of Neville is due to Dr. Maarten Jansen.
% X - Interpolation points
% V - Value at the interpolation points
% Xq - Query points at which polynomial is evaluated

Xq = Xq';
X = X';
% Vector of query points
N = length(Xq);
% Vector of interpolation points
n = length(X);
[R,~] = size(V);

% Allocate cell array for interpolating polynomials
ptmp = cell(n,1);
for jj = 1:n
    ptmp{jj} = repmat(V(:,jj),1,N);
end

xx = repmat(Xq,R,1);
for i = 1:n-1
    for j = 1:n-i
        ptmp{j} = ...
            ( (xx-X(j+i)).*ptmp{j} - (xx-X(j)).*ptmp{j+1} ) / ( X(j) - X(j+i) );
    end
end
if isempty(ptmp)
    Vq = 0;
else
    Vq = ptmp{1};
end
