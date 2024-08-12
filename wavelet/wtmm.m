function varargout = wtmm(x,varargin)
%Wavelet Transform Modulus Maxima
% HEXP = WTMM(X) returns an estimate of the global Holder exponent, HEXP,
% for the real-valued 1-D input signal, X. X must have at least 128
% samples. HEXP is estimated by regressing the mean log of the CWT maxima
% by scale on the log of the wavelet scales. The CWT is obtained using the
% 2nd derivative of Gaussian wavelet with 10 voices per octave. An
% equivalent syntax is: HEXP = WTMM(X,'ScalingExponent','global')
%
% [HEXP,TAUQ] = WTMM(X) returns an estimate of the partition function
% scaling exponents, TAUQ, for the linearly spaced Q-moments, -2:0.1:2.
% An equivalent syntax is [HEXP,TAUQ] = WTMM(X,'ScalingExponent','global')
%
% [HEXP,TAUQ] = WTMM(X,'MinRegressionScale',SCALE) uses only scales greater
% than or equal to SCALE in the estimate of the Holder exponent. SCALE is a
% positive scalar greater than or equal to 4. The MinRegressionScale
% name-value pair only affects global estimates. If unspecified,
% MinRegressionScale defaults to 4. There must be at least two scales to
% use in the estimation of the global Holder exponent.
%
% [HEXP,TAUQ,STRUCTFUNC] = WTMM(...) returns the multiresolution structure
% functions, STRUCTFUNC, for the global estimates. STRUCTFUNC is a
% structure array containing the following fields:
%
%   Tq: matrix of multiresolution quantities that depend jointly on time
%   and scale. Tq provides measurements of the input X at various scales.
%   Scaling phenomena in X imply a power-law relationship between the
%   moments of Tq and scale. For WTMM, Tq is a Ns-by-44 matrix where Ns is
%   the number of scales. The first 41 columns of Tq constitute the
%   scaling exponent estimates for each of the q-moments -2:0.1:2 by scale.
%   The last three columns correspond to the 1st, 2nd, and 3rd order
%   cumulants respectively by scale.
%
%   weights: Ns-by-1 vector of weights used in the regression estimates.
%   The weights correspond to the number of wavelet maxima at each scale.
%
%   logscales: Ns-by-1 vector with the base-2 logarithm of the scales used
%   as predictors in the regression.
%
% [LOCALHEXP,WT,WAVSCALES] = WTMM(X,'ScalingExponent','local') returns the
% continuous wavelet transform WT, the local Holder exponent estimates, and
% the scales used in the CWT, WAVSCALES. WT is a numel(WAVSCALES)-by-N
% matrix where N is the length of the input signal X. LOCALHEXP is a M-by-2
% array containing the sample of the local singularity in the first column
% and the estimated local Holder exponent in the second column. If there
% are no maxima lines that converge to the finest scale in the wavelet
% transform, LOCALEXP is an empty array.
%
% [...] = WTMM(...,'VoicesPerOctave',NV) uses NV voices per octave to
% determine the CWT, maxima lines, and fractal estimates. NV is an even
% integer between 8 and 32. If you do not specify the number of voices per
% octave, NV defaults to 10.
%
% [...] = WTMM(...,'NumOctaves',NO) uses NO octaves to determine the CWT,
% maxima lines, and fractal estimates. NO is an integer greater than or
% equal to 4. WTMM limits the number of octaves to be less than or equal to
% floor(log2(N/(3*sqrt(1.1666)))) where N is the length of the input data.
% The factor sqrt(1.1666) is the standard deviation of the 2nd derivative
% of Gaussian wavelet. NO defaults to the minimum of 7 and
% floor(log2(N/(3*sqrt(1.1666)))). If you specify NO greater than the
% maximum number of octaves, WTMM uses the maximum supported number.
%
% WTMM(...,'ScalingExponent','local') with no output arguments plots the
% wavelet maxima lines in the current figure. Estimates of the local Holder
% exponents are displayed in a table to the right of the plot.
%
%   % Example 1: Obtain local Holder exponents for cusp signal
%   %   Note at sample 241, this signal has Holder exponent of 0.5. At
%   %   sample 803, the signal has a Holder exponent of 0.3.
%   load cusp;
%   wtmm(cusp,'ScalingExponent','local');
%
%   % Example 2: Obtain local Holder exponents for two delta functions
%   %   located at sample 200 and sample 500. The local Holder exponents
%   %   of the delta functions should be -1 at these sample values.
%   x = zeros(1e3,1);
%   x([200 500]) = 1;
%   wtmm(x,'ScalingExponent','local','NumOctaves',6);
%
%   % Example 3: Estimate global Holder exponent for Brownian motion.
%   %   In theory, the Holder exponent should be around 0.5 for this 
%   %   monofractal process.
%   rng(100);
%   x = cumsum(randn(2^15,1));
%   hexp = wtmm(x);
%
%   See also DWTLEADER, WFBM

