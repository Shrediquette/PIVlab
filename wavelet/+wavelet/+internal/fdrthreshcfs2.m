function [wthr,thr] = fdrthreshcfs2(C,S,varargin)
%   This function is for internal use only. It may change in a future
%   release.
%   The function thresholds coefficients using false discovery rate with a
%   specified q-value (the default is 0.05).
%   The thresholding is hard.

%   Copyright 2018-2021 The MathWorks, Inc.

%#codegen
sigma = [];
q = 0.05;
wthr = C;

% Number of levels in the wavelet 2D transform
L = size(S,1)-2;

% Check varargin for the optional q-value and whether we are doing
% level-independent or level-dependent noise estimation
if ~isempty(varargin) && numel(varargin)==1
    q = varargin{1};
    sigma = [];
elseif ~isempty(varargin) && numel(varargin)==2
    q = varargin{1};
    sigma = varargin{2};
% For WDENOISE2, we are always using this option
elseif ~isempty(varargin) && numel(varargin)== 3
    q = varargin{1};
    sigma = varargin{2};
    noisedir = varargin{3};
end

details = [];
    
for lev = 1:L
    Idx = wavelet.internal.getLevelIndices(S,lev);
    % If sigma is empty, we are doing level-dependent estimate of the
    % noise. Accordingly, we need to respect the value of noisedir
    if isempty(sigma)
       details = wavelet.internal.getdetcoef2(wthr,S,noisedir,lev); 
    end
        
    [wthr(Idx),thr] = ...
        FDRthreshold2(wthr(Idx),q,sigma,details);
end


%--------------------------------------------------------------------------
function [dout,thr] = FDRthreshold2(x,q,stdev,details)

if isempty(stdev) && ~isempty(details)
    % If the standard deviation estimate is empty, we are using
    % level-dependent estimation of \sigma.
    normfac = 1/(-sqrt(2)*erfcinv(2*0.75));
    temp = bsxfun(@minus,details,median(details));
    temp_stdev = normfac*median(abs(temp));
else
    temp_stdev = stdev;
end
coder.varsize('temp_stdev');
M = numel(x);
% Guard against zero standard deviation. This protects against edge cases
% where the input is a constant signal, i.e. the variance is zero.
minstd = 1e-9;
temp_stdev(temp_stdev< minstd) = minstd;

% Change to zero-mean approximately unit-std RVs. Use absolute value
mu = mean(x);
xtmp = bsxfun(@rdivide,abs(x-mu),temp_stdev);
xtmp = sort(xtmp,'descend');
% 1-normcdf
p = 1/2*erfc(xtmp./sqrt(2));
% Probabilty is corrected for one-sided test
psort = 2*p;

% Sort data values -- the smaller p-values will correspond to the largest
% data values so this sorts the order statistics of the wavelet
% coefficients in decreasing magnitude
% xsort = sort(abs(x),1,'descend');
xsort = sort(abs(x),'descend');
% n = size(p,1);
n = numel(p);
pval = q*(1:n)./n;
pdiff = psort-pval;
% Guard against empty
pdiff = [0 pdiff];
% Find last nonpositive index in each column
% rowidx = arrayfun(@(x)find(pdiff(:,x)<=0,1,'last'),1:N);
idx = find(pdiff <= 0, 1,'last');
% Correct for the added zero row for row indices greater than 1
idx(idx>1) = idx(idx>1)-1;
thr = xsort(idx);
thr = repmat(thr,1,M);
% Hard thresholding is the only option for FDR
dout = wthresh(x,'h',thr);



