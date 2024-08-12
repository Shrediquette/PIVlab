function [wcorr,wcorrCI,Pval,NJ] = modwtcorr(w1,w2,varargin)
%MODWTCORR MODWT multiscale correlation.
%   WCORR = MODWTCORR(W1,W2) computes the wavelet correlation by scale for
%   the input matrices W1 and W2. W1 and W2 are the outputs of MODWT. W1
%   and W2 must be the same size and must have been obtained using the same
%   wavelet. WCORR is a M-by-1 vector of correlation coefficients where M
%   is the number of levels with nonboundary wavelet coefficients.
%   MODWTCORR returns correlation estimates only where there are
%   nonboundary coefficients. This condition is satisfied when the
%   transform level is not greater than floor(log2(N/(L-1)+1)) where N is
%   the length of the input. If there are sufficient nonboundary
%   coefficients at the final level, MODWTCORR returns the scaling
%   correlation in the final row of WCORR. By default, MODWTCORR uses the
%   'sym4' wavelet to determine the boundary coefficients.
%
%   WCORR = MODWTCORR(W1,W2,WAV) uses the wavelet WAV to determine the
%   number of boundary coefficients by level. WAV can be a string
%   corresponding to valid wavelet or a positive even scalar indicating the
%   length of the wavelet filter. The wavelet filter length must match the
%   length used in the MODWT of the inputs. If WAV is unspecified or
%   specified as empty, the default 'sym4' wavelet is used.
%
%   [WCORR,WCORRCI] = MODWTCORR(...) returns the lower and upper 95%
%   confidence bounds for the correlation coefficients in WCORR. WCORRCI is
%   an M-by-2 matrix. The first column of WCORRCI is the lower confidence
%   bound. The second column of WCORRCI is the upper confidence bound.
%   Confidence bounds are computed using Fisher's Z-transformation. The
%   standard error of Fisher's Z statistic, sqrt(N-3), is determined by the
%   equivalent number of coefficients in the critically sampled DWT,
%   floor(size(w1,2)/2^LEV) where LEV is the level of the wavelet
%   transform. MODWTCORR returns NaNs for the confidence bounds when N-3 is
%   less than or equal to zero.
%
%   [...] = MODWTCORR(W1,W2,WAV,ConfLevel) uses ConfLevel for the coverage
%   probability of the confidence interval. ConfLevel is a real scalar
%   strictly greater than 0 and less than 1. If ConfLevel is unspecified or
%   specified as empty, the coverage probability defaults to 0.95.
%
%   [WCORR,WCORRCI,PVAL] = MODWTCORR(...) returns the p-values for the
%   hypothesis test that the correlation coefficient in WCORR is equal to
%   zero. PVAL is a M-by-2 matrix. The first column of PVAL is the p-value
%   computed using the standard t-statistic test for a correlation
%   coefficient of zero. The second column of PVAL contains the adjusted
%   p-value using the false discovery procedure of Benjamini & Yekutieli
%   under arbitrary dependence assumptions. The degrees of freedom (N-2)
%   for the t-statistic are determined by the equivalent number of
%   coefficients in the critically sampled DWT, floor(size(w1,2)/2^LEV)
%   where LEV is the level of the wavelet transform. MODWTCORR returns NaNs
%   when N-2 is less than or equal to zero.
%
%   [WCORR,WCORRCI,PVAL,NJ] = MODWTCORR(...) returns the number of
%   nonboundary coefficients used in the computation of the correlation
%   estimates by level.
%
%   WCORR = MODWTCORR(...,'table') returns a M-by-6 MATLAB table with
%   the following variables:
%       NJ              The number of MODWT coefficients by level
%       Lower           The lower confidence bound for the correlation
%                       coefficient
%       Rho             Correlation coefficient
%       Upper           The upper confidence bound for the correlation
%                       coefficient
%       Pvalue          P-value for the null hypothesis test that the
%                       correlation is zero.
%       AdjustedPvalue  Adjusted p-value
%
%   You can specify the 'table' flag anywhere after the input transforms W1
%   and W2. If you specify 'table', MODWTCORR only outputs one argument.
%
%   The row names of the table WCORR designate the type and level of each
%   estimate. For example, D1 designates that the row corresponds to a
%   wavelet or detail estimate at level 1 and S6 designates that the row
%   corresponds to the scaling estimate at level 6. The scaling correlation
%   is only computed for the final level of the MODWT and only when there
%   are nonboundary scaling coefficients.
%
%   [...] = MODWTCORR(...,'reflection') reduces the number of wavelet and
%   scaling coefficients at each scale by half. Use this option when the
%   MODWT of W1 and W2 were obtained using the 'reflection' boundary
%   condition. You must enter the entire string 'reflection'. If you added
%   a wavelet named 'reflection' using the wavelet manager, you must rename
%   that wavelet prior to using this option. 'reflection' may be placed in
%   any position in the input argument list after the input transforms W1
%   and W2. MODWTCORR only supports unbiased estimates of the wavelet
%   correlation. For unbiased estimates, extra coefficients obtained using
%   the 'reflection' boundary must be removed. Specifying the 'reflection'
%   option in MODWTCORR is identical to first obtaining the MODWT of W1 and
%   W2 using the default 'periodic' boundary handling and then computing
%   the wavelet correlation estimates.
%
%   MODWTCORR(...) with no output arguments plots the wavelet correlations
%   by scale with lower and upper confidence bounds. If ConfLevel is not
%   specified, the coverage probability defaults to 0.95. Scales with NaNs
%   for the confidence bounds and the scaling correlation are excluded.
%
%   %Example 1:
%   %   Obtain the MODWT of the Southern Oscillation Index and Truk Island
%   %   daily pressure datasets. Tabulate the correlation between the two
%   %   datasets by scale.
%
%   load soi;
%   load truk;
%   wsoi = modwt(soi);
%   wtruk = modwt(truk);
%   wcorr = modwtcorr(wsoi,wtruk,'table')
%
%   %Example 2:
%   %   Plot the correlation coefficient by scale with error bars for
%   %   the monthly Deutsche Mark-USD and Japanese Yen-USD exchange rates.
%
%   load DM_USD;
%   load JY_USD;
%   wdm = modwt(DM_USD,'db2',6);
%   wjy = modwt(JY_USD,'db2',6);
%   modwtcorr(wdm,wjy,'db2')
%
%   See also MODWTXCORR, MODWTVAR, MODWTMRA, MODWT, IMODWT