%   Copyright 2016-2020 The MathWorks, Inc.


if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

narginchk(1,7);
nargoutchk(0,3);
% Determine the number of outputs
nOutputs = nargout;
% Parse the input
p = inputParser;
defaultScaling = 'global';
expectedScaling = {'global','local'};
defaultnv = 10;
defaultno = 7;
defaultminRegScale = 4;
addRequired(p,'x',@(x)validateattributes(x,{'numeric'},{'real','finite',...
    'vector'}));
addParameter(p,'ScalingExponent',defaultScaling);
addParameter(p,'VoicesPerOctave',defaultnv,@(x)validateattributes(x,...
    {'numeric'},{'scalar','integer','even','>=',8,'<=',32}));
addParameter(p,'NumOctaves',defaultno,@(x)validateattributes(x,...
    {'numeric'},{'scalar','integer','>=',4,'finite'}));
addParameter(p,'MinRegressionScale',defaultminRegScale,...
    @(x)validateattributes(x,{'numeric'},{'scalar','positive','>=',2}));

% Parse the inputs to the function. Only required is the time series
parse(p,x,varargin{:});
scalexp = validatestring(p.Results.ScalingExponent,expectedScaling);

% Pad for global estimates
if strcmpi(scalexp,'global')
    pad = true;
else
    pad = false;
end

numoct = p.Results.NumOctaves;
nv = p.Results.VoicesPerOctave;
x = p.Results.x;
j1 = p.Results.MinRegressionScale;

% Detrend signal
x = detrend(x,0);
x = x(:)';
%Only supported 2nd derivative of Gaussian
wavname = 'dergauss2';


% Record original signal length
Norig = numel(x);
if Norig < 128
    error(message('Wavelet:mfa:WTMMLength'));
end
% 2 sigma_t for the 2nd derivative of Gaussian
sigma2 = 2*sqrt(1.1666);

% Determine maximum scale. For WTMM, keep the maximum scale from going
% too large
numoct = min(numoct,floor(log2(Norig/(3/2*sigma2))));
n = Norig;

if pad
    padvalue = floor(Norig/2);
    x =[fliplr(x(1:padvalue)) x x(end:-1:end-padvalue+1)];
    % Length of data plus any extension
    n = length(x);
end

ds = 1/nv;
a0 = 2^ds;

% Create scales
wavscales = a0.^(1:numoct*nv);
% Find the minimum scale greater than or equal to the MinRegressionScale

% determine the cone of influence at finest scale
% we will only trust local maxima that terminate inside the cone of
% influence at the finest scale
conofinfb = round(sigma2*wavscales(1));
% beginning and end of cone of influence
conofinfb = [conofinfb Norig-conofinfb];
NbSc = numel(wavscales);

% Create frequencies for real wavelet transform
omega = (1:fix(n/2));
omega = omega.*(2*pi)/n;
omega = [0, omega, -omega(fix((n-1)/2):-1:1)];

% Obtain the Fourier transform of the data and the wavelet filter bank
f = fft(x);
psift  = wavelet.internal.waveft(wavname,omega,wavscales);
% Obtain the CWT coefficients -- real-valued because the wavelet is
% real-valued and the signal is real-valued
cwtcfs = ifft(repmat(f,NbSc,1).*psift,[],2,'symmetric');

% Remove padding if necessary
if pad
    cwtcfs = cwtcfs(:,padvalue+1:padvalue+Norig);
end


