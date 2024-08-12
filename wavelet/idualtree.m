function xrec = idualtree(yl,yh,varargin)
% 1-D Inverse Kingsbury Q-shift Dual-tree complex wavelet transform
%   XREC = IDUALTREE(A,D) returns the inverse 1-D complex dual-tree
%   transform of the final-level approximation coefficients, A, and cell
%   array of wavelet coefficients, D. A and D are outputs of DUALTREE.
%   IDUALTREE uses the orthogonal Q-shift filter of length 10 and
%   near-symmetric biorthogonal filter pair with lengths 7 (scaling
%   synthesis filter) and 5 (wavelet synthesis filter) in the
%   reconstruction.
%
%   XREC = IDUALTREE(A,D,'LevelOneFilter',FSF) uses the biorthogonal
%   filter, FSF, as the first-level synthesis filter. Valid options for 
%   FSF are 'nearsym5_7', 'nearsym13_19', 'antonini', or 'legall'. 
%   If unspecified, FSF defaults to 'nearsym5_7'. 
%   The first-level synthesis filters must match the first-level analysis
%   filters used in DUALTREE for perfect reconstruction.
%
%   XREC = IDUALTREE(A,D,'FilterLength',FLEN) uses the Q-shift Hilbert
%   synthesis filter pair of length FLEN. Valid options for FLEN are 6, 10,
%   14, 16, or 18. If unspecified, FLEN defaults to 10. The synthesis
%   filter length used in IDUALTREE must match the analysis filter length
%   in DUALTREE for perfect reconstruction.
%
%   XREC = IDUALTREE(...,'DetailGain',DGAIN) sets the gain for the wavelet
%   coefficient subbands for use in the reconstruction. DGAIN is a column
%   vector of LEV elements where LEV is the number of elements in D. The
%   elements DGAIN are real numbers in the interval [0,1]. The k-th element
%   of DGAIN is the gain, or weighting applied to the k-th wavelet subband.
%   By default, DGAIN is a vector of LEV ones.
%
%   XREC = IDUALTREE(...,'LowpassGain',LPGAIN) sets the gain for the
%   lowpass (scaling) coefficients for use in the reconstruction. LPGAIN
%   is a real number in the interval [0,1]. 
%
%   %Example Obtain the dual-tree wavelet transform of a signal and 
%   %   reconstruct an approximation using all but the two finest-detail
%   %   wavelet subbands.
%   load noisdopp
%   [A,D] = dualtree(noisdopp);
%   dgain = ones(numel(D),1);
%   dgain(1:2) = 0;
%   xrec = idualtree(A,D,'DetailGain',dgain);
%   plot([noisdopp' xrec])
%   axis tight, grid on;
%
%   See also dualtree, qbiorthfilt, qorthwavf

%   Kingsbury, N.G. (2001) Complex wavelets for shift invariant analysis 
%   and filtering of signals, Journal of Applied and Computational Harmonic
%   Analysis, vol 10, no. 3, pp. 234-253.


%   Copyright 2019-2020 The MathWorks, Inc.
%#codegen 


narginchk(2,10);
nargoutchk(0,1);
validateattributes(yh,{'cell'},{'nonempty'});


% The number of cell arrays in the wavelet coefficients gives the number of
% levels
Nlev = numel(yh);
params = parseinputs(Nlev,varargin{:});
[~,~,LoR,HiR] = qbiorthfilt(params.biorth);
LoR = cast(LoR,'like',yl);
HiR = cast(HiR,'like',yl);
[~,~,~,~,LoRa,LoRb,HiRa,HiRb] = qorthwavf(params.qlen);
LoRa = cast(LoRa,'like',yl);
LoRb = cast(LoRb,'like',yl);
HiRa = cast(HiRa,'like',yl);
HiRb = cast(HiRb,'like',yl);
% Cast gain
if coder.target('MATLAB')
    dgain = cast(params.detailgain,'like',yl);
    lpgain = cast(params.lpgain,'like',yl);
else
    dgain = coder.nullcopy(zeros(size(params.detailgain),'like',yl));
    for kk = 1:numel(params.detailgain)
        dgain(kk) = cast(params.detailgain(kk),'like',yl);
    end
    lpgain = cast(params.lpgain,'like',yl);
end
        

% Check size of lowpass filter coefficients to ensure they are even
Nscal = size(yl,1);
tfS = signalwavelet.internal.iseven(Nscal);
coder.internal.errorIf(~tfS,'Wavelet:dualtree:EvenLengthInput');


% Scaling coefficients are the real-valued yl vector
coder.varsize('Lo');
Lo= yl;

coder.varsize('dtmp');
dtmp = yh;

% If the decomposition only has one level, the following for loop is
% skipped
kk = Nlev;
while kk >= 2
    % interleave the wavelet details up to the resolution of the 
    Hi = cinterleave(dtmp{kk}*dgain(kk));
    Lo = ...
        real(wavelet.internal.invcolumnfilter(Lo,LoRb,LoRa)+wavelet.internal.invcolumnfilter(Hi,HiRb,HiRa));
    if kk == Nlev
        Lo = Lo*lpgain;
    end
    % Now we check the length of the projection onto the scaling space
    % against the length of the next finer resolution details
    if size(Lo,1) ~= 2*size(dtmp{kk-1},1)
        Lo = Lo(2:end-1,:);
    end
    kk = kk-1;
end

% To obtain reconstruction, use the first-level biorthogonal filters
Hi = cinterleave(dtmp{1}*dgain(kk));
xrec = ...
    real(wavelet.internal.colfilter(Lo,LoR)+wavelet.internal.colfilter(Hi,HiR));
 


%-------------------------------------------------------------------------
function yi = cinterleave(x)
% yi = cinterleave(x) interleave real and imaginary parts of complex
% wavelet coefficients

% Input is always column vector
[nr,nc] = size(x);
nrout = 2*nr;
% Allocate array
yi = coder.nullcopy(zeros(nrout,nc,'like',x));
yi(1:2:nrout,:) = real(x);
yi(2:2:nrout,:) = imag(x);

%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function params = parseinputs(Nlev,varargin)
% Set default mask
defaultDgain = ones(Nlev,1);
defaultLPGain = 1;
% Set default Q-shift filter length
defaultQlen = 10;
validQ = @(x)ismember(x,[6 10 14 16 18]);
% Set default biorthogonal filter
defaultBiorth = 'nearsym5_7';
validBiorth = {'nearsym5_7','nearsym13_19','antonini','legall'};

if coder.target('MATLAB')
    p = inputParser;
    addParameter(p,'LevelOneFilter',defaultBiorth);
    addParameter(p,'FilterLength',defaultQlen);
    addParameter(p,'DetailGain',defaultDgain);
    addParameter(p,'LowpassGain',1);
    p.parse(varargin{:});
    params.biorth = p.Results.LevelOneFilter;
    params.qlen = p.Results.FilterLength;
    params.detailgain = p.Results.DetailGain;
    params.lpgain = p.Results.LowpassGain;
    
    
else
    parms = struct('LevelOneFilter',uint32(0),...
        'FilterLength',uint32(0),...
        'DetailGain',uint32(0),...
        'LowpassGain',uint32(0));
    popts = struct('CaseSensitivity',false, ...
        'PartialMatching',true);
    
    pstruct = coder.internal.parseParameterInputs(parms,popts,varargin{:});
    params.biorth = ...
        coder.internal.getParameterValue(pstruct.LevelOneFilter,defaultBiorth,varargin{:});
    params.qlen = ...
        coder.internal.getParameterValue(pstruct.FilterLength,defaultQlen,varargin{:});
    params.detailgain = ...
        coder.internal.getParameterValue(pstruct.DetailGain,defaultDgain,varargin{:});
    params.lpgain = ...
        coder.internal.getParameterValue(pstruct.LowpassGain,defaultLPGain,varargin{:});
    
    
    
    
end

validateattributes(params.detailgain,{'double','single'},{'vector',...
    'numel',Nlev,'>=',0,'<=',1},'idualtree','DetailGain');
validateattributes(params.lpgain,{'double','single'},{'scalar', '>=',0,...
    '<=',1},'idualtree','LowpassGain');    
params.biorth = validatestring(params.biorth,validBiorth,'idualtree',...
    'LevelOneFilter');
tfQ = validQ(params.qlen);
coder.internal.errorIf(~tfQ,'Wavelet:dualtree:UnsupportedQ');





