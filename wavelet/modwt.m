function w = modwt(x,varargin)
%MODWT Maximal overlap discrete wavelet transform.
%   W = MODWT(X) computes the maximal overlap discrete wavelet transform
%   (MODWT) of X. X can be a real- or complex-valued vector or matrix. If X
%   is a matrix, MODWT operates on the columns of X. If X is a vector, it
%   must contain at least two samples. If X is a matrix, the row dimension
%   of X must be at least 2. By default, the maximal overlap discrete
%   wavelet transform is computed down to level floor(log2(length(X))) if X
%   is a vector and floor(log2(size(X,1))) if X is a matrix. MODWT uses
%   the Daubechies least-asymmetric wavelet with 4 vanishing moments
%   ('sym4') and periodic boundary handling. W contains the wavelet
%   coefficients and final-level scaling coefficients of X. W is a
%   LEV+1-by-N matrix if X is a vector and a LEV+1-by-N-by-NC array if X is
%   a matrix where NC is the number of columns in X. LEV is the level of
%   the wavelet transform. The m-th row of the array, W, contains the
%   wavelet (detail) coefficients for scale 2^m. The LEV+1-th row contains
%   the scaling coefficients for scale 2^LEV.
%
%   W = MODWT(X,WNAME) computes the MODWT using the wavelet, WNAME. WNAME
%   is a character vector denoting the name of an orthogonal wavelet.
%   Orthogonal wavelets are designated as type 1 wavelets in the
%   wavelet manager. Valid built-in orthogonal wavelet families begin with
%   'haar', 'dbN', 'fkN', 'coifN', 'blN', 'hanSR.LP', 'symN', 'vaid', or
%   'beyl'. Use waveinfo with the wavelet family short name to see
%   supported values for any numeric suffixes and how to interpret those
%   values, for example waveinfo('db'). You can check if your wavelet is
%   orthogonal by using wavemngr('type',wname) to see if a 1 is returned.
%   For example, wavemngr('type','db2'). If you have LO and HI as numeric
%   vectors, you can use ISORTHWFB to determine orthogonality. For example:
%   [~,~,Lo,Hi] = wfilters('db2');
%   [tf,checks] = isorthwfb(Lo,Hi);
%
%   W = MODWT(X,Lo,Hi) computes the MODWT using the scaling filter, Lo, and
%   the wavelet filter, Hi. Lo and Hi are even-length row or column
%   vectors. These filters must satisfy the conditions for an orthogonal
%   wavelet. You cannot specify both WNAME and a filter pair, Lo and Hi. To
%   agree with the usual convention in the implementation of MODWT
%   in numerical packages, the roles of the analysis and synthesis filters
%   returned by WFILTERS are reversed in MODWT. For example: 
%   wt = modwt(x,'db2') 
%   matches 
%   [~,~,Lo,Hi] = wfilters('db2') 
%   wt = modwt(x,Lo,Hi)
%
%   W = MODWT(...,LEV) computes the MODWT down to the level LEV. LEV is a
%   positive integer that cannot exceed floor(log2(N)) where N = length(x)
%   if X is a vector or N = size(X,1) if X is a matrix. If unspecified, LEV
%   defaults to floor(log2(N)).
%
%   W = MODWT(...,'reflection') uses reflection boundary handling by
%   extending the single- or multichannel signal symmetrically at the
%   terminal end to twice the signal length before computing the wavelet
%   transform. The number of wavelet and scaling coefficients returned are
%   twice the length of the input signal. By default, the signal is
%   extended periodically. You must enter the entire character vector
%   'reflection'. If you added a wavelet named 'reflection' using the
%   wavelet manager, you must rename that wavelet prior to using this
%   option. 'reflection' may be placed in any position in the input
%   argument list after X.
%
%   W = MODWT(...,'TimeAlign',ALIGNFLAG) circularly shifts the wavelet
%   coefficients at all levels (scales) and the scaling coefficients to
%   correct for the delay of the scaling and wavelet filters.  ALIGNFLAG is
%   a logical scalar. If unspecified, ALIGNFLAG defaults to false. Shifting
%   the coefficients is useful if you want to time align features in the
%   signal with the wavelet coefficients. If you want to reconstruct the
%   signal with the inverse MODWT, or obtain a multiresolution analysis
%   using MODWTMRA, do not shift the coefficients. In those cases, the time
%   alignment is performed in obtaining the inverse or multiresolution
%   analysis.
%
%   % Example 1:
%   %   Obtain the maximal overlap discrete wavelet transform of the Nile 
%   %   river minimum water level data. The data is 663 samples in length 
%   %   sampled yearly. Use the Haar wavelet and transform the data down 
%   %   to level 8. Plot the level-3 wavelet coefficients.
%    
%   load nileriverminima;
%   w = modwt(nileriverminima,'haar',8);
%   plot(w(3,:)); title('Level-3 Wavelet Coefficients');
%
%   % Example 2:
%   %   Check that the maximal overlap discrete wavelet transform 
%   %   partitions the variance of the signal by scale.
%
%   load noisdopp;
%   [~,~,Lo,Hi] = wfilters('sym8');
%   w = modwt(noisdopp,Lo,Hi,10);
%   varbylev = var(w,1,2);
%   sum(varbylev)
%   var(noisdopp,1)
%
%   %Example 3: 
%   %   Load the Espiga3 EEG dataset. The data consists of 23 EEG signals 
%   %   sampled at 200 Hz. Compute the maximal overlap discrete wavelet
%   %   transform down to the maximum level. Obtain the squared signal 
%   %   energies and compare them against the squared energies obtained 
%   %   from summing the wavelet coefficients over all levels. Use the log
%   %   squared energy due to the disproportionately large energy in one 
%   %   component.
%   load Espiga3
%   wt = modwt(Espiga3);
%   sigN2 = vecnorm(Espiga3).^2;
%   wtN2 = sum(squeeze(vecnorm(wt,2,2).^2));
%   bar(1:23,log(sigN2))
%   hold on
%   scatter(1:23,log(wtN2),'filled','SizeData',100)
%   alpha(0.75)
%   legend('Signal Energy','Energy in Wavelet Coefficients', ...
%       'Location','NorthWest')
%   xlabel('Channel'), ylabel('ln(squared energy)')
%   hold off
%
%   See also IMODWT MODWTMRA MODWTCORR MODWTXCORR DLMODWT

