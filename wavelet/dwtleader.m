function [dh,h,cp,zq,leaders,structfunc] = dwtleader(x,varargin)
%Multifractal 1-D Wavelet Leader Estimates
% [DH,H] = DWTLEADER(X) returns the singularity spectrum, DH, and the
% Holder exponents, H, for the 1-D real-valued data, X. The singularity
% spectrum is estimated using structure functions determined for the
% linearly-spaced moments -5:5. The structure functions are computed based
% on the wavelet leaders obtained using the biorthogonal spline wavelet
% filter with 1 vanishing moment in the synthesis wavelet and 5 vanishing
% moments in the analysis wavelet ('bior1.5'). By default, multifractal
% estimates are derived from wavelet leaders at a minimum level of 3 and
% maximum level where there are at least 6 wavelet leaders. For the
% default wavelet and minimum regression level, you need a time series with
% at least 248 samples.
%
% [DH,H,CP] = DWTLEADER(X) returns the first three cumulants, CP. The first
% cumulant characterizes the local maximum of the singularity spectrum. For
% monofractal processes, the first cumulant measures the linear fit for the
% scaling exponents, while the second cumulant characterizes the departure
% from linearity.
%
% [DH,H,CP,TAUQ] = DWTLEADER(X) returns the scaling exponents for the
% linearly spaced moments -5:5.
%
% [DH,H,CP,TAUQ,LEADERS] = DWTLEADER(...) returns the wavelet leaders in
% LEADERS. LEADERS is a cell array with the i-th element containing the
% wavelet leaders at level i+1, or scale 2^(i+1). Wavelet leaders are not
% defined at level 1.
%
% [DH,H,CP,TAUQ,LEADERS,STRUCTFUNC] = DWTLEADER(...) returns the
% multiresolution structure functions, STRUCTFUNC. STRUCTFUNC is a
% structure with the following fields:
%
%   Tq: matrix of multiresolution quantities that depend jointly on time
%   and scale. Tq provides measurements of the input X at various scales.
%   Scaling phenomena in X imply a power-law relationship between the
%   moments of Tq and scale. For DWTLEADER, Tq is a Ns-by-36 matrix where
%   Ns is the number of scales used in multifractal estimates. The first 11
%   columns of Tq are the scaling exponent estimates by scale for each of
%   the q-th moments, -5:5. The next 11 columns contain the singularity
%   spectrum estimates, DH, for each of the q-th moments. Columns 23 to 33
%   contain the Holder exponent estimates, H. The final three columns
%   contain the estimates for the 1st, 2nd, and 3rd order cumulants
%   respectively.
%
%   weights: Ns-by-1 vector of weights used in the regression. The weights
%   are all equal to one if 'RegressionWeight' is equal to 'uniform' or
%   equal to the number of wavelet leaders by scale if 'RegressionWeight'
%   is equal to 'scale'.
%
%   logscales: Ns-by-1 vector containing the base-2 logarithm of the scales
%   used as predictors in the regression.
%
% [...] = DWTLEADER(X,WNAME) uses the orthogonal or biorthogonal wavelet
% denoted by WNAME in the computation of the wavelet leaders and the
% fractal estimates. WNAME is a wavelet family short name and filter number
% recognized by the wavelet manager. You can query valid wavelet family
% short names using wavemngr('read'). To determine whether a particular
% wavelet is orthogonal or biorthogonal, you can use WAVEINFO with the
% wavelet family short name, waveinfo('db'), or use WAVEMNGR with the
% 'type' option for a specific wavelet, wavemngr('type','fk4'). A 1
% indicates an orthogonal wavelet and a 2 denotes a biorthogonal wavelet.
% The minimum-required data length depends on the wavelet filter and the
% levels used in the regression model.
%
% [...] = DWTLEADER(...,'RegressionWeight',WEIGHT) uses the WEIGHT option
% in the weighted least-squares regression model to determine the
% singularity spectrum, Holder exponents, cumulants, and scaling exponents.
% Valid options for WEIGHT are 'uniform' and 'scale'. The 'uniform' option
% applies equal weight to each scale. The 'scale' option uses the number of
% wavelet leaders by scale as weights. If unspecified, 'RegressionWeight'
% defaults to 'uniform'.
%
% [...] = DWTLEADER(...,'MinRegressionLevel',MINLEV) uses only levels
% greater than or equal to MINLEV in the multifractal estimates. MINLEV
% is a positive integer greater than or equal to 2. DWTLEADER requires at
% least 6 wavelet leaders at the maximum level and two levels to be used in
% the multifractal estimates. The scale in the discrete wavelet transform
% corresponding to MINLEV is 2^MINLEV. If unspecified, MinRegressionLevel
% defaults to 3.
%
% [...] = DWTLEADER(...,'MaxRegressionLevel',MAXLEV) uses only levels less
% than or equal to MAXLEV in the multifractal estimates. MAXLEV is a
% positive integer greater than or equal to MINLEV+1. MAXLEV defaults to
% the largest level where there are at least 6 wavelet leaders. The scale
% in the discrete wavelet transform corresponding to MAXLEV is 2^MAXLEV.
% The MaxRegressionLevel name-value pair is intended for situations where
% you want to restrict the levels used in the regression to a value less
% than the default level. You can use the optional output argument,
% LEADERS, or the weights field of the optional output argument,
% STRUCTFUNC, to determine the number of wavelet leaders by level.
%
%   %Example 1:
%   %   Compute the singularity spectrum and cumulants for
%   %   a Brownian noise process.
%   rng(100);
%   x = cumsum(randn(2^15,1));
%   [dh,h,cp] = dwtleader(x);
%   plot(h,dh,'o-','MarkerFaceColor','b'); grid on;
%   title({'Singularity Spectrum'; ['First Cumulant ' num2str(cp(1))]});
%
%   %Example 2:
%   %   Compute the cumulants for a multifractal random walk. The
%   %   multifractal random walk is realization of a random process with a
%   %   theoretical first cumulant of 0.75 and second cumulant of -0.05.
%   %   The second cumulant value of -0.05 captures the fact that the
%   %   scaling exponents deviate from a linear function with slope 0.75.
%   load mrw07505;
%   [~,~,cp,tauq] = dwtleader(mrw07505);
%   cp([1 2])
%   plot(-5:5,tauq,'bo--'); title('Estimated Scaling Exponents');
%   grid on;
%   xlabel('Q-th Moments'); ylabel('\tau(q)');
%
%   %Example 3:
%   %   Compare multifractal spectrum of heart-rate variability data
%   %   before and after application of a drug that reduces heart dynamics.
%   load hrvDrug;
%   predrug = hrvDrug(1:4642);
%   postdrug = hrvDrug(4643:end);
%   [dhpre,hpre] = dwtleader(predrug);
%   [dhpost,hpost] = dwtleader(postdrug);
%   plot(hpre,dhpre,hpost,dhpost);
%   xlabel('h'); ylabel('D(h)');
%   grid on;
%   legend('Predrug','Postdrug');
%
% See also WTMM, WFBM

