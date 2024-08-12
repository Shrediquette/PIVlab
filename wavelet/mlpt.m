function [w,t,nj,scalingMoments] = mlpt(x,varargin)
%Multiscale Local 1-D Polynomial Transform
%   [W,T,NJ,SCALINGMOMENTS] = MLPT(X,T) returns the multiscale local
%   polynomial 1-D transform of the signal X sampled at the time instants,
%   or grid locations, T.
%
%   X is a vector or matrix with real-valued entries. X must have at least
%   2 elements if X is a vector and 2 rows if X is a matrix. If X is a
%   matrix, MLPT operates independently on each column of X. If X is a
%   vector, X and T must have the same number of elements. If X is a
%   matrix, the number of elements in T must equal the row dimension of X.
%   If X is a matrix, any NaNs in the columns of X must occur in the same
%   rows. If T or X contains NaNs, the union of the NaNs in T and X is
%   removed prior to obtaining the MLPT. By default, the MLPT is obtained
%   at L resolution levels where L is equal to floor(log2(length(X))) if X
%   is a vector and floor(log2(size(X,1))) if X is a matrix.
%
%   The elements of T do not need to be uniformly spaced, but the elements
%   must increase monotonically. T is a vector, a datetime array, or an
%   array of durations. 
%
%   W is a vector or matrix containing the coarsest resolution scaling
%   coefficients and detail coefficients for each resolution level.
%
%   The output T is a vector of sample times obtained from X and the input
%   T. If the input T is a datetime or duration array, T is converted to
%   units that allow for the stable computation of the MLPT and inverse and
%   is returned as a duration array. The output T is required by IMLPT and
%   MLPTRECON.
%
%   NJ is a vector containing the number of coefficients at each resolution
%   level in W. The elements of NJ are organized as follows:
%
%   NJ(1) -- Number of scaling (approximation) coefficients at the coarsest
%   resolution level.
%
%   NJ(i) -- Number of detail coefficients at resolution level i, i= L-i+2
%   with i = 2,..L+1. Note that the smaller the index i, the coarser the
%   resolution. The MLPT is 2 times redundant in the number of detail
%   coefficients, but not in the number of scaling coefficients.
%
%   SCALINGMOMENTS is a length(W)-by-P matrix containing the 0-th,..P-1 st
%   order scaling function moments. The column dimension of SCALINGMOMENTS
%   depends on the number of primal vanishing moments. For the default
%   setting, SCALINGMOMENTS is length(W)-by-2. SCALINGMOMENTS is required
%   by IMLPT and MLPTRECON.
%
%   In most cases you want to output all of the listed output arguments
%   for MLPT because they are required for IMLPT and MLPTRECON. However,
%   you can output any combination of the positional output arguments. As
%   an example:
%
%   W = MLPT(X,T) outputs the MLPT coefficients. This can be useful for a
%   comparison of MLPT coefficients for different values of the name-value
%   pairs. See the Example below.
%
%   [W,T,NJ,SCALINGMOMENTS] = MLPT(X,T,L) obtains the MLPT at L resolution
%   levels. L is a positive integer less than or equal to
%   floor(log2(length(X)) if X is a vector or floor(log2(size(X,1))) if X
%   is a matrix.
%
%   [W,T,NJ,SCALINGMOMENTS] = MLPT(X) uses uniform sampling instants for
%   the signal X as the time grid if X does not contain NaNs. The sampling
%   interval is equal to 1. If X contains NaNs, the NaNs are removed from X
%   and the nonuniform sampling instants are obtained from the indices of
%   the numeric elements of X. If you specify input arguments other than X,
%   you must either explicitly specify the T input as a floating-point
%   vector, datetime array, duration array, or specify T as empty, [].
%
%   [W,T,NJ,SCALINGMOMENTS] = MLPT(...,'DualMoments',DM) uses DM
%   dual vanishing moments in the lifting scheme. DM is a positive integer
%   between 2 and 4. If unspecified, DM defaults to 2.
%
%   [W,T,NJ,SCALINGMOMENTS] = MLPT(...,'PrimalMoments',PM) uses PM primal
%   vanishing moments in the lifting scheme. PM is a positive integer
%   between 2 and 4. If unspecified, PM defaults to 2. If you specify a
%   value for PM, the SCALINGMOMENTS is a length(W)-by-PM matrix.
%
%   [W,T,NJ,SCALINGMOMENTS] = MLPT(...,'Prefilter',PREFILTER) uses the
%   prefilter denoted by the character array, PREFILTER. Supported options
%   are 'Haar', 'UnbalancedHaar', or 'None'. If you do not specify a
%   prefilter, 'Haar' is used by default.
%
%   % Example:
%   %   Obtain the MLPT of a cubic polynomial using 4
%   %   vanishing dual moments. Show that the MLPT details remove the
%   %   polynomial resulting in a sparse representation of the polynomial.
%   %   Compare the result using the default of 2 vanishing moments, which
%   %   does not remove the quadratic polynomial. Invert the MLPT and show
%   %   perfect reconstruction.
%
%   T = 1:16;
%   x = T.^3;
%   [w4,t,nj,scalingmoments] = mlpt(x,T,'dualmoments',4,'prefilter','none');
%   w2 = mlpt(x,T,'prefilter','none');
%   stem(w4,'markerfacecolor','b'); title('MLPT Coefficients');
%   hold on;
%   stem(w2,'markerfacecolor','r');
%   legend('4 Dual Moments','2 Dual Moments');
%   xrec = imlpt(w4,t,nj,scalingmoments,'dualmoment',4);
%   max(abs(xrec(:)-x(:)))
%
%   See also IMLPT, MLPTDENOISE, MLPTRECON

%   Copyright 2016-2020 The MathWorks, Inc.

%   References
%   The theory of the multiscale local polynomial transform and efficient
%   algorithms for its computation were developed by Maarten Jansen.
%
%   Jansen, M. (2013). Multiscale local polynomial smoothing in a lifted
%   pyramid for non-equispaced data. IEEE Transactions on Signal
%   Processing, 61(3), 545-555.
%
%   Jansen, M. & Oonincx, P. (2005). Second Generation Wavelets and
%   Applications. Springer Verlag.

% Check number of output and input arguments
nargoutchk(0,4);
narginchk(1,9);

% Check that X is double, nonempty and has no more than 2 dimensions.
validateattributes(x,{'double'},{'nonempty','real','2d'},'MLPT','X');
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

[w,t,nj,scalingMoments] = wavelet.internal.mlpt(x,t,L,nd,np,prefilter);

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
params.L = floor(log2(N));
validmoments = @(x) isnumeric(x) && rem(x,1) == 0 && x>=2 && x<=4;
expectedPrefilters = {'none','Haar','UnbalancedHaar'};

if isempty(varargin)
    return;
end

% Check whether a resolution level has been entered
isLevel = isscalar(varargin{1});
if isLevel
    L = varargin{1};
    validateattributes(L,{'numeric'},{'positive','integer','scalar','<=',params.L},...
        'MLPT','L');
    params.L = L;
    varargin(1) = [];
end
p = inputParser;
addParameter(p,'DualMoments',params.nd,validmoments);
addParameter(p,'PrimalMoments',params.np,validmoments);
addParameter(p,'Prefilter',params.prefilter);
parse(p,varargin{:});
params.nd = p.Results.DualMoments;
params.np = p.Results.PrimalMoments;
params.prefilter = p.Results.Prefilter;
params.prefilter = validatestring(p.Results.Prefilter,expectedPrefilters);



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
validateattributes(t,{'numeric'},{'vector','increasing'},'MLPT','T');
validateattributes(x,{'numeric'},{'finite'},'MLPT','X');


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














