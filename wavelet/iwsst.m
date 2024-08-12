function xrec = iwsst(sst,varargin)
%Inverse Wavelet Synchrosqueezed Transform
% XREC = IWSST(SST) returns the inverse of the wavelet synchrosqueezed
% transform in SST. XREC is a N-by-1 vector where N is the number of
% columns in SST. By default, IWSST assumes the analytic Morlet wavelet was
% used to obtain the SST.
%
% XREC = IWSST(SST,F,FREQRANGE) uses the frequency vector F and the
% two-element vector FREQRANGE to invert the synchrosqueezed transform. F
% is the vector of frequencies corresponding to the rows of SST. FREQRANGE
% is a two-element vector with positive strictly increasing values and must
% lie in the range of F. The synchrosqueezed transform is inverted for all
% frequencies included in FREQRANGE.
%
% XREC = IWSST(SST,IRIDGE) inverts the synchrosqueezed transform along the
% time-frequency ridges specified by the index column vector or matrix,
% IRIDGE. IRIDGE is the output of WSSTRIDGE. If IRIDGE is a matrix, IWSST
% first inverts the synchrosqueezed transform along the first column of
% IRIDGE, then iteratively reconstructs along subsequent columns of IRIDGE.
% XREC is a vector or matrix with the same size as IRIDGE.
%
% XREC = IWSST(...,WAV) uses the wavelet specified by WAV in inverting the
% synchrosqueezed transform. Valid options for WAV are 'amor' and
% 'bump'. You must use the same wavelet in the reconstruction that you used
% in computing the synchrosqueezed transform.
%
% XREC = IWSST(...,IRIDGE,'NumFrequencyBins',NBINS) specifies the number of
% frequency bins +/- the indices in IRIDGE to use in the reconstruction. If
% the index of the time-frequency ridge +/- NBINS exceeds the number of
% frequency bins at any time step, IWSST truncates the reconstruction at
% the first or last frequency bin. If unspecified, NBINS defaults to 16
% bins which is 1/2 the default number of voices per octave. The name-value
% pair 'NumFrequencyBins',NBINS is only valid if you provide the IRIDGE
% input. You can specify the name-value pair anywhere in the input argument
% list after the synchrosqueezed transform, SST.
%
%   %Example 1
%   %   Obtain the wavelet synchrosqueezed transform of a speech sample
%   %   using the bump wavelet. Invert the synchrosqueezed transform, plot
%   %   the result, and look at the L-infinity norm of the difference
%   %   between the original waveform and the reconstruction.
%   load mtlb;
%   dt = 1/Fs;
%   t = 0:dt:numel(mtlb)*dt-dt;
%   Txmtlb = wsst(mtlb,'bump');
%   xrec = iwsst(Txmtlb,'bump');
%   Linf = norm(abs(mtlb-xrec),Inf);
%   plot(t,mtlb); hold on; xlabel('Seconds'); ylabel('Amplitude');
%   plot(t,xrec,'r');
%   title({'Reconstruction of Wavelet Synchrosqueezed Transform'; ...
%   ['Largest Absolute Difference ' num2str(Linf,'%1.2f')]});
%
%   %Example 2
%   %   Obtain the wavelet synchrosqueezed transform of a quadratic chirp
%   %   sampled at 1000 Hz. Extract the maximum energy time-frequency ridge
%   %   and reconstruct the signal mode along the ridge.
%   load quadchirp;
%   sstchirp = wsst(quadchirp);
%   [~,iridge] = wsstridge(sstchirp);
%   xrec = iwsst(sstchirp,iridge);
%   plot(tquad,xrec,'r');
%   hold on;
%   plot(tquad,quadchirp,'b--');
%   xlabel('Time'); ylabel('Amplitude');
%   set(gca,'ylim',[-1.5 1.5]);
%   legend('Reconstruction','Original');
%   grid on;
%   title('Reconstruction of Chirp Along Maximum Time-Frequency Ridge');
%
%   See also wsst, wsstridge

%   Copyright 2015-2020 The MathWorks, Inc.

%Check that there are between 1 and 5 inputs
narginchk(1,5);

%Check that input is matrix
validateattributes(sst,{'numeric'},{'finite'},'iwsst','sst');
if (iscolumn(sst) || isrow(sst))
    error(message('Wavelet:synchrosqueezed:InvalidMatrixInput'));
end

%Get size of SST matrix
M = size(sst,1);
N = size(sst,2);

params = parseinputs(M,N,varargin{:});
WAV = params.WAV;
nbins = params.nbins;
Rpsi = waveRpsi(WAV);

if isempty(params.idx)
    xrec = wsstrec(sst,Rpsi,params.f,params.freqrange);
    % Return column vector to be consistent
    xrec = xrec(:);
    return;
end

NumRidges = size(params.idx,2);
curverec = zeros(N,NumRidges);

for ii = 1:NumRidges
    curverec(:,ii) = getcurve(sst,M,N,params.idx(:,ii),nbins,Rpsi);
end

xrec = curverec;



%-------------------------------------------------------------------------
function rpsi = waveRpsi(WAV)

