function [xden,t,wthr,w] = mlptdenoise(x,varargin)
%Denoising using the Multiscale Local 1-D Polynomial Transform
%   XDEN = MLPTDENOISE(X,T) returns a denoised version of the signal X
%   sampled at the time instants, or grid locations T. X is a vector or
%   matrix with real-valued entries. If X is a matrix, MLPTDENOISE operates
%   independently on each column of X. T is a vector, a datetime array, or
%   an array of durations. If X is a vector, X and T must have the same
%   number of elements. If X is a matrix, the number of elements in T must
%   equal the row dimension of X. If X is a matrix, any NaNs in the columns
%   of X must occur in the same rows. If T or X contains NaNs, the union of
%   the NaNs in T and X is removed prior to denoising. 
%
%   By default, the MLPT is denoised based on the two highest-resolution
%   level detail coefficients unless X has fewer than 4 samples. If X has
%   fewer than 4 samples, the MLPT is denoised based only on the highest
%   resolution detail coefficients.
%
%   XDEN = MLPTDENOISE(X) uses uniform sampling instants for the signal X
%   as the time grid if X does not contain NaNs. The sampling interval is
%   equal to 1. If X contains NaNs, the NaNs are removed from X and the
%   nonuniform sampling instants are obtained from the indices of the
%   numeric elements of X. If you specify input arguments other than X, you
%   must either explicitly specify the T input as a floating-point vector,
%   datetime array, duration array, or specify T as empty, [].
%
%   XDEN = MLPTDENOISE(X,T,L) denoises X down to the level L. L must be
%   less than or equal to the maximum resolution level, which is
%   floor(log2(length(X))) if X is a vector and floor(log2(size(X,1))) if X
%   is a matrix. By default, MLPTDENOISE denoises the signal based on the
%   two highest-level detail coefficients.
%
%   XDEN = MLPTDENOISE(...,'DenoisingMethod',DENOISINGMETHOD) denoises the
%   MLPT using DENOISINGMETHOD. DENOISINGMETHOD is one of the following
%   options 'Bayesian', 'Median','SURE', or 'FDR'. If unspecified,
%   DENOISINGMETHOD defaults to 'Bayesian'.
%       * For 'FDR', there is an optional argument for the Q-value, which
%       is the proportion of false positives. Q is a real-valued scalar
%       between 0 and 1, (0<Q<1). To specify FDR with a Q-value use a
%       cell array where the second element is the Q-value, for example
%       'DenoisingMethod',{'FDR',0.01}. If unspecified, Q defaults to 0.05.
%
%   XDEN = MLPTDENOISE(...,'DualMoments',DM) uses DM dual vanishing moments
%   in the lifting scheme. DM is a positive integer between 2 and 4. If
%   unspecified, DM defaults to 2.
%
%   XDEN = MLPTDENOISE(...,'PrimalMoments',PM) uses PM primal vanishing
%   moments in the lifting scheme. PM is a positive integer between 2 and
%   4. If unspecified, PM defaults to 2.
%
%   XDEN = MLPTDENOISE(...'Prefilter',PREFILTER) uses the prefilter denoted
%   by the character array, PREFILTER. Supported options are 'Haar' or
%   'UnbalancedHaar'. If you do not specify a prefilter, 'Haar' is used by
%   default.
%
%   [XDEN,T] = MLPTDENOISE(...) returns the time instants for the denoised
%   signal. T is a floating point vector or a duration array depending on
%   the input time vector. If T is a duration array, MLPTDENOISE internally
%   computed a best duration unit for numerical stability.
%
%   [XDEN,T,WTHR] = MLPTDENOISE(...) returns the thresholded MLPT
%   coefficients, WTHR. 
%
%   [XDEN,T,WTHR,W] = MLPTDENOISE(...) returns the original MLPT
%   coefficients, W.
%
%   % Example 1:
%   %   Denoise the nonuniformly sampled skyline signal down to level 
%   %   three using the default Bayesian method.
%
%   load skyline;
%   xden = mlptdenoise(y,T,3);
%   plot(T,[f xden]); grid on;
%   xlabel('Time'); ylabel('Amplitude');
%
%   % Example 2:
%   %   Denoise a nonuniformly sampled spline signal with added noise using
%   %   median smoothing and two primal vanishing moments. The
%   %   nonuniformed sampling of the signal is indicated by NaNs 
%   %   (missing data). After denoising the signal, replace the original 
%   %   missing data in the correct position.
%
%   load nonuniformspline;
%   plot(splinenoise); grid on; title('Noisy Signal with Missing Data');   
%   xden = mlptdenoise(splinenoise,[],'DenoisingMethod','median');
%   denoisedsig = NaN(size(splinenoise));
%   denoisedsig(~isnan(splinenoise)) = xden;
%   figure;
%   plot([splinesig denoisedsig]); grid on; 
%   legend('Original Signal','Denoised Signal');
%
%   % Example 3:
%   %   Denoise a nonuniformly sampled signal using Stein's unbiased risk 
%   %   method. Return the denoised and original MLPT coefficients and plot 
%   %   for comparison.
%
%   load nonuniformheavisine;
%   [xden,t,wthr,w] = mlptdenoise(x,t,3,'denoisingmethod','SURE');
%   plot(t,[xden f]); title('Denoised Signal with Original');
%   figure;
%   plot([w wthr]); title('Coefficients'); legend('Original','Denoised');
%
%   See also MLPT, IMLPT, MLPTRECON

