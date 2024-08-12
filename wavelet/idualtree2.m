function imrec = idualtree2(yl,yh,varargin)
% 2-D Inverse Kingsbury Q-shift Dual-tree complex wavelet transform
%   IMREC = IDUALTREE2(A,D) returns the inverse 2-D complex dual-tree
%   transform of the final-level approximation coefficients, A, and cell
%   array of wavelet coefficients, D. A and D are outputs of DUALTREE2.
%   IDUALTREE2 uses the orthogonal Q-shift filter of length 10 and
%   near-symmetric biorthogonal filter pair with lengths 7 (scaling
%   synthesis filter) and 5 (wavelet synthesis filter) in the
%   reconstruction.
%
%   IMREC = IDUALTREE2(A,D,'LevelOneFilter',FSF) uses the biorthogonal
%   filter, FSF, as the first-level synthesis filter. Valid options for 
%   FSF are 'nearsym5_7', 'nearsym13_19', 'antonini', or 'legall'. 
%   If unspecified, FSF defaults to 'nearsym5_7'. 
%   The first-level synthesis filters must match the first-level analysis
%   filters used in DUALTREE2 for perfect reconstruction.
%
%   IMREC = IDUALTREE2(A,D,'FilterLength',FLEN) uses the Q-shift Hilbert
%   synthesis filter pair of length FLEN. Valid options for FLEN are 6, 10,
%   14, 16, or 18. If unspecified, FLEN defaults to 10. The synthesis
%   filter length used in IDUALTREE2 must match the analysis filter length
%   in DUALTREE2 for perfect reconstruction.
%
%   IMREC = IDUALTREE2(...,'DetailGain',G) sets the gain for the wavelet
%   coefficient subbands for use in the reconstruction. DGAIN is a matrix
%   with a row dimension of LEV where LEV is the number of elements in D.
%   There are six columns in DGAIN for each of the six wavelet subbands.
%   The elements of DGAIN are real numbers in the interval [0,1]. The k-th
%   column of DGAIN are the gains, or weightings applied to the k-th
%   wavelet subband. By default, DGAIN is a LEV-by-6 matrix of ones.
%
%   IMREC = IDUALTREE2(...,'LowpassGain',LPGAIN) sets the gain for the
%   lowpass (scaling) coefficients for use in the reconstruction. LPGAIN
%   is a real number in the interval [0,1]. 
%
%   % Example: Obtain the dual-tree wavelet transform of an image down to
%   % level 2. Reconstruct an approximation based on the 2nd and 5th
%   % wavelet subbands.
%   load xbox
%   [A,D] = dualtree2(xbox,'Level',2);
%   dgain = zeros(2,6);
%   dgain(:,[2 5]) = 1;
%   lpgain = 0;
%   imrec = idualtree2(A,D,'DetailGain',dgain,'LowpassGain',lpgain);
%   subplot(2,1,1)
%   imagesc(xbox)
%   subplot(2,1,2)
%   imagesc(imrec)
%
%   See also dualtree2, qbiorthfilt, qorthwavf

%   Kingsbury, N.G. (2001) Complex wavelets for shift invariant analysis 
%   and filtering of signals, Journal of Applied and Computational Harmonic
%   Analysis, vol 10, no. 3, pp. 234-253.

% Copyright 2019-2020 The MathWorks, Inc.

%#codegen 

narginchk(2,10);
nargoutchk(0,1);
validateattributes(yh,{'cell'},{'nonempty'});
% The number of cell arrays in the wavelet coefficients gives the number of
% levels
Nlev = numel(yh);
% Parse inputs
params = parseinputs(Nlev,varargin{:});
validateattributes(params.detailgain,{'double','single'},{'real','>=',0,'<=',1,...
    'size',[Nlev 6]},'idualtree2','DetailGain');
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
    for kk = 1:size(params.detailgain,1)
        dgain(kk,:) = cast(params.detailgain(kk,:),'like',yl);
    end
    lpgain = cast(params.lpgain,'like',yl);
end
% Check size of lowpass filter coefficients to ensure they are even and
% check whether we have an RGB image
coder.varsize('LH','HL','HH');
[Nr,Nc,Nchan,NIm] = size(yl);
[NrFine,NcFine] = size(yh{1});
% For code generation, specify upper bounds on changing Lo. Coder seems to
% need this to figure out the correct size.
Nelem = max([NrFine NcFine]);
coder.varsize('Lo',[2*Nelem,2*Nelem Nchan NIm],[1 1 1 1]);
% Reshape the wavelet subbands into HxWxNCxNIM
yhR = cell(size(yh));
for kk = 1:numel(yh)
    [NrD,NcD,~,~] = size(yh{kk});
    yhR{kk} = reshape(yh{kk},[NrD NcD Nchan 6 NIm]);
end
tfSR = signalwavelet.internal.iseven(Nr);
coder.internal.errorIf(~tfSR,'Wavelet:dualtree:EvenLengthInput');
tfSC = signalwavelet.internal.iseven(Nc);
coder.internal.errorIf(~tfSC,'Wavelet:dualtree:EvenLengthInput');
permidx = [2 1 3 4 5];
 
