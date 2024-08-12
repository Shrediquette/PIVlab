function [xcseq,xcseqci,lags] = modwtxcorr(w1,w2,varargin)
%MODWTXCORR Wavelet cross-correlation sequence estimates using the MODWT.
%   XCSEQ = MODWTXCORR(W1,W2) returns the wavelet cross-correlation
%   sequence estimates for the MODWT transforms in W1 and W2. W1 and W2
%   must be the same size and obtained with the same wavelet. By default,
%   MODWTXCORR assumes the 'sym4' wavelet was used. XCSEQ is a cell array
%   of (2NJ-1)-by-1 vectors where NJ is the number of nonboundary
%   coefficients by level. The length of XCSEQ is equal to the number of
%   levels in W1 and W2 with nonboundary coefficients. This level is the
%   minimum of size(W1,1) and floor(log2(N/(L-1)+1)) where N is the length
%   of the data and L is the filter length. The elements in each cell of
%   XCSEQ correspond to cross-correlation sequence estimates at lags from
%   -(NJ-1) to (NJ-1). The 0-th lag element is located at the index
%   floor((2*NJ-1)/2)+1. If there are sufficient nonboundary coefficients
%   at the final level, MODWTXCORR returns the scaling cross-correlation
%   sequence estimate in the final cell of XCSEQ.
%
%   XCSEQ = MODWTXCORR(W1,W2,WAV) uses the wavelet WAV to determine the
%   number of boundary coefficients by level. WAV can be a string
%   corresponding to a valid wavelet or a positive even integer indicating
%   the length of the wavelet filter. If WAV is unspecified or specified 
%   as empty, the default 'sym4' wavelet is used. The wavelet filter length
%   must match the length used in the MODWT of the inputs.
%
%   [XCSEQ,XCSEQCI] = MODWTXCORR(...) returns 95% confidence intervals for
%   the cross-correlation sequence estimates in XCSEQ. XCSEQCI is a cell
%   array of (2NJ-1)-by-2 matrices. The first column of the k-th element of
%   XCSEQCI contains the lower 95% confidence bound for the
%   cross-correlation coefficient at each lag. The second column contains
%   the upper 95% confidence bound. Confidence intervals are computed using
%   Fisher's Z-transformation. The N in the standard error of Fisher's Z
%   statistics, sqrt(N-3), is determined by the equivalent number of
%   coefficients in the critically sampled DWT, floor(size(w1,2)/2^LEV),
%   where LEV is the level of the wavelet transform. MODWTXCORR returns
%   NaNs for the confidence bounds when N-3 is less than or equal to zero.
%
%   [...] = MODWTXCORR(W1,W2,WAV,ConfLevel) uses ConfLevel for the
%   coverage probability of the confidence interval. ConfLevel is a real
%   scalar strictly greater than 0 and less than 1. If ConfLevel is
%   unspecified or specified as empty, the coverage probability defaults 
%   to 0.95. 
%
%   [XCSEQ,XCSEQCI,LAGS] = MODWTXCORR(...) returns the lags for the wavelet
%   cross-correlation sequence estimates. LAGS is a cell array of column
%   vectors the same length as XCSEQ. The elements of LAGS range from
%   -(NJ-1) to (NJ-1) where NJ is the number of nonboundary coefficients at
%   level J.
%
%   [...] = MODWTXCORR(...,'reflection') reduces the number of wavelet and
%   scaling coefficients at each scale by 1/2. Use this option when the
%   MODWT of W1 and W2 were obtained using the 'reflection' boundary
%   condition. You must enter the entire string 'reflection'. If you added
%   a wavelet named 'reflection' using the wavelet manager, you must rename
%   that wavelet prior to using this option. 'reflection' may be placed in
%   any position in the input argument list after the input transforms W1
%   and W2. Specifying the 'reflection' option in MODWTXCORR is equivalent
%   to first obtaining the MODWT of W1 and W2 with 'periodic' boundary
%   handling and then computing the wavelet cross-correlation sequence
%   estimates.
%
%   %Example 1:   
%   %   Plot the cross-correlation sequence estimate for the Southern
%   %   Oscillation Index and Truk Island pressure data for scale 2^5.
%   load soi
%   load truk
%   wsoi = modwt(soi);
%   wtruk = modwt(truk);
%   [xcseq,xcseqci,lags] = modwtxcorr(wsoi,wtruk);
%   plot(lags{5},xcseq{5},'linewidth',2)
%   hold on
%   plot(lags{5},xcseqci{5},'r--')
%   set(gca,'xlim',[-120 120]);
%   xlabel('Lag (Days)'); 
%   grid 
%   title({'Cross-Correlation Sequence Level 5'; 'Scale: 32-64 Days'});
%   hold off
%   
%   %Example 2:
%   %   Plot wavelet correlation for two 5-Hz sine wave signals with
%   %   additive noise.
%   dt = 0.01;
%   t = 0:dt:6;
%   x = cos(2*pi*5*t)+1.5*randn(size(t));
%   y = cos(2*pi*5*t-pi)+2*randn(size(t));
%   wx = modwt(x,'fk14',5);
%   wy = modwt(y,'fk14',5);
%   modwtcorr(wx,wy,'fk14')
%
%   % For the significant correlation at scale 4, plot the wavelet
%   % cross-correlation sequence
%   J = 4;
%   [xcseq,xcseqci,lags] = modwtxcorr(wx,wy,'fk14');
%   zerolag = floor(numel(lags{J})/2)+1;
%   lagidx = zerolag-30:zerolag+30;
%   plot(lags{J}(lagidx).*dt,xcseq{J}(lagidx));
%   hold on;
%   grid 
%   plot(lags{J}(lagidx).*dt,xcseqci{J}(lagidx,:),'r--');
%   xlabel('Lag (Seconds)');
%   title('Scale: 0.32-0.16 Seconds');
%   
%   See also MODWTCORR, MODWTVAR, MODWTMRA, MODWT, IMODWT

