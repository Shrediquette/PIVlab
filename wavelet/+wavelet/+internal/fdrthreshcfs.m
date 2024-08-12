function [wthr,thr] = fdrthreshcfs(w,nj,q,varargin)
%   This function is for internal use only. It may change in a future
%   release.
%   The function thresholds coefficients using false discovery rate with a
%   specified q-value (the default is 0.05).
%   The thresholding is hard.

%   Copyright 2016-2020 The MathWorks, Inc.

%#codegen

narginchk(2,6);

if isvector(w) && ~iscell(w) && isrow(w)
    w = w(:);
    RowVector = true;
else
    RowVector = false;
end

sigma = [];

if numel(varargin)>=1
    sigma = varargin{1};
end

if ~iscell(w)
    L = length(nj)-1;
    tempwthr = w;
    Numcoefs = cumsum(nj);
    thr = zeros(L,1);
    for lev = L:-1:1
        [tempwthr(Numcoefs(lev)+1:Numcoefs(lev+1),:),thr] = ...
            FDRthreshold(w(Numcoefs(lev)+1:Numcoefs(lev+1),:),q,sigma);
    end
else
    tempwthr = cell(size(w));
    thr = cell(size(w));
    for lev = 1:length(w)
        [temp_wthr,temp_thr] = FDRthreshold(w{lev},q,sigma);
        tempwthr{lev} = temp_wthr;
        thr{lev} = temp_thr;
    end
end

if RowVector
    wthr = tempwthr.';
else
    wthr = tempwthr;
end
end

%--------------------------------------------------------------------------
function [dout,thr] = FDRthreshold(x,q,stdev)
if isempty(stdev)
    % If the standard deviation estimate is empty, we are using
    % level-dependent estimation of \sigma.
    normfac = 1/(-sqrt(2)*erfcinv(2*0.75));
    temp = bsxfun(@minus,x,median(x));
    tempstdev = normfac*median(abs(temp));
else
    tempstdev = stdev;
end

M = size(x,1);
N = size(x,2);

% Guard against zero standard deviation. This protects against edge cases
% where the input is a constant signal, i.e. the variance is zero.
minstd = 1e-9;
tempstdev(tempstdev< minstd) = minstd;

% Change to zero-mean approximately unit-std RVs. Use absolute value
tempmean = bsxfun(@minus, x, mean(x));
xtmp = abs(bsxfun(@rdivide,tempmean,tempstdev));
xtmp = sort(xtmp,'descend');
% 1-normcdf
p = 1/2*erfc(xtmp./sqrt(2));
% Probabilty is corrected for one-sided test
psort = 2*p;

% Sort data values -- the smaller p-values will correspond to the largest
% data values so this sorts the order statistics of the wavelet
% coefficients in decreasing magnitude
xsort = sort(abs(x),1,'descend');
n = size(p,1);
pval = repmat(q*(1:n)/n,size(x,2),1)';
pdiff = psort-pval;
% Guard against empty
zerorow = zeros(1,size(pdiff,2));
pdiff = [zerorow; pdiff];
% Find last nonpositive index in each column
if isempty(coder.target)
    rowidx = arrayfun(@(x)find(pdiff(:,x)<=0,1,'last'),1:N);
else
    rowidx = zeros(1,N);
    for i = 1:N
        rowidx(i) = find(pdiff(:,i)<=0,1,'last');
    end
end
% Correct for the added zero row for row indices greater than 1
rowidx(rowidx>1) = rowidx(rowidx>1)-1;
shift = 0:M:(N-1)*M;
% Convert to linear index
idx = rowidx+shift;
% Extract threshold for sorted data instead of inverse normal
%thr = xsort(idx);
thr = xsort(idx);
thr = repmat(thr,M,1);
% Hard thresholding is the only option for FDR
dout = wthresh(x,'h',thr);
end