% Scaling coefficients are the real-valued yl matrix
Lo= yl;

% If the decomposition only has one level, the following for loop is
% skipped
kk = Nlev;
while kk >= 2
    % Recover wavelet subbands
    LH = complex2Quad(yhR{kk}(:,:,:,[1 6],:),dgain(kk,[1 6]));
    HL = complex2Quad(yhR{kk}(:,:,:,[3 4],:),dgain(kk,[3 4]));
    HH = complex2Quad(yhR{kk}(:,:,:,[2 5],:),dgain(kk,[2 5]));
    Lo = reshape(Lo,size(HH));
    if kk == Nlev
       Lo = Lo*lpgain;
    end
    Y1 = wavelet.internal.BatchInvColumnFilter(Lo,LoRb,LoRa)+wavelet.internal.BatchInvColumnFilter(LH,HiRb,HiRa);
    Y2 = wavelet.internal.BatchInvColumnFilter(HL,LoRb,LoRa)+wavelet.internal.BatchInvColumnFilter(HH,HiRb,HiRa);
    Y1 = permute(Y1,permidx);
    Y2 = permute(Y2,permidx);
    
    
    Lo = wavelet.internal.BatchInvColumnFilter(Y1,LoRb,LoRa)+wavelet.internal.BatchInvColumnFilter(Y2,HiRb,HiRa);
    Lo = ipermute(Lo,permidx);
    
   % Now we check the length of the projection onto the scaling space
   % against the length of the next finer resolution details
   [Nrrecon, Ncrecon,~] = size(Lo);
   [rcfs,colcfs,~] = size(yhR{kk-1});
   rcfs = 2*rcfs;
   colcfs = 2*colcfs;
   
   
   if Nrrecon ~= rcfs
        Lo = Lo(2:Nrrecon-1,:,:,:);		
   end   
   
   if Ncrecon ~= colcfs
       Lo = Lo(:,2:Ncrecon-1,:,:);
   end 
   
   
   
   
    kk = kk-1;
end

% To obtain reconstruction, use the first-level biorthogonal filters
%if kk == 1
LH = complex2Quad(yhR{kk}(:,:,:,[1 6],:),params.detailgain(kk,[1 6]));
HL = complex2Quad(yhR{kk}(:,:,:,[3 4],:),params.detailgain(kk,[3 4]));
HH = complex2Quad(yhR{kk}(:,:,:,[2 5],:),params.detailgain(kk,[2 5]));
Lo = reshape(Lo,size(LH));     
Y1 = wavelet.internal.Batchcolfilter(Lo,LoR)+wavelet.internal.Batchcolfilter(LH,HiR);
Y2 = wavelet.internal.Batchcolfilter(HL,LoR)+wavelet.internal.Batchcolfilter(HH,HiR);
Y1 = permute(Y1,permidx);
Y2 = permute(Y2,permidx);
   
imrec = wavelet.internal.Batchcolfilter(Y1,LoR)+wavelet.internal.Batchcolfilter(Y2,HiR);
imrec = ipermute(imrec,permidx);
imrec = squeeze(imrec); 
   
%end   


%--------------------------------------------------------------------------
function X = complex2Quad(Z,gain)

if nargin < 2
    gain = 1;
end

[Nr,Nc,Nchan,~,NIm] = size(Z);
X = coder.nullcopy(zeros([2*Nr 2*Nc Nchan NIm],'like',real(Z)));
%X = coder.nullcopy(zeros([2*Nr 2*Nc Nchan 1 NIm],'like',real(Z)));

% gain here is a column vector
scalfac = 1/sqrt(2)*gain;
P = Z(:,:,:,1,:)*scalfac(1)+Z(:,:,:,2,:)*scalfac(2);
Q = Z(:,:,:,1,:)*scalfac(1)-Z(:,:,:,2,:)*scalfac(2);
X(1:2:2*Nr,1:2:2*Nc,:,:)  = real(P);
X(1:2:2*Nr,2:2:2*Nc,:,:)  = imag(P);
X(2:2:2*Nr,1:2:2*Nc,:,:)  = imag(Q);
X(2:2:2*Nr,2:2:2*Nc,:,:)  = -real(Q);

   
%--------------------------------------------------------------------------
function params = parseinputs(Nlev,varargin)
% Set default mask
defaultDetailGain = ones(Nlev,6);
defaultLowpassGain = 1;
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
    addParameter(p,'DetailGain',defaultDetailGain);
    addParameter(p,'LowpassGain',defaultLowpassGain);
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
        coder.internal.getParameterValue(pstruct.DetailGain,defaultDetailGain,varargin{:});
    params.lpgain = ...
        coder.internal.getParameterValue(pstruct.LowpassGain,defaultLowpassGain,varargin{:});
    
    
    
end


validateattributes(params.lpgain,{'double','single'},{'scalar','real','>=',0,'<=',1},...
    'idualtree2','LowpassGain');
coder.internal.errorIf(~validQ(params.qlen),'Wavelet:dualtree:UnsupportedQ');
params.biorth = validatestring(params.biorth,validBiorth,'dualtree2',...
    'LevelOneFilter');