%Admissibility constant for reconstruction


switch WAV
    case 'bump'
        mu = 5;
        sigma = 1;
        bumpwav = @(w)conj(exp(1)*exp(-1./(1-((w-mu)/sigma).^2)))./w;
        rpsi = integral(bumpwav,mu-sigma,mu+sigma);
        rpsi = rpsi/log(2);
        
    case 'amor'
        cf = 6;
        morlwav = @(w)exp(-1/2*(w-cf).^2)./w;
        rpsi = integral(morlwav,0+sqrt(eps),Inf);
        rpsi = rpsi/log(2);
        
end
%-------------------------------------------------------
function curverec = getcurve(sst,M,N,c,nbins,Rpsi)
freqrange = []; %#ok<NASGU>
sstidx = 1:(M*N);
colstart = ones(size(c));
colend = M*ones(size(c));
mincolidx = (0:N-1)'*M+colstart;
maxcolidx = (0:N-1)'*M+colend;
idx = (0:N-1)'*M+c;
idxlower = idx-nbins;
idxupper = idx+nbins;
idxlower = [mincolidx idxlower];
idxlower = max(idxlower,[],2);
idxupper = [maxcolidx idxupper];
idxupper = min(idxupper,[],2);

idxtmp = [];
for ii = 1:numel(idxlower)
    idxtmp = [idxtmp idxlower(ii):idxupper(ii)]; %#ok<AGROW>
end
sst(setdiff(sstidx,idxtmp)) = 0;

curverec = wsstrec(sst,Rpsi,[],[]);

%--------------------------------------------------------------------------
function sigrec = wsstrec(sst,Rpsi,varargin)

if isempty(varargin{1})
    sigrec = 2/Rpsi*real(sum(sst,1));
    return;
else
    f = varargin{1};
    freqrange = varargin{2};
    lfidx = find(f>=freqrange(1),1,'first');
    hfidx = find(f<=freqrange(2),1,'last');
    Txrec = zeros(size(sst));
    Txrec(lfidx:hfidx,:) = sst(lfidx:hfidx,:);
    sigrec = 2/Rpsi*real(sum(Txrec,1));
    
end

%-------------------------------------------------------------------------
function params = parseinputs(nrow,ncol,varargin)
% Set up defaults
% First convert any strings to char arrays
[varargin{:}] = convertStringsToChars(varargin{:});
params.WAV = 'amor';
params.freqrange = [];
params.f = [];
% Default number of frequency bins is 1/2 the number of voices
params.nbins = 16;
params.idx = [];

tfnumbins = find(strncmpi(varargin,'numfrequencybins',1));

% Find if 'NumFrequencyBins' P-V pair is passed
if any(tfnumbins)
    params.nbins = varargin{tfnumbins+1};
    validateattributes(params.nbins,{'numeric'},...
        {'positive','integer','even','>=',2},'iwsst','NumFrequencyBins');
    varargin(tfnumbins:tfnumbins+1)  = [];
end

% How many numeric inputs
tfvectors = cellfun(@isnumeric,varargin);

% There must be at most two numeric inputs in varargin
if (any(tfvectors) && nnz(tfvectors) >2)
    error(message('Wavelet:modwt:Invalid_Numeric'));
elseif (any(tfvectors) && nnz(tfvectors) == 1)
    % If there is one numeric input, it must be IRIDGE
    params.idx = varargin{tfvectors>0};
    validateattributes(params.idx,{'numeric'},...
        {'positive','integer','>=',1,'<=',nrow,'ndims',2},...
        'iwsst','IRIDGE');
    if (size(params.idx,1) ~= ncol)
        error(message('Wavelet:FunctionInput:DimensionMismatch',...
            size(params.idx,1),ncol));
    end
    
    if any(size(params.idx)==0)
        error(message('Wavelet:FunctionInput:NonzeroColumSize'));
    end
    
elseif (any(tfvectors) && nnz(tfvectors) == 2)
    idxvectors = find(tfvectors,2,'first');
    % If there are two numeric inputs, the first must be F and
    % the second must be FREQRANGE
    params.f = varargin{idxvectors(1)};
    params.freqrange = varargin{idxvectors(2)};
    validateattributes(params.f,{'numeric'},{'positive','increasing'},...
        'iwsst','F');
    % Find the limits of F to test against FREQRANGE
    f1 = params.f(1);
    fend = params.f(end);
    validateattributes(params.freqrange,{'numeric'},...
        {'numel',2,'>=',f1,'<=',fend},'iwsst','FREQRANGE');
end

% You cannot specify the number of bins without specifying the indices
if (isempty(params.idx) && any(tfnumbins))
    error(message('Wavelet:FunctionInput:InvalidSSTReconstruct'));
end

%Only char variable left must be wavelet
tfwav = cellfun(@ischar,varargin);

if (nnz(tfwav) == 1)
    params.WAV = varargin{tfwav>0};
    params.WAV = validatestring(params.WAV,{'bump','amor'},'iwsst','WAV');
elseif nnz(tfwav)>1
    error(message('Wavelet:FunctionInput:InvalidChar'));
    
end