%   Copyright 2015-2018 The MathWorks, Inc.

% MODWTCORR accepts between 2 and 6 inputs
narginchk(2,6);

% Ensure that the input has at least two rows
if (isrow(w1) || iscolumn(w1))
    error(message('Wavelet:modwt:InvalidCFSSize'));
end

% Ensure that the input matrices are the same size
if (numel(w1) ~= numel(w2))
    error(message('Wavelet:modwt:CFSMatrixSize'));
end

%Validate that the inputs are double-precision, real-valued with no
% NaNs or Infs
validateattributes(w1,{'double'},{'real','nonnan','finite'});
validateattributes(w2,{'double'},{'real','nonnan','finite'});

params = parseinputs(varargin{:});
ConfLevel = params.ConfLevel;
filtlen = params.L;
boundary = params.boundary;

% Level of the MODWT
level = size(w1,1)-1;

% Extract scaling coefficients
V1 = w1(end,:);
V2 = w2(end,:);
scalingcorr = false;

% Keep just the wavelet coefficients
w1 = w1(1:end-1,:);
w2 = w2(1:end-1,:);

% If the boundary is specified as 'reflection', remove the last N/2
% coefficients
if strcmpi(boundary,'reflection')
    if isodd(size(w1,2))
        error(message('Wavelet:modwt:EvenLengthInput'));
    end
    N = size(w1,2)/2;