%   Copyright 2016-2020 The MathWorks, Inc.


if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

narginchk(1,8)
nargoutchk(0,6)
validateattributes(x,{'numeric'},{'finite','vector','nonempty'});
params = parseinputs(varargin{:});
wname = params.wname;
% Mininum regression level
j1 = params.j1;

wtype = wavemngr('type',wname);
if wtype == 1 || wtype == 2
    [Lo,Hi] = wfilters(wname);
else
    error(message('Wavelet:mfa:OrthorBiorthWavelet'));
end


x = x(:)';
[leaders,scales,ncount] = wavelet.internal.dwtleaders(x,Lo,Hi);
% Determine default maximum level
J = find(ncount>=6,1,'last');
% Check if user has specified a maximum regression level
if isfield(params,'J')
    if params.J <= J
        J = params.J;
    else
        error(message('Wavelet:mfa:MaxRegressionLevel',J));
    end
end

if J < j1+1
    error(message('Wavelet:mfa:RegressionLevels'));
end

Nq = numel(params.q);
Nest = length(ncount);
Dq = zeros(Nq,Nest);
Hq = zeros(Nq,Nest);
Cp = zeros(params.cumulant,Nest);
zetaq = zeros(Nq,Nest);
% Compute wavelet multiresolution structure functions
% Structure function computation includes finest-scale "leaders"
% Regression does not
for jj = 1:Nest
    [zetaq(:,jj),Dq(:,jj), Hq(:,jj), Cp(:,jj)] = ...
        wavelet.internal.mfstructfunctions(abs(leaders{jj}),params);
end


Cp = Cp*log2(exp(1));
Y = [zetaq; Dq; Hq; Cp];
xj = log2(scales);

Y = Y(:,j1:J);
xj = xj(j1:J);
ncount = ncount(j1:J);

% Leaders are not defined at level 1 but we use their quantities in the
% regression
leaders = leaders(2:end);
% Forming multiresolution structure functions
structfunc.Tq = Y';
if strcmpi(params.weight,'scale')
    structfunc.weights = ncount;
elseif strcmpi(params.weight,'uniform')
    structfunc.weights = ones(size(ncount));
end
structfunc.logscales = xj;
% Create design matrix
X = ones(length(structfunc.logscales),2);
X(:,2) = structfunc.logscales;
% Least-squares regression with weigths
betahat = lscov(X,structfunc.Tq,structfunc.weights);
% Ignore intercept terms -- use only slopes
betahat = betahat(2,:);
zq = betahat(1:Nq);
dh = betahat(Nq+1:2*Nq)+1;
h = betahat(2*Nq+1:3*Nq);
cp = betahat(3*Nq+1:end);




function params = parseinputs(varargin)

params.wname = 'bior1.5';
params.j1 = 3;
params.q = -5:5;
params.cumulant = 3;
params.weight = 'uniform';
if isempty(varargin)
    return;
end

tf = find(strncmpi(varargin,'MinRegressionLevel',2));
if nnz(tf) == 1
    params.j1 = varargin{tf+1};
    validateattributes(params.j1,{'numeric'},{'scalar','integer', '>=',2},...
        'dwtleader','MinRegressionLevel');
    varargin(tf:tf+1) = [];
    if isempty(varargin)
        return;
    end
end

tf = find(strncmpi(varargin,'MaxRegressionLevel',2));
if nnz(tf) == 1
    params.J = varargin{tf+1};
    validateattributes(params.J,{'numeric'},{'scalar','integer', ...
        '>=',params.j1+1},'dwtleader','MaxRegressionLevel');
    varargin(tf:tf+1) = [];
    if isempty(varargin)
        return;
    end
end

tf = find(strncmpi(varargin,'RegressionWeight',1));
if nnz(tf) == 1
    params.weight = varargin{tf+1};
    validweights = {'uniform','scale'};
    params.weight = validatestring(params.weight,validweights);
    varargin(tf:tf+1) = [];
    if isempty(varargin)
        return;
    end
end

% Only remaining varargin argument must be wavelet
tf = cellfun(@(x)ischar(x),varargin);
if nnz(tf) == 1
    params.wname = varargin{tf>0};
    varargin(tf>0) = [];
else
    error('Invalid');
end

if ~isempty(varargin)
    error(message('Wavelet:mfa:UnsupportedSyntax'));
end






