% Determine the maximum map. This is the input to the structure function
% calculation and is used in the formation of the wavelet skeleton
% We need this map for both the local and global exponents.
maxmap  = wtmaxmap(cwtcfs',pad);
cfsmask = fliplr(maxmap)';
ncount = sum(cfsmask,2);




% Mask the CWT coefficients using the local maxima
wtmask = cwtcfs.*cfsmask;

% If the scaling exponent calculation is global, we need
% to compute the global estimates
if strcmpi(scalexp,'global')
    % We keep the index of the scale, not the actual scale.
    j1 = find(wavscales>=j1,1,'first');
    % Find terminal scale for regression
    J = find(ncount>=6,1,'last');
    % Check that there are at least two scales for the regression estimates
    if J < j1+1
        error(message('Wavelet:mfa:RegressionLevels'));
    end
    
    
    if ~any(wtmask(:))
        error(message('Wavelet:mfa:AllZeroCWT'));
    end
    
    Nest = size(wtmask,1);
    param.q = -2:0.1:2;
    Nq = numel(param.q);
    param.cumulant = 3;
    zetaq = zeros(Nq,Nest);
    Cp = zeros(param.cumulant,Nest);
    
    for jj = 1:Nest
        [zetaq(:,jj),~, ~, Cp(:,jj)] = ...
            wavelet.internal.mfstructfunctions(abs(wtmask(jj,:)),param);
    end
    
    Y = [zetaq; Cp*log2(exp(1))];
    xj = log2(wavscales);
    J = numel(wavscales);
    
    % Return scaling exponent results and
    structfunc.Tq = Y(:,j1:J)';
    structfunc.weights = ncount(j1:J);
    structfunc.logscales = xj(j1:J)';
    % Create design matrix
    X = ones(length(structfunc.logscales),2);
    X(:,2) = structfunc.logscales;
    % Weighted linear regression with multiple response variables
    betahat = lscov(X,structfunc.Tq,structfunc.weights);
    betahat = betahat(2,:);
    zq = betahat(1:Nq);
    cp = betahat(Nq+1:end);
    
    
    % If scaling exponents are local
elseif strcmpi(scalexp,'local')
    maxchains = wtskeleton(maxmap,nv,conofinfb);
    if ~isempty(maxchains)
        hlocal = zeros(numel(maxchains),1);
        tsamp = zeros(numel(maxchains),1);
        for kk = 1:numel(maxchains)
            [hexp,samp] = wavelet.internal.localholderexp(kk,maxchains,cwtcfs,wavscales);
            hlocal(kk) = hexp;
            tsamp(kk) = samp;
            
        end
        localHdata = [tsamp hlocal];
        
    else
        localHdata = [];
        
    end
end



if nOutputs == 0 && strcmpi(scalexp,'local')
    plotwavskeleton(cwtcfs,maxchains,wavscales,localHdata)
end

if strcmpi(scalexp,'global') 
    varargout{1} = cp(1);
    varargout{2} = zq;
    varargout{3} = structfunc;
    
    
elseif strcmpi(scalexp,'local') && nOutputs > 0
    varargout{1} = localHdata;
    varargout{2} = cwtcfs;
    varargout{3} = wavscales;
    
end




function maxmap = wtmaxmap(cwtcfs,pad)

% Get time and scale dimension of CWT
% here n is the number of samples and nscale is the number of scales
[n,nscale] = size(cwtcfs);
maxmap = zeros(n,nscale);


t      = 1:n;
tplus  = circshift(t,1,2);
tminus = circshift(t,-1,2);
wtmag  = fliplr(abs(cwtcfs));

for k = 1:nscale
    localmax =  ...
        wtmag(:,k) >= wtmag(tplus,k) & wtmag(:,k) >= wtmag(tminus,k);
    y =  localmax.* wtmag(:,k);
    nnzy = y(y>0);
    
    if pad
        medy = median(nnzy);
        maxmap(:,k) = (y>medy);
    else
        maxmap(:,k) = (y>0);
    end
    
    
end



function chains = wtskeleton(maxmap,nv,conofinfb)
% Chain together Ridges of Wavelet Transform
%  A chain is a list of maxima at essentially the same position
%  across a range of scales.
%  It is identified from the maxmap data structure output by WTMM
%  by finding a root at coarse scales and identifying the closest
%  maxima at the next finest scale.

% n is the number of time points
% nscale is the number of scales
% first column of maxmap is the coarsest scale
[n,nscale] = size(maxmap);


nchain = 0;
chains = zeros(size(maxmap));
count  = 0;

while any(any(maxmap))
    
    [i,j] = find(maxmap);
    % beginning chain formation
    iscale = j(1);
    ipos   = i(1);
    nchain = nchain+1;
    % at chain n and scale iscale, ipos gets a time position
    chains(nchain,iscale) = ipos;
    % zero out the maxmap
    maxmap(ipos,iscale) = 0;
    count = count+1;
    
    while(iscale < nscale)
        iscale = iscale+1;
        j = find(maxmap(:,iscale))';
        circdist   = min([ abs(j-ipos) ; abs(j-ipos+n); abs(j-ipos-n) ]);
        [~,pos] = min(circdist);
        if ~isempty(pos)
            ipos = j(pos);
            chains(nchain,iscale) = ipos;
            maxmap(ipos,iscale)   = 0;
            count = count+1;
        else
            iscale = nscale;
        end
    end
    
end

chaincell = cell(size(chains,1));
for kk = 1:size(chains,1)
    [~,j,v] = find(chains(kk,:));
    chaincell{kk} = [j' v']; 
end
% retain only nonempty cells
chains = chaincell(~cellfun(@isempty,chaincell));

%chains = chaincell;
chainLength = cellfun(@(x)numel(x(:,1)),chains);
chainEnd = cellfun(@(x)x(end,1),chains);
idxEnd = chainEnd == nscale;
idxLen = chainLength>=nv;
% what chains can we estimate Holder exponents for
chains = chains(idxEnd & idxLen);
rangechains = cellfun(@(x)max(x(:,2))-min(x(:,2)),chains);
idx = rangechains<=floor(n/4);
chains = chains(idx);
%Find chains that terminate in the cone of influence and remove those
cET = cellfun(@(x)(x(end,2)),chains);
insidecf = cET>conofinfb(1) & cET <conofinfb(2);
chains = chains(insidecf);
% Sort by chain end time
chainEndTime = cellfun(@(x)(x(end,2)),chains);
[~,idxsort] = sort(chainEndTime);
chains = chains(idxsort);




function plotwavskeleton(wt,chains,wavscales,hexpdata)
% Plot local maxima lines for zero output case
for kk = 1:numel(chains)
    chains{kk}(:,1) = flipud(chains{kk}(:,1));
end

f = gcf;
clf(f,'reset');
ax1 = axes(f);
f.Visible = 'off';
f.Units = 'normalized';
f.Position = [0.1 0.2 0.4 0.5];
movegui(f,'center');
f.Units = 'Pixels';

% Layout figure 
hl = wavelet.internal.layout.GridBagLayout(f);
hl.add(ax1, 1, 1,'Fill','both');
imagesc(ax1,1:size(wt,2),log2(wavscales),abs(wt));
hold(ax1,'on');
for kk = 1:numel(chains)
    scales = chains{kk}(:,1);
    plot(ax1,chains{kk}(:,2),log2(wavscales(scales)),'w','linewidth',0.1);
end
ylim(ax1,[min(log2(wavscales)) max(log2(wavscales))]);
xlim(ax1,[1 size(wt,2)]);
set(ax1,'ydir','reverse');
ylbl = getString(message('Wavelet:mfa:WTMMYlabel'));
ylabel(ax1,ylbl);
xlbl = getString(message('Wavelet:mfa:WTMMXlabel'));
xlabel(ax1,xlbl);
titl = getString(message('Wavelet:mfa:WTMMTitle'));
title(ax1,titl);
grid(ax1,'on');
hold(ax1,'off');
colnames = {getString(message('Wavelet:mfa:Table1stCol')); ...
    getString(message('Wavelet:mfa:Table2ndCol')) };
tbl = uitable('Parent',f, 'Data', hexpdata, 'ColumnName', colnames,...
    'units','pixels','visible','off');
tbl.BackgroundColor = [0.94 0.94 0.94];
hl.add(tbl, 1, 2,'Fill', 'Both', 'MinimumWidth', tbl.Extent(3));
hl.HorizontalWeights = [1 0];
hl.setConstraints(1, 2, 'TopInset', 5, 'RightInset', 7, 'BottomInset', 5);
hl.setConstraints(1,2, 'MinimumHeight', tbl.Extent(4), 'Fill', 'None',...
    'Anchor','North');
tbl.Visible = 'on';
f.Visible = 'on';
f.NextPlot = 'replace';