%   Copyright 2014-2022 The MathWorks, Inc.

% Check number of input arguments
narginchk(1,7);

% Validate that data is single- or double precision
validateattributes(x,{'double','single'},{'2d','nonnan','finite'});
isReal = isreal(x);

% If the signal is a rank-1 tensor, we will convert to column vector  
if isrow(x) || iscolumn(x)
    isVector = true;
else    
    isVector = false;
end

if isVector && isrow(x)
    % Convert data to column vector
    x = x(:);
end

% Get the row dimension of x. This works for rank-1 and rank-2 tensors
szX = size(x,1);
if szX < 2
    error(message('Wavelet:modwt:LenTwo'));
end


% Record original data length
datalength = szX;


%Parse input arguments
params = parseinputs(datalength,varargin{:});

%Check that the level of the transform does not exceed
%floor(log2(size(x,1))
J = params.J;
Jmax = floor(log2(datalength));
if (J <= 0) || (J > Jmax) 
    error(message('Wavelet:modwt:MRALevel'));
end

boundary = params.boundary;
if (~isempty(boundary) && ~strcmpi(boundary,'reflection'))
    error(message('Wavelet:modwt:Invalid_Boundary'));
end

% increase signal length if 'reflection' is specified
if strcmpi(boundary,'reflection')
    x = [x ; flip(x)];
end

% obtain new signal length if needed
siglen = size(x,1);
Nrep = siglen;


% If wavelet specified as a string, ensure that wavelet is orthogonal
if (isfield(params,'wname') && ~isfield(params,'Lo'))
    [~,~,Lo,Hi] = wfilters(params.wname);
    wtype = wavemngr('type',params.wname);
    if (wtype ~= 1)
        error(message('Wavelet:modwt:Orth_Filt'));
    end
end

%If scaling and wavelet filters are specified as vectors, ensure they
%satisfy the orthogonality conditions

if (isfield(params,'Lo') && ~isfield(params,'wname'))
    Lo = params.Lo;
    Hi = params.Hi;
end

% Scale the scaling and wavelet filters for the MODWT
Lo = Lo./sqrt(2);
Hi = Hi./sqrt(2);

% Ensure Lo and Hi are column vectors. These are real-valued.
Lo = Lo(:);
Hi = Hi(:);

% If X is complex-valued, this adds a zero-imaginary part to the filter.
Lo = cast(Lo,'like',x);
Hi = cast(Hi,'like',x);


% If the signal length is less than the filter length, need to 
% periodize the signal in order to use the DFT algorithm

if (siglen < numel(Lo))
    % This should work for an rank 1 or 3 tensor
    x = [x ; repmat(x,ceil(numel(Lo)-siglen),1)];
    Nrep = size(x,1);
end

% Allocate coefficient array. Include complexness of x.
w = zeros(J+1,Nrep,size(x,2),'like',x);

% Obtain the DFT of the filters
G = fft(Lo,Nrep);
H = fft(Hi,Nrep);


%Obtain the DFT of the data
Vhat = fft(x);

if isReal
    % Main MODWT algorithm
    for jj = 1:J
        [Vhat,What] = modwtdec(Vhat,G,H,jj);
        w(jj,:,:) = ifft(What,'symmetric');
        
    end
    w(J+1,:,:) = ifft(Vhat,'symmetric');
else
    for jj = 1:J
        [Vhat,What] = modwtdec(Vhat,G,H,jj);
        w(jj,:,:) = ifft(What);
        w(jj,:,:) = ifft(What);
    end
    w(J+1,:,:) = ifft(Vhat);

end

% Truncate data to length of boundary condition
if size(w,2) > siglen
    w = w(:,1:siglen,:);
end

if params.timealign
    w = wavelet.internal.modwtphaseshift(w,Lo,Hi);
end

%----------------------------------------------------------------------
function [Vhat,What] = modwtdec(X,G,H,J)
% [Vhat,What] = modwtfft(X,G,H,J)

N = size(X,1);
upfactor = 2^(J-1);
% Dilated filters modulo N
Gup = G(1+mod(upfactor*(0:N-1),N));
Hup = H(1+mod(upfactor*(0:N-1),N));
Vhat = Gup.*X;
What = Hup.*X;

%-------------------------------------------------------------------------
function params = parseinputs(siglen,varargin)
% Parse varargin and check for valid inputs
% First convert any strings to char arrays
[varargin{:}] = convertStringsToChars(varargin{:});
% Assign defaults 
params.boundary = [];
params.J = floor(log2(siglen));
params.wname = 'sym4';
params.timealign = false;
 
% Check for 'reflection' boundary      
tfbound = strcmpi(varargin,'reflection');
 
% Determine if 'reflection' boundary is specified
if any(tfbound)
    params.boundary = varargin{tfbound>0};
    varargin(tfbound>0) = [];
end

%Find if the timealign option is specified
alignmatches = find(strncmpi('timealign',varargin,1));

if any(alignmatches)
    aligntruefalse = varargin{alignmatches+1};
    %validate the value is logical
    validateattributes(aligntruefalse,{'numeric','logical'},{'scalar',...
        'finite','real'},'MODWT','TimeAlign');
    varargin(alignmatches:alignmatches+1) = [];
    params.timealign = aligntruefalse;
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

% There's one numeric argument and it's not a wavelet level
if (nnz(tffilters)==1) && (nnz(tfscalar) == 0)
    error(message('Wavelet:FunctionInput:InvalidLoHiFilters'));
end

% If there are at least two numeric inputs, the first two must be the
% scaling and wavelet filters
if (nnz(tffilters)>1)
    idxFilt = find(tffilters,2,'first');
    params.Lo = varargin{idxFilt(1)};
    params.Hi = varargin{idxFilt(2)};
    params = rmfield(params,'wname');
    
    if (length(params.Lo) < 2 || length(params.Hi) < 2)
        error(message('Wavelet:modwt:Invalid_Filt_Length'));
    end
    
end
 
% Any scalar input must be the level
if any(tfscalar)
    tmpJ = gather(varargin{tfscalar > 0});
    validateattributes(tmpJ,{'numeric'},{'integer','finite'},...
        'MODWT','LEV')
    params.J = cast(tmpJ,'double');
end
 
% If the user specifies a filter, use that instead of default wavelet
if (isfield(params,'Lo') && any(tfchar))
     error(message('Wavelet:FunctionInput:InvalidWavFilter'));
end
 
 

% [EOF] modwt.m

    
