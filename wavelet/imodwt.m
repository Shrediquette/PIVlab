function xrec = imodwt(w,varargin)
%IMODWT Inverse maximal overlap discrete wavelet transform.
%   XREC = IMODWT(W) returns the reconstructed signal based on the maximal
%   overlap discrete wavelet transform (MODWT) coefficients in W. W is a
%   LEV+1-by-N or LEV+1-by-N-by-NSIG array which is the MODWT of an N-point
%   input signal, or N-by-NSIG matrix down to level LEV. By default, IMODWT
%   assumes that you used the 'sym4' wavelet with periodic boundary
%   handling to obtain the MODWT. If you do not modify the coefficients,
%   XREC is a perfect reconstruction of the signal.
%
%   XREC = IMODWT(W,WNAME) reconstructs the signal using the wavelet WNAME.
%   WNAME must be the same wavelet used in the analysis of the signal with
%   MODWT.
%
%   XREC = IMODWT(W,Lo,Hi) reconstructs the signal using the scaling
%   filter Lo and the wavelet filter Hi. You cannot specify both WNAME and
%   Lo and Hi. Lo and Hi must be the same filters used in the analysis with
%   MODWT.
%
%   XREC = IMODWT(...,RECONLEV) reconstructs the signal up to level
%   RECONLEV. XREC is a projection onto the scaling space at RECONLEV.
%   RECONLEV is a nonnegative integer between 0 and strictly less than
%   size(W,1)-1, which is the level of the wavelet transform. The default
%   is RECONLEV = 0, which results in perfect reconstruction if you do not
%   modify the coefficients.
%
%   XREC = IMODWT(...,'reflection') uses the 'reflection' boundary
%   condition in the reconstruction. If you specify 'reflection', IMODWT
%   assumes that the column size of W is even and equals twice the length
%   of the original signal. You must enter the entire string 'reflection'.
%   If you added a wavelet named 'reflection' using the wavelet manager,
%   you must rename that wavelet prior to using this option. 'reflection'
%   may be placed in any position in the input argument list after W. By
%   default both MODWT and IMODWT assume periodic signal extension at the
%   boundary.
%
%   %Example 1:
%   %   Demonstrate perfect reconstruction of ECG data with the MODWT. The
%   %   ECG waveform has a power-of-two length. However, both MODWT and
%   %   IMODWT work with arbitrary input lengths. Remove the last sample to
%   %   obtain an odd length time series and demonstrate perfect
%   %   reconstruction.
%
%   load wecg;
%   wecg = wecg(1:end-1);
%   w = modwt(wecg,'sym4',10);
%   xrec = imodwt(w);
%   max(abs(xrec-wecg'))
%   subplot(2,1,1)
%   plot(wecg); title('Original Signal');
%   subplot(2,1,2)
%   plot(xrec); title('Reconstructed Signal');
%
%   %EXAMPLE 2:
%   %   Reconstruct a signal approximation based on the level-3 and
%   %   level-4 wavelet coefficients. Remove the last sample of the time
%   %   series to show reconstruction with a signal length which is not
%   %   a power of two.
%
%   load wecg;
%   wecg = wecg(1:end-1);
%   w = modwt(wecg,'db2',10);
%   idx = 3:4;
%   wnew = w(idx,:);
%   xrec = imodwt(wnew);
%   subplot(2,1,1)
%   plot(wecg); title('Original Signal');
%   subplot(2,1,2)
%   plot(xrec);
%   title('Reconstruction from Level-3 and Level-4 Wavelet Coefficients');
%
%   %Example
%   %   Reconstruct multichannel signal. Plot the original data along with
%   %   the inverted wavelet transform.
%   load Espiga3
%   wt = modwt(Espiga3);
%   xrec = imodwt(wt);
%   subplot(2,1,1)
%   plot(Espiga3)
%   subplot(2,1,2)
%   plot(xrec)
%
%   See also modwt, modwtmra, modwtvar, modwtcorr, modwtxcorr

%   Copyright 2014-2021 The MathWorks, Inc.

% Check number of input arguments
narginchk(1,5);

% Input cannot be a row or column vector. IMODWT expects at least a two row
% matrix
if (isrow(w) || iscolumn(w))
    error(message('Wavelet:modwt:InvalidCFSSize'));
end

% Input must be real-value, finite, and double precision
validateattributes(w,{'double','single'},{'3d','nonnan','finite'});
isReal = isreal(w);
%isReal = 0;

% Parse input arguments
params = parseinputs(varargin{:});

% Get the original input size
% Get the level of the MODWT
N = size(w,2);
Nrep = N;
J = size(w,1)-1;


boundary = params.boundary;
if (~isempty(boundary) && ~strcmpi(boundary,'reflection'))
    error(message('Wavelet:modwt:Invalid_Boundary'));
end

% Adjust final output length if MODWT obtained with 'reflection'
if strcmpi(boundary,'reflection')
    N = N/2;
end

% If the wavelet is specified as a string, obtain filters from wavemngr
if (isfield(params,'wname') && ~isfield(params,'Lo'))
    [~,~,Lo,Hi] = wfilters(params.wname);
    wtype = wavemngr('type',params.wname);
    if (wtype ~= 1)
        error(message('Wavelet:modwt:Orth_Filt'));
    end
end

%If scaling and wavelet filters specified as vectors, ensure they
%satisfy the orthogonality conditions

if (isfield(params,'Lo') && ~isfield(params,'wname'))
    Lo = params.Lo;
    Hi = params.Hi;
end

% Scale scaling and wavelet filters for MODWT
Lo = Lo./sqrt(2);
Hi = Hi./sqrt(2);
% Ensure these are row vectors
Lo = Lo(:)';
Hi = Hi(:)';
Lo = cast(Lo,'like',w);
Hi = cast(Hi,'like',w);

% If the number of samples is less than the length of the scaling filter
% we have to periodize the data and then truncate.
if (Nrep<numel(Lo))
    % Works for rank 2 and rank 3 tensors
    w = [w repmat(w,1,ceil(numel(Lo)-Nrep),1)];
    Nrep = size(w,2);
end

% Get the DFTs of the scaling and wavelet filters
G = fft(Lo,Nrep);
H = fft(Hi,Nrep);

% Get the level of the reconstruction
lev = params.lev+1;

% Error
if (lev>J)
    error(message('Wavelet:modwt:Incorrect_ReconLevel'));
end

% Works for rank 2 and rank 3 tensors
vin = w(J+1,:,:);

% IMODWT algorithm

for jj = J:-1:lev
    vout = imodwtrec(vin,w(jj,:,:),G,H,jj,isReal);
    vin = vout;
end

% Return proper output length
xrec = squeeze(vout(:,1:N,:));

%-----------------------------------------------------------------
function Vout = imodwtrec(Vin,Win,G,H,J,isReal)
N = size(Vin,2);
Vhat = fft(Vin,[],2);
What = fft(Win,[],2);
upfactor = 2^(J-1);
Gup = conj(G(1+mod(upfactor*(0:N-1),N)));
Hup = conj(H(1+mod(upfactor*(0:N-1),N)));
if isReal
    Vout = ifft(Gup.*Vhat+Hup.*What,'symmetric');
else
    Vout = ifft(Gup.*Vhat+Hup.*What);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function params = parseinputs(varargin)
% Parse varargin and check for valid inputs
% First convert any strings to chars
[varargin{:}] = convertStringsToChars(varargin{:});

% Assign default inputs
params.boundary = [];
params.lev = 0;
params.wname = 'sym4';


% Check for 'reflection' boundary
tfbound = strcmpi(varargin,'reflection');

% Determine if 'reflection' boundary is specified
if any(tfbound)
    params.boundary = varargin{tfbound>0};
    varargin(tfbound>0) = [];
end

% If boundary is the only input in addition to the data, return with
% defaults
if isempty(varargin)
    return;
end

% Only remaining char variable must be wavelet name
tfchar = cellfun(@ischar,varargin);

if (nnz(tfchar) == 1)
    params.wname = varargin{tfchar>0};
elseif nnz(tfchar) > 1
    error(message('Wavelet:modwt:WaveletName'));
    
end

% Only scalar input must be the level
tfscalar = cellfun(@isscalar,varargin);

% Check for numeric inputs
tffilters = cellfun(@isnumeric,varargin);

% At most 3 numeric inputs are supported
if nnz(tffilters)>3
    error(message('Wavelet:modwt:Invalid_Numeric'));
end

% If there are at least two numeric inputs, the first two must be the
% scaling and wavelet filters

if (nnz(tffilters)>1)
    idxFilt = find(tffilters,2,'first');
    params.Lo = varargin{idxFilt(1)};
    params.Hi = varargin{idxFilt(2)};
    if (length(params.Lo) < 2 || length(params.Hi) < 2)
        error(message('Wavelet:modwt:Invalid_Filt_Length'));
    end
    params = rmfield(params,'wname');
end


% Any scalar input must be the level
if any(tfscalar)
    tmplev = gather(varargin{tfscalar > 0});
    validateattributes(tmplev,{'numeric'},{'integer','finite'},...
        'IMODWT','RECONLEV');
    params.lev = cast(tmplev,'double');
end

% If the user specifies a filter, use that instead of default wavelet
if (isfield(params,'Lo') && any(tfchar))
    error(message('Wavelet:FunctionInput:InvalidWavFilter'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
