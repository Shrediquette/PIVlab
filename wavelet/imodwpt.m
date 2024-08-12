function xrec = imodwpt(cfs,varargin)
%Inverse maximal overlap discrete wavelet packet transform
%   XREC = IMODWPT(CFS) returns the inverse maximal overlap discrete
%   wavelet packet transform for the terminal node coefficient matrix CFS
%   obtained using the 'fk18' wavelet.  IMODWPT only accepts the terminal
%   nodes of a wavelet packet tree. The input to IMODWPT must have been
%   obtained from MODWPT using the 'FullTree', false option. The 'FullTree'
%   false option is the default for MODWPT. XREC is a row vector with the
%   same number of columns as the coefficient matrix, CFS.
%
%   XREC = IMODWPT(CFS,WNAME) uses the wavelet specified in the character vector,
%   WNAME to invert the MODWPT. WNAME must be the same wavelet used in the
%   analysis with MODWPT.
%
%   XREC = IMODWPT(CFS,Lo,Hi) uses the scaling filter, Lo, and wavelet
%   filter, Hi, to invert the MODWPT. Lo and Hi must be the same filter
%   pair used in the MODWPT. You cannot specify both WNAME and a
%   scaling-wavelet filter pair.
%
%   %Example 1:
%   %   Obtain the MODWPT of an ECG waveform and demonstrate perfect
%   %   reconstruction using the inverse MODWPT.
%   load wecg;
%   wpt = modwpt(wecg);
%   xrec = imodwpt(wpt);
%   subplot(2,1,1)
%   plot(wecg); title('Original ECG Waveform');
%   subplot(2,1,2)
%   plot(xrec); title('Reconstructed ECG Waveform');
%   max(abs(wecg-xrec'))
%
%   See also modwpt, modwptdetails

%   Copyright 2015-2020 The MathWorks, Inc.

% Number of input arguments is between 1 and 4.
% If the user specifies both the WNAME and Lo, Hi inputs, we ignore
% WNAME

narginchk(1,4);
% Input must a real-valued matrix with no Infs or NaNs
validateattributes(cfs,{'double'},{'real','finite'},'imodwpt','CFS');

% The terminal level must be at least j=1, which means that cfs must have
% two rows
if (isrow(cfs) || iscolumn(cfs))
    error(message('Wavelet:modwt:InvalidCFSSize'));
end
NumPackets = size(cfs,1);

% The number of rows in the matrix must be a power of two
if any(rem(log2(NumPackets),1))
    error(message('Wavelet:modwt:InvalidTermSize'));
end

%The level of the transform
level = log2(NumPackets);

%Parse inputs
params = parseinputs(varargin{:});


if isfield(params,'wname')
    [~,~,LoD,HiD] = wfilters(params.wname);
    % Normalize filters for MODWPT
    Lo = LoD./sqrt(2);
    Hi = HiD./sqrt(2);
else
    Lo = params.Lo./sqrt(2);
    Hi = params.Hi./sqrt(2);
end

% Ensure Lo and Hi are row vectors
Lo = Lo(:)';
Hi = Hi(:)';


% If the coefficient length is less than the filter length, need to
% periodize the signal in order to use the DFT algorithm
N = size(cfs,2);
Nrep = N;

%For the edge case where the number of samples is less than the scaling
%filter
if (N <numel(Lo))
    cfs = [cfs repmat(cfs,1,ceil(numel(Lo)-N))];
    Nrep = size(cfs,2);
end

% Obtain the DFT of the filters
G = fft(Lo,Nrep);
H = fft(Hi,Nrep);


for jj = level:-1:1
    kk = 1;
    upcfs = zeros(size(cfs,1)/2,Nrep);
    index = 0;
    for nn = 0:2^jj/2-1
        index = index+1;
        if iseven(nn)
            upcfs(index,:) = EvenInvert(cfs(kk,:),cfs(kk+1,:),G,H,jj);
        else
            upcfs(index,:) = OddInvert(cfs(kk,:),cfs(kk+1,:),G,H,jj);
        end
        kk = kk+2;
    end
    cfs = upcfs;
end

%Ensure output length matches the number of columns in the input
xrec = cfs(1:N);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function evencfs = EvenInvert(even,odd,G,H,J)

N = numel(even);
evendft = fft(even);
odddft = fft(odd);
upfactor = 2^(J-1);
Gup = conj(G(1+mod(upfactor*(0:N-1),N)));
Hup = conj(H(1+mod(upfactor*(0:N-1),N)));
evencfs = ifft(Gup.*evendft+Hup.*odddft);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function oddcfs = OddInvert(even,odd,G,H,J)
N = numel(even);
evendft = fft(even);
odddft = fft(odd);
upfactor = 2^(J-1);
Gup = conj(G(1+mod(upfactor*(0:N-1),N)));
Hup = conj(H(1+mod(upfactor*(0:N-1),N)));
oddcfs = ifft(Gup.*odddft+Hup.*evendft);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function params = parseinputs(varargin)
% Parse varargin and check for valid inputs
% First convert any varargin strings to char
[varargin{:}] = convertStringsToChars(varargin{:});
%Default wavelet is Fejer-Korovkin (18)
params.wname = 'fk18';

%If there are no varargin inputs, return
if isempty(varargin)
    return;
end

% Only remaining char variable must be wavelet name
tfchar = cellfun(@ischar,varargin);
if (nnz(tfchar) == 1)
    params.wname = varargin{tfchar>0};
elseif nnz(tfchar)>1
    error(message('Wavelet:FunctionInput:InvalidChar'));
end

tffilters = cellfun(@isnumeric,varargin);
% If there are at least two numeric inputs, the first two must be the
% scaling and wavelet filters
if (nnz(tffilters)==2)
    idxFilt = find(tffilters,2,'first');
    params.Lo = varargin{idxFilt(1)};
    params.Hi = varargin{idxFilt(2)};
    LengthCheck = isodd([numel(params.Lo) numel(params.Hi)]);
    LengthCheck(end+1) = ~isequal(numel(params.Lo),numel(params.Hi));
    
    if any(LengthCheck)
        error(message('Wavelet:modwt:Invalid_Filt_Length'));
    end
    params = rmfield(params,'wname');
    
end

% If the user specifies a filter, use that instead of default wavelet
if (isfield(params,'Lo') && any(tfchar))
    error(message('Wavelet:FunctionInput:InvalidWavFilter'));
end