else
    N = size(w1,2);
end

% For unbiased estimates, keep only N coefficients and make sure
% we only compute estimates where we have nonboundary coefficients

Jmax = floor(log2((N-1)/(filtlen-1)+1));
if (Jmax<1)
    error(message('Wavelet:modwt:ZeroNonBoundaryCFS'));
end
Jmax = min(Jmax,level);
w1 = w1(1:Jmax,1:N);
w2 = w2(1:Jmax,1:N);

% Remove the mean from the scaling coefficients. Wavelet coefficients
% should be zero mean

V1 = detrend(V1(1:N),0);
V2 = detrend(V2(1:N),0);

if (Jmax-level==0)
    scalingcorr = true;
end

[X,NJ] = removemodwtboundarycoeffs(w1,V1,N,Jmax,filtlen,scalingcorr);
Y = removemodwtboundarycoeffs(w2,V2,N,Jmax,filtlen,scalingcorr);

J = 1:Jmax;

if scalingcorr
    % If we are returning a correlation estimate of the scaling
    % coefficients
    J = [J Jmax];
end

XY = X .* Y;
Nrows = numel(J);
SSX = zeros(1,Nrows);
SSY = zeros(1,Nrows);
SSXY = zeros(1,Nrows);

for jj = 1:Nrows
    
    XNaN = X(jj,~isnan(X(jj,:)));
    SSX(jj) = sum(XNaN.^2);
    YNaN = Y(jj,~isnan(Y(jj,:)));
    SSY(jj) = sum(YNaN.^2);
    XYNaN = XY(jj,~isnan(XY(jj,:)));
    SSXY(jj) = sum(XYNaN);
    
end

% Correlation estimates
COR = SSXY ./ (sqrt(SSX) .* sqrt(SSY));

% Compute the N for the T-statistic along
% with T-statistic, p-value, and adjusted p-value
% N is derived from the DWT

NDWT = floor(size(w1,2) ./ 2.^J);

% T statistic and p-value
Tstat = abs(COR.*sqrt((NDWT-2)./(1-COR.^2)));
pvalue = 2*tpvalue(-Tstat,NDWT-2);
pvalue = pvalue(:);

% Benjamini & Yekutieli, FDR
adj_p = wfdrBY(pvalue);


% Adjust confidence level for symmetric distribution for Gaussian
% confidence intervals using Fisher's Z-transformation

ConfLevelComplement = 1-ConfLevel;
ConfLevelComplement = ConfLevelComplement/2;
ConfLevel = 1-ConfLevelComplement;


% Compute confidence intervals based on the Gaussian distribution
qnorm = -sqrt(2)*erfcinv(2*ConfLevel);
Cest = [real(tanh(atanh(COR) - qnorm ./ sqrt(NDWT-3))); COR;
    real(tanh(atanh(COR) + qnorm ./ sqrt(NDWT-3)))]';

% For NDWT <=3 returns NaNs for the confidence intervals
InvalidIdx = NDWT<=3;
Cest(InvalidIdx,[1 3]) = NaN;

if nargout >1 && params.tableflag
    error(message('Wavelet:modwt:InvalidOutput'));
end

if nargout >=1 && ~params.tableflag
    wcorr = Cest(:,2);
    wcorrCI = Cest(:,[1 3]);
    Pval = [pvalue adj_p];
    NJ = NJ(:);
end