%   Copyright 2015-2020 The MathWorks, Inc.


% MODWTXCORR accepts between 2 and 5 inputs
narginchk(2,5);

% Ensure that the input has at least two rows
if (isrow(w1) || iscolumn(w1))
    error(message('Wavelet:modwt:InvalidCFSSize'));
end

% Ensure that the input matrices are the same size
% Ensure that the input matrices are the same size
if (numel(w1) ~= numel(w2))
    error(message('Wavelet:modwt:CFSMatrixSize'));
end

%Validate that the inputs are double-precision, real-valued with no
% NaNs or Infs
validateattributes(w1,{'double'},{'real','nonnan','finite'});
validateattributes(w2,{'double'},{'real','nonnan','finite'});

% Parse inputs
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

% For an unbiased estimate, keep only scales with nonboundary coefficients
Jmax = floor(log2((N-1)/(filtlen-1)+1));
if (Jmax<1)
     error(message('Wavelet:modwt:ZeroNonBoundaryCFS'));
 end
Jmax = min(Jmax,level);
w1 = w1(1:Jmax,1:N);
w2 = w2(1:Jmax,1:N);
V1 = V1(1:N);
V2 = V2(1:N);
 
 if (Jmax-level==0)
     scalingcorr = true;
 end
 
 % Remove boundary coefficients
cfs1 = removemodwtboundarycoeffs(w1,V1,N,Jmax,filtlen,scalingcorr);
[cfs2,MJ] = removemodwtboundarycoeffs(w2,V2,N,Jmax,filtlen,scalingcorr);

J = 1:Jmax;

if scalingcorr
    % If we are returning a correlation estimate of the scaling
    % coefficients
   J = [J Jmax];
end

% Adjust confidence level for symmetric distribution
ConfLevelComplement = 1-ConfLevel;
ConfLevelComplement = ConfLevelComplement/2;
ConfLevel = 1-ConfLevelComplement;

% Get critical value
qnorm = -sqrt(2)*erfcinv(2*ConfLevel);

xcseq = cell(numel(J),1);
xcseqci = cell(numel(J),1);
lags = cell(numel(J),1);


% The N in the Fisher Z-transformation for the cross-correlation
% coefficients comes from the critically-sampled DWT
NDWT = floor(size(w1,2) ./ 2.^J);

% calculate the estimator of the wavelet autocorrelation or
% cross-correlation sequence
for jj = 1:numel(J)
    cfsNoNaN1 = cfs1(jj,~isnan(cfs1(jj,:)));
    cfsNoNaN2 = cfs2(jj,~isnan(cfs2(jj,:)));
    [ccs,tau] = modwtCCS(cfsNoNaN1,cfsNoNaN2,MJ(jj));
    lowerci = real(tanh(atanh(ccs) - qnorm ./ sqrt(NDWT(jj)-3)));
    upperci = real(tanh(atanh(ccs)+qnorm./sqrt(NDWT(jj)-3)));
    xcseq{jj} = ccs';
    xcseqci{jj} = [lowerci' upperci'];
    lags{jj} = tau;
end

% For any NDWT<=3 replace confidence intervals with NaNs
if any(NDWT<=3)
 [xcseqci{NDWT<=3}] = deal(NaN(1,2));
end



%-----------------------------------------------------------------------
function [wccs,tau] = modwtCCS(cfs1,cfs2,MJ)
% Cross-correlation sequence estimation
N = size(cfs1,2);
fftpad = 2^nextpow2(2*N-1);
% floor the fftpad for the edge case that MJ = 1
zerolag = floor(fftpad/2)+1;
idxbegin = zerolag-(MJ-1);
idxend = zerolag+(MJ-1);
tau = (-(MJ-1):MJ-1)';
SSX = sum(abs(cfs1).^2);
SSY = sum(abs(cfs2).^2);
scalefactor = sqrt(SSX*SSY);
wccsDFT = fft(cfs1,fftpad).*conj(fft(cfs2,fftpad));
wccs = ifftshift(ifft(wccsDFT));
wccs = wccs(idxbegin:idxend);
wccs = wccs./scalefactor;

%-----------------------------------------------------------------------
function params = parseinputs(varargin)
% Parse inputs
% First convert any strings to char arrays
[varargin{:}] = convertStringsToChars(varargin{:});
params.boundary = 'periodic';
params.L = 8;
params.ConfLevel = 0.95;
    
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
% Handle cases where the wavelet is a string, or a scalar, or a vector, or
% empty

    if ischar(wavlen)
        [~,~,Lo,~] = wfilters(wavlen);
        params.L = length(Lo);
    elseif isscalar(wavlen)
        params.L = wavlen;
    elseif (isrow(wavlen) || iscolumn(wavlen))
        params.L = length(wavlen);
    elseif isempty(wavlen)
        params.L = 8;
    else
        error(message('Wavelet:modwt:InvalidWavelet'));
    end
validateattributes(params.L,{'numeric'},{'real','positive','even'});

    if (Len>1)
        params.ConfLevel = varargin{2};
            if isempty(params.ConfLevel)
                params.ConfLevel = 0.975;
            end
    end

validateattributes(params.ConfLevel,{'double'},{'>',0,'<',1});