%   Copyright 2016-2020 The MathWorks, Inc.
  
%   References
%   The theory of the multiscale local polynomial transform and efficient 
%   algorithms for its computation were developed by Maarten Jansen.
% 
%   The theory of empirical Bayesian shrinkage for wavelet transforms was
%   developed by Ian Johnstone and Bernard Silverman. 
%
%   Algorithms for computing empirical Bayesian shrinkage are due to
%   Bernard Silverman
%
%   Jansen, M. (2013). Multiscale local polynomial smoothing in a lifted 
%   pyramid for non-equispaced data. IEEE Transactions on Signal
%   Processing, 61(3), 545-555.
%
%   Jansen, M. & Oonincx, P. (2005). Second Generation Wavelets and 
%   Applications. Springer Verlag. 
%
%   Johnstone, I. & Silverman, B. (2005). EbayesThresh: R Programs for 
%   Empirical Bayes Thresholding, Journal of Statistical Software, 12,1,
%   pp. 1-38.
%
%   Silverman, B. (2012) EbayesThresh: Empirical Bayes Thresholding and
%   Related Methods, http://CRAN.R-project.org/package=EbayesThresh.



% Check number of input and output arguments
narginchk(1,9);
nargoutchk(0,4);

% Check that X is numeric, nonempty and has no more than 2 dimensions.
validateattributes(x,{'double'},{'nonempty','2d'},'MLPTDENOISE','X');
% Obtain the row and column dimensions of X
[r,c] = size(x);
minDim = min([r c]);
% If the minimum dimension of the input is 1, treat X as a column vector
if minDim == 1
    x = x(:);
end
% Get the size of x before the removal of any NaNs
Nall = size(x,1);
% Default time vector if one is not supplied
if isempty(varargin)
    t = (1:Nall)';
    tdur = [];
elseif ~isempty(varargin)
    [t,tdur,varargin] = validTimeVector(Nall,varargin{:});
end

% Check to see if a time vector has been specified. If the time vector
% is specified as empty, set the time vector equal to 1 to size(X,1)

% Remove any NaNs
[x,t,tdur] = removeNaNs(x,t,tdur);
% Check the size of x after the removal of NaNs
if size(x,1) < 2
    error(message('Wavelet:mlpt:MLPTSamples','X'));
end


params = parseinputs(size(x,1),varargin{:});
nd = params.nd;
prefilter = params.prefilter;
np = params.np;
L = params.L;
denoisingmethod = params.denoisingmethod;
[w,t,nj,scalingMoments] = wavelet.internal.mlpt(x,t,L,nd,np,prefilter);

wthr = w;
if strncmpi(denoisingmethod,'Bayesian',1)

    Numcoefs = cumsum(nj);
    for j = 1:L

       wthr(Numcoefs(j)+1:Numcoefs(j+1),:) = ...
           wavelet.internal.ebayesthresh(w(Numcoefs(j)+1:Numcoefs(j+1),:),'leveldependent','median','nondecimated');
    end
elseif strncmpi(denoisingmethod,'Median',1)
    wthr = wavelet.internal.movmedianthresh(w,nj);
elseif strncmpi(denoisingmethod,'SURE',1)
    wthr = wavelet.internal.surethreshcfs(w,nj);
elseif strncmpi(denoisingmethod,'FDR',1)
    wthr = wavelet.internal.fdrthreshcfs(w,nj,params.q);