if nargout == 1 && params.tableflag
    
    % Create row names for table
    rownames = cell(numel(J),1);
    for ii = 1:numel(J)
        rownames{ii} = sprintf('D%d',ii);
    end
    if scalingcorr
        rownames{end} = sprintf('S%d',level);
    end
    
    Ctmp = [NJ' Cest pvalue adj_p];
    
    wcorr = array2table(Ctmp,'VariableNames',...
        {'NJ','Lower','Rho','Upper','Pvalue','AdjustedPvalue'},...
        'RowNames',rownames);
end

if nargout==0
    plotMODWTCorr(Cest,scalingcorr)
end


%%------------------------------------------------------------------
function params = parseinputs(varargin)
% First convert any strings to char arrays
[varargin{:}] = convertStringsToChars(varargin{:});

params.boundary = 'periodic';
params.L = 8;
params.ConfLevel = 0.95;
params.tableflag = false;


% Check for the table flag. If the table flag is present
% make this input true. If there are no other variable input arguments
% return
tftable = strcmpi('table',varargin);
if any(tftable)
    params.tableflag = true;
    varargin(tftable>0) = [];
end

if isempty(varargin)
    return;
end

tfboundary = strcmpi(varargin,'reflection');
if any(tfboundary)
    params.boundary = 'reflection';
    varargin(tfboundary>0) = [];
end

if isempty(varargin)
    return;
end


Len = length(varargin);
% The wavelet must be the first input argument in varargin
wavlen = varargin{1};
% Handle cases where the wavelet is a string, or a scalar, or
% empty

if ischar(wavlen)
    [~,~,Lo,~] = wfilters(wavlen);
    params.L = length(Lo);
elseif isscalar(wavlen)
    params.L = wavlen;
elseif isempty(wavlen)
    params.L = 8;
else
    error(message('Wavelet:modwt:InvalidWavelet'));
end

validateattributes(params.L,{'numeric'},{'real','positive','even'});

if (Len>1)
    params.ConfLevel = varargin{2};
    if isempty(params.ConfLevel)
        params.ConfLevel = 0.95;
    end
end

validateattributes(params.ConfLevel,{'double'},{'scalar','>',0,'<',1});



%--------------------------------------------------------------------
function p = tpvalue(x,v)
%TPVALUE Compute p-value for t statistic.

normcutoff = 1e7;
if length(x)~=1 && length(v)==1
    v = repmat(v,size(x));
end

% Initialize P.
p = NaN(size(x));
nans = (isnan(x) | ~(0<v)); % v == NaN ==> (0<v) == false

% First compute F(-|x|).
%
% Cauchy distribution.  See Devroye pages 29 and 450.
cauchy = (v == 1);
p(cauchy) = .5 + atan(x(cauchy))/pi;

% Normal Approximation.
normal = (v > normcutoff);
p(normal) = 0.5 * erfc(-x(normal) ./ sqrt(2));

% See Abramowitz and Stegun, formulas 26.5.27 and 26.7.1.
gen = ~(cauchy | normal | nans);
p(gen) = betainc(v(gen) ./ (v(gen) + x(gen).^2), v(gen)/2, 0.5)/2;

% Adjust for x>0.  Right now p<0.5, so this is numerically safe.
reflect = gen & (x > 0);
p(reflect) = 1 - p(reflect);

% Make the result exact for the median.
p(x == 0 & ~nans) = 0.5;

%-----------------------------------------------------------------
function plotMODWTCorr(C,scalingCorr)
% Plotting function for MODWT correlation

% If scaling correlation is present, exclude it.
if scalingCorr
    C = C(1:end-1,:);
end

% Form the data for the error bar plot
rho = C(:,2);
lower = rho-C(:,1);
upper = C(:,3)-rho;

% Do not plot intervals with NaNs
idxNoNaN = ~isnan(lower);
rho = rho(idxNoNaN);
lower = lower(idxNoNaN);
upper = upper(idxNoNaN);

% Create a vector of scales for the plot
levels = 1:numel(rho);
scales = 2.^levels;

errorbar(log2(scales),rho,lower,upper,'bx','markersize',12);
grid on;
Ax = gca;
line(log2(scales),zeros(size(scales)),'color','r','linestyle','--',...
    'linewidth',2);
Ax.XTick = log2(scales);
Ax.YLim = [-1.05 1.05];
xlabel('Log(scale) -- base 2');
ylabel('Correlation Coefficient');
title('Correlation by Scale -- Wavelet Coefficients');
