end

% Pass to internal imlpt
xden = wavelet.internal.imlpt(wthr,t,nj,scalingMoments,nd);

% Return the time vector as a duration array if not empty
if ~isempty(tdur)
    t = tdur;
end

%------------------------------------------------------------------------
function params = parseinputs(N,varargin)
% Set the default number of dual and primal moments as well as the
% prefilter
[varargin{:}] = convertStringsToChars(varargin{:});
params.nd = 2;
params.np = 2;
params.prefilter = 'haar';
params.L = min(2,floor(log2(N)));
params.q = 0.05;
maxlev = floor(log2(N));
params.denoisingmethod = 'Bayesian';
validmoments = @(x) isnumeric(x) && rem(x,1) == 0 && x>=2 && x<=4;
expectedPrefilters = {'Haar','UnbalancedHaar'};
expectedDenoisingMethod = {'Bayesian','Median','SURE','FDR'};

if isempty(varargin)
    return;
end

% Check whether a resolution level has been entered
isLevel = isscalar(varargin{1});
if isLevel
    L = varargin{1};
    validateattributes(L,{'numeric'},{'positive','integer','scalar','<=',maxlev},...
        'MLPTDENOISE','L');
    params.L = L;
    varargin(1) = [];
end
p = inputParser;
addParameter(p,'DualMoments',params.nd,validmoments);
addParameter(p,'PrimalMoments',params.np,validmoments);
addParameter(p,'Prefilter',params.prefilter);
addParameter(p,'DenoisingMethod',params.denoisingmethod);
parse(p,varargin{:});
params.nd = p.Results.DualMoments;
params.np = p.Results.PrimalMoments;
params.prefilter = p.Results.Prefilter;
params.prefilter = validatestring(params.prefilter,expectedPrefilters);
params.denoisingmethod = p.Results.DenoisingMethod;
if iscell(params.denoisingmethod)
    params.q = params.denoisingmethod{2};
    validateattributes(params.q,{'numeric'},{'scalar','nonempty','>',0,'<',1},...
        'MLPTDENOISE','Q');
    params.denoisingmethod = params.denoisingmethod{1};
end
params.denoisingmethod = validatestring(params.denoisingmethod,...
    expectedDenoisingMethod);


%------------------------------------------------------------------------
function [x,t,tdur] = removeNaNs(x,t,tdur)
% First error if x is a matrix and contains NaNs at different rows
% in multiple columns

if all(size(x) ~= 1)
    [M,N] = size(x);
    idxNaNx = isnan(x);
    sameRow = ismember(sum(idxNaNx,2),[0 N]);
    if sum(sameRow) ~= M
        error(message('Wavelet:mlpt:MLPTMatrixNaNs','X'));
    else
        % Remove NaNs from X and T
        x(idxNaNx(:,1),:) = [];
        t(idxNaNx(:,1)) = [];
        idxNaNT = isnan(t);
        t(idxNaNT) = [];
        x(idxNaNT,:) = [];
    end
end
% Cover the vector case -- for a matrix input there should be no NaNs
% remaining in T or X
if length(t) ~= size(x,1)
    error(message('Wavelet:mlpt:MLPTLengthAgree','X','T'));
end
idxNaNT = isnan(t);
idxNaNX = isnan(x);
sumNaN = idxNaNT+idxNaNX;
t(sumNaN>0) = [];
if ~isempty(tdur)
    tdur(sumNaN>0) = [];
end
x(sumNaN>0,:) = [];
validateattributes(t,{'numeric'},{'vector','increasing'},'MLPTDENOISE','T');
validateattributes(x,{'numeric'},{'finite'},'MLPTDENOISE','X');

%-------------------------------------------------------------------------
function [t,tdur,varargin] = validTimeVector(N,varargin)
timevec = varargin{1};
tdur = [];
expectedtimevec = isnumeric(timevec) || isdatetime(timevec) || ...
    isduration(timevec) || isempty(timevec);

if ~any(expectedtimevec)
   error(message('Wavelet:mlpt:MLPTTimeVector'));
end

caltime = isdatetime(timevec) || isduration(timevec);
if caltime
    [t,tdur] = wavelet.internal.convertDuration(timevec);
    
elseif (isvector(timevec) && ~isscalar(timevec))
    t = timevec(:);
    
elseif isempty(timevec)
    t = (1:N)';
end
varargin(1) = [];


