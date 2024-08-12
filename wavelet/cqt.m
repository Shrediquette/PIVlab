function varargout = cqt(x,varargin)
%Constant-Q nonstationary Gabor transform
%   CFS = CQT(X) returns the constant-Q transform of X. X is a
%   double-precision real- or complex-valued vector or matrix. X must have
%   at least four samples. If X is a matrix, CQT obtains the constant-Q
%   transform of each column of X. CFS is a matrix if X is a vector, or
%   multidimensional array if X is a multichannel signal. The array, CFS,
%   corresponds to the maximally redundant version of the CQT. Each row of
%   the pages of CFS corresponds to passbands with normalized center
%   frequencies (cycles/sample) logarithmically spaced between 0 and 1. A
%   normalized frequency of 1/2 corresponds to the Nyquist frequency. The
%   number of columns, or hops, corresponds to the largest bandwidth center
%   frequency. This usually occurs one frequency bin below (or above) the
%   Nyquist bin. Note that the inverse CQT requires the optional outputs G
%   and FSHIFTS described below.
%
%   [CFS,F] = CQT(X) returns the approximate bandpass center frequencies F
%   corresponding to the rows of CFS. The frequencies are ordered from 0 to
%   1 and are in cycles/sample.
%
%   [CFS,F,G,FSHIFTS] = CQT(X) returns the Gabor frames G used in the
%   analysis of X and the frequency shifts FSHIFTS in discrete Fourier
%   transform (DFT) bins between the passbands in the rows of CFS. CFS, G,
%   and FSHIFTS are required inputs for the inversion of the CQT with ICQT.
%
%   [CFS,F,G,FSHIFTS,FINTERVALS] = CQT(X) returns the frequency intervals
%   FINTERVALS corresponding the rows of CFS. The k-th element of FSHIFTS
%   is the frequency shift in DFT bins between the ((k-1) mod N)-th and (k
%   mod N)-th element of FINTERVALS with k = 0,1,2,...,N-1 where N is the
%   number of frequency shifts. Because MATLAB indexes from 1, this means
%   that FSHIFTS(1) contains the frequency shift between FINTERVALS{end}
%   and FINTERVALS{1}, FSHIFTS(2) contains the frequency shift between
%   FINTERVAL{1} and FINTERVAL{2} and so on.
%
%   [CFS,F,G,FSHIFTS,FINTERVALS,BW] = CQT(X) returns the bandwidths BW in
%   DFT bins of the frequency intervals, FINTERVALS.
%
%   [...] = CQT(X,'SamplingFrequency',Fs) specifies the sampling frequency
%   of X in hertz. Fs is a positive scalar.
%
%   [...] = CQT(...,'BinsPerOctave',B) specifies the number of bins per
%   octave to use in the constant-Q transform as an integer between 1
%   and 96. B defaults to 12.
%
%   [...] = CQT(...,'TransformType',TTYPE) specifies the 'TransformType' as
%   "full" or "sparse". The "sparse" transform is the minimally redundant
%   version of the constant-Q transform. If you specify 'TransformType' as
%   "sparse", CFS is a cell array with the number of elements equal to the
%   number of bandpass frequencies. Each element of the cell array, CFS, is
%   a vector or matrix with the number of rows equal to the value of the
%   bandwidth in DFT bins, BW. If 'TransformType' is "full" without
%   'FrequencyLimits', CFS is a matrix. If 'TransformType' is "full" and
%   frequency limits are specified, CFS is a structure array. TTYPE defaults
%   to "full".
%
%   [...] = CQT(...,'FrequencyLimits',[FMIN FMAX]) specifies the frequency
%   limits over which the constant-Q transform has a logarithmic frequency
%   response with the specified number of frequency bins per octave. FMIN
%   must be greater than or equal to Fs/N where Fs is the sampling
%   frequency and N is the length of the signal. FMAX must be strictly less
%   than the Nyquist frequency. To achieve the perfect reconstruction
%   property of the constant-Q analysis with nonstationary Gabor frames,
%   both the zero frequency (DC) and the Nyquist bin must be prepended and
%   appended respectively to the frequency interval. The negative
%   frequencies are mirrored versions of the positive center frequencies
%   and bandwidths. If the TransformType is specified as 'full' and you
%   specify frequency limits, CFS is returned as a structure array with the
%   following 4 fields:
%   c:              Coefficient matrix or multidimensional array for the
%                   frequencies within the specified frequency limits. This
%                   includes both the positive and "negative" frequencies.
%   DCcfs:          Coefficient vector or matrix for the passband from 0 to
%                   the lower frequency limit.
%   Nyquistcfs:     Coefficient vector or matrix for the passband from the
%                   upper frequency limit to the Nyquist.
%   NyquistBin:     DFT bin corresponding to the Nyquist frequency. This
%                   field is used when inverting CQT.
%
%   [...] = CQT(...,'Window',WINNAME) uses the WINNAME window as the
%   prototype function for the nonstationary Gabor frames. Supported
%   options for WINNAME are "hann", "hamming", "blackmanharris",
%   "itersine", and "bartlett". WINNAME defaults to "hann". Note that these
%   are compactly supported functions in frequency defined on the interval
%   (-1/2,1/2) for normalized frequency or (-Fs/2,Fs/2) when you specify a
%   sampling frequency.
%
%   CQT(...) with no output arguments plots the constant-Q transform in the
%   current figure. Plotting is only supported in MATLAB for a single-vector
%   input. If the input signal is real, the CQT is plotted over the range
%   [0,Fs/2]. If the signal is complex-valued, the CQT is plotted over
%   [0,Fs).
%
%   % Example:
%   %   Plot the constant-Q transform of a speech sample using the maximally
%   %   redundant version of the transform and 48 bins per octave. Set the
%   %   frequency limits from 100 to 6000 Hz.
%
%   load wavsheep;
%   cqt(sheep,'SamplingFrequency',fs,'BinsPerOctave',48,...
%   'FrequencyLimits',[100 6000])
%
%   References:
%   Holighaus, N., Doerfler, M., Velasco, G.A., & Grill,T.
%   (2013) "A framework for invertible real-time constant-Q transforms",
%   IEEE Transactions on Audio, Speech, and Language Processing, 21, 4,
%   pp. 775-785.
%
%   Velasco, G.A., Holighaus, N., Doerfler, M., & Grill, Thomas. (2011)
%   "Constructing an invertible constant-Q transform with nonstationary
%   Gabor frames", Proceedings of the 14th International Conference on
%   Digital Audio Effects (DAFx-11), Paris, France.
%
%   See also ICQT

%   Copyright 2017-2020 The MathWorks, Inc.

%#codegen

isMATLAB = isempty(coder.target);

% Check number of input and output arguments
narginchk(1, 11);
if isMATLAB
    nargoutchk(0, 6);
else
    %cqt with no output arguments plots cfs coefficients in current figure.
    %Plotting not supported for code generation
    nargoutchk(1, 6);
end

% Validate attributes on signal
validateattributes(x, {'double'}, {'finite', 'nonempty', '2d'},...
    'CQT', 'X');

if isvector(x)
    n = numel(x);
    sig = x(:);
    numSig = 1;
else
    % Columns as signals
    [n, numSig] = size(x);
    sig = x;
end

% Plotting not supported for multidimensional inputs
if isMATLAB && nargout == 0 && numSig > 1
    error(message('Wavelet:FunctionOutput:PlotTooManyDims'));
end

% Signal must have at least four samples
if n < 4
    coder.internal.error('Wavelet:synchrosqueezed:NumInputSamples');
end

% Parse Inputs
[normFreq, fs, numBins, transformType, freqLimits, winName] = ...
    parseInputs(n, varargin{:});
if any(imag(sig(:)))
    sigType = 'complex';
else
    sigType = 'real';
end
fMin = freqLimits(1);
fMax = freqLimits(2);

% Nyquist frequency
nyqFreq = fs/2;

% Set minimum bandwidth in DFT bins
minBW = 4;

%   Q-factor for CQ-NSGT and inverse for determining bandwidth Bandwidths
%   are $\varepsilon_{k+1}-\varepsilon_{k}$ where $\varepsilon_k$ is the
%   k-th center frequency. Described in Holighaus et. al. (2013). CQ-NSGT
%   Parameters: Windows and Lattices
q = 1/(2^(1/numBins) - 2^(-(1/numBins)));
% bw = cf*q^(-1) so obtain 1/q
qInv = 1/q;
%   Default number of octaves. Velasco et al., 2011 CQ-NSGT Parameters:
%   Windows and Lattices
bMax = ceil(numBins*log2(fMax/fMin) + 1);


%   Note: fMin is rendered exactly. fMax is not necessarily
%   f = fMin.*2.^((0:numBins*numOct-1)./numBins);
%   frequencies here are in hertz.
tFreqBins = fMin.*2.^((0:bMax - 1)./numBins);
tFreqBinsReshapeToColumn = tFreqBins(:);

% Remove any bins greater than or equal to the Nyquist
% First find the first frequency greater than or equal to fMax, this should
% not be empty by construction. We will append the Nyquist so ensure we
% are not at the Nyquist or beyond.
if isMATLAB
    % First index greater than or equal to fMax
    idxGrEqFMax = find(tFreqBinsReshapeToColumn >= fMax, 1, 'first');
else
    % Code replacing 'find' function to support code generation
    idxGrEqFMax = numel(tFreqBinsReshapeToColumn);
    for ii = 1:numel(tFreqBinsReshapeToColumn)
        if tFreqBinsReshapeToColumn(ii) >= fMax
            % Index greater than or equal to fMax
            idxGrEqFMax = ii;
            break;
        end
    end
end
% Frequency bins less than Nyquist frequency
if tFreqBinsReshapeToColumn(idxGrEqFMax) >= nyqFreq
    tFreqBinsLeNyq = tFreqBinsReshapeToColumn(1:idxGrEqFMax - 1);
else
    tFreqBinsLeNyq = tFreqBinsReshapeToColumn(1:idxGrEqFMax);
end

% First record number of bins, 1,....K prior to pre-pending DC and
% appending the Nyquist
lenBins = numel(tFreqBinsLeNyq);
% Now prepend DC and append Nyquist frequencies
tFreqConcat = [0; tFreqBinsLeNyq; nyqFreq];
% Store Nyquist Bin
NyquistBin = lenBins + 2;
% Store DC bin
dcBin = 1;
% Mirror other filters -- start with one bin below the Nyquist bin and go
% down to one bin above DC
f = [tFreqConcat; fs - tFreqConcat(end - 1:-1:2)];

% Convert the frequency bins to approximate index of DFT bin.
fBins = f*(n/fs);

% Determine bandwidths in DFT bins. For everything but the DC bin and the
% Nyquist bins the bandwidth is \epsilon_{k+1}-\epsilon_{k-1}. Total number
% of bandwidths is now 2*lenBins+2
bw = zeros(2*lenBins + 2, 1);

%   Set bandwidth of DC bin to 2*fMin -- these are bandwidths in samples
%   (approximately), we will round to integer values.
bw(dcBin) = 2*fBins(2);
% Set lenBins 1 such that cf/bw = q
bw(2) = fBins(2)*qInv;
%   Set the bandwidth for the frequency before the Nyquist such that
%   cf/bw = q
bw(lenBins + 1) = fBins(lenBins + 1)*qInv;
% Set the original k = 1,....K-1
idxk = [3:lenBins, NyquistBin];
% See Velasco et al. and Holighaus et al. CQ-NSGT Parameters: Windows
% and Lattices
bw(idxk) = fBins(idxk + 1) - fBins(idxk - 1);
% Mirror bandwidths on the negative frequencies
bw(lenBins + 3:2*lenBins + 2) = bw(lenBins + 1:-1:2);
% Round the bandwidths to integers
bw = round(bw);

% Convert frequency centers to integers. Round down up to Nyquist. Round up
% after Nyquist.
cfBins = zeros(size(fBins));
% Up to Nyquist floor round down
cfBins(1:lenBins + 2) = floor(fBins(1:lenBins + 2));
% From Nyquist to Fs, round up
cfBins(lenBins + 3:end) = ceil(fBins(lenBins + 3:end));


% Compute the shift between filters in frequency in samples
diffLFDC = n - cfBins(end);
fshifts = [diffLFDC; diff(cfBins)];

% Ensure that any bandwidth less than the minimum window is set to the
% minimum window
bw(bw < minBW) = minBW;


% Compute the frequency windows for the CQT-NSGFT
g = wavelet.internal.cswindow(winName, bw, lenBins);
nWin = numel(g);

% Obtain DFT of input signal
xDFT = fft(sig);

% Depending on transform type value
if strcmpi(transformType, 'full')
    if isMATLAB
        m = max(cellfun(@(x)numel(x), g))*ones(nWin, 1);
    else
        % Code to replace 'cellfun' function to find maximum number of
        % elements, as there is no code generation support for cellfun
        maxLen = numel(g{1});
        for ii = 2:nWin
            if numel(g{ii}) > maxLen
                maxLen = numel(g{ii});
            end
        end
        m = maxLen*ones(nWin, 1);
    end
    [cfs, ~, fintervals] = cqtFull(xDFT, g, cfBins, m, sigType,...
        transformType, NyquistBin);
    
elseif strcmpi(transformType, 'reduced')
    m = zeros(size(bw));
    hfBand = bw(NyquistBin - 1);
    m([2:NyquistBin, NyquistBin + 1:end]) = hfBand;
    m(dcBin) = bw(dcBin);
    m(NyquistBin) = bw(NyquistBin);
    [~, cfs, fintervals] = cqtFull(xDFT, g, cfBins, m, sigType,...
        transformType, NyquistBin);
    
elseif strcmpi(transformType, 'sparse')
    [cfs, fintervals] = cqtSparse(xDFT, g, cfBins, bw, sigType);
    
else
    coder.internal.error('MATLAB:CQT:unrecognizedStringChoice');
    
end

if isMATLAB && nargout == 0
    
    % Plot if no output arguments
    if strcmpi(transformType, 'sparse')
        cfs = sparseCoefsToFull(cfs, sigType, NyquistBin);
    end
    
    plotcqt(cfs, f, fs, n, sigType, transformType, NyquistBin, normFreq);
    
else
    
    varargout{1} = cfs;
    varargout{2} = f;
    varargout{3} = g;
    varargout{4} = fshifts;
    varargout{5} = fintervals;
    varargout{6} = bw;
    
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [cfs,fIntervals] = cqtSparse(xDFT,g,cfBins,m,sigType)

nWin = numel(g);
[n, numSig] = size(xDFT);
fIntervals = cell(nWin, 1);
cfs = cell(nWin, 1);

% Algorithm for forward CQT due to Holighaus and Velasco
for kk = 1:nWin
    gLen = numel(g{kk});
    % Note: Flip halves of windows. This centers the window at zero
    % frequency
    winOrder = [ceil(gLen/2) + 1:gLen, 1:ceil(gLen/2)];
    % The following are the DFT bins corresponding to the frequencies in
    % the bandwidth of the window
    winRange = 1 + mod(cfBins(kk) + (-floor(gLen/2):ceil(gLen/2) - 1), n);
    fIntervals{kk} = winRange;
    tmp = complex(zeros(m(kk), numSig));
    % Multiply the DFT of the signal by the compactly supported window in
    % frequency. Then take the inverse Fourier transform to obtain the
    % CQT coefficients
    if isempty(coder.target)
        tmp(winOrder, :) = xDFT(winRange, :).*g{kk}(winOrder);
        
    else
        % Splitting times(.*) operation to support code generation
        prodGTempXDFT = complex(zeros(numel(winRange), numSig));
        for ii = 1:numSig
            prodGTempXDFT(:,ii) = xDFT(winRange, ii).*g{kk}(winOrder) ;
        end
        tmp(winOrder, :) = prodGTempXDFT;
        
    end
    cfs{kk} = ifft(tmp);
    
end

%Multiply cfs by scaling factor to obtain final cfs coefficients
cfs = cfsCoefs(cfs, n, sigType);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [cfsFull,cfsReduced,fIntervals] = cqtFull(xDFT,g,cfBins,m,...
    sigType,transformType,NyquistBin)

isMATLAB = isempty(coder.target);
nWin = numel(g);
[n, numSig] = size(xDFT);
fIntervals = cell(nWin, 1);
% Using hop size of highest frequency band before the Nyquist.
tCFS = cell(nWin, 1);

% Algorithm for forward CQT due to Holighaus and Velasco
for kk = 1:nWin
    gLen = numel(g{kk});
    % Note: Flip halves of windows
    winOrder = [ceil(gLen/2) + 1:gLen, 1:ceil(gLen/2)];
    % The following are the DFT bins corresponding to the frequencies in
    % the bandwidth of the window
    winRange = 1 + mod(cfBins(kk) + (-floor(gLen/2):ceil(gLen/2) - 1), n);
    fIntervals{kk} = winRange;
    rowDim = m(kk);
    tmp = complex(zeros(m(kk),numSig));
    if isMATLAB
        tmp([rowDim - floor(gLen/2) + 1:rowDim, 1:ceil(gLen/2)], :) = ...
            xDFT(winRange, :).*g{kk}(winOrder);
        
    else
        % Splitting times(.*) operation to support code generation
        prodGTempXDFT = complex(zeros(numel(winRange), numSig));
        for ii = 1 : numSig
            prodGTempXDFT(:,ii) = xDFT(winRange, ii).*g{kk}(winOrder);
        end
        tmp([rowDim - floor(gLen/2) + 1:rowDim, 1:ceil(gLen/2)], :) = ...
            prodGTempXDFT;
        
    end
    tCFS{kk} = ifft(tmp);
    
end

%Multiply cfs by scaling factor to obtain final cfs coefficients
tCFS = cfsCoefs(tCFS, n, sigType);

if strcmpi(transformType, 'reduced')
    DCcfs = tCFS{1};
    Nyquistcfs = tCFS{NyquistBin};
    if isMATLAB
        tCFS([1 NyquistBin]) = [];
        tCFSMatrix = cell2mat(tCFS);
        
    else
        nCells = numel(tCFS);
        [nRow, nCol] = size(tCFS{2});
        tCFSMatrix = complex(zeros((nCells-2)*nRow, nCol));
        % cell2mat implementation using for loop
        % as there is no code generation support for cell2mat
        idx = 0;
        for ii = 1:nCells
            if ii ~= 1 && ii ~= NyquistBin
                tCFSMatrix(idx + 1:idx + nRow, 1:nCol) = tCFS{ii};
                idx = idx + nRow;
            end
        end
        
    end
    numTPts = max(m(2:NyquistBin - 1));
    tCFSReshape = reshape(tCFSMatrix, numTPts, nWin - 2, numSig);
    % Permute frequency and hop so that the coefficients matrices are
    % frequency by time
    c = permute(tCFSReshape, [2 1 3]);
    cfsReduced = struct('c', c, 'DCcfs', DCcfs, 'Nyquistcfs', Nyquistcfs,...
        'NyquistBin', NyquistBin);
    cfsFull = [];
    
else
    if isMATLAB
        tCFSMatrix = cell2mat(tCFS);
    else
        % cell2mat implementation using for loop
        % as there is no code generation support for cell2mat
        nCells = numel(tCFS);
        [nRow,nCol] = size(tCFS{1});
        tCFSMatrix = complex(zeros(nCells*nRow, nCol));
        idx = 0;
        for ii = 1:nCells
            tCFSMatrix(idx + 1:idx + nRow, 1:nCol) = tCFS{ii};
            idx = idx + nRow;
        end
        
    end
    numTPts = max(m);
    tCFSReshape = reshape(tCFSMatrix, numTPts, nWin, numSig);
    % Permute frequency and hop so that the coefficients matrices are
    % frequency by time
    cfsFull = permute(tCFSReshape, [2 1 3]);
    cfsReduced = struct('c', complex([]), 'DCcfs', complex([]), ...
        'Nyquistcfs', complex([]), 'NyquistBin', []);
    
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function plotcqt(coefs,f,fs,l,sigType,transformType,NyquistBin,normFreq)
if strcmpi(sigType, 'real') && (strcmpi(transformType, 'full') || ...
        strcmpi(transformType, 'sparse'))
    f = f(1:NyquistBin);
    coefs = coefs(1:NyquistBin, :);
elseif strcmpi(sigType, 'real') && strcmpi(transformType, 'reduced')
    f = f(2:NyquistBin - 1);
    % Nyquist frequency has already been removed from c field
    coefs = coefs.c(1:NyquistBin - 2,:);
elseif strcmpi(sigType, 'complex') && strcmpi(transformType, 'reduced')
    f([1 NyquistBin]) = [];
    coefs = coefs.c;
end

numTimePts = size(coefs, 2);
t = linspace(0, l*1/fs, numTimePts);

if normFreq
    freqUnitStrs = wavelet.internal.wgetfrequnitstrs;
    freqLbl = freqUnitStrs{1};
    ut = 'Samples';
    xLbl = ...
        [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
    
else
    [f, ~, uf] = engunits(f, 'unicode');
    [t, ~, ut] = engunits(t, 'unicode', 'time');
    freqLbl = wavelet.internal.wgetfreqlbl([uf 'Hz']);
    xLbl = ...
        [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
    
end
ax = newplot;
hndl = surf(ax, t, f, 20*log10(abs(coefs) + eps(0)));
hndl.EdgeColor = 'none';
axis xy; axis tight;
view(0, 90);
h = colorbar;
h.Label.String = getString(message('Wavelet:FunctionOutput:dB'));
ylabel(freqLbl);
xlabel(xLbl);
title(getString(message('Wavelet:FunctionOutput:constantq')));

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function coefs = sparseCoefsToFull(cfs,sigtype,NyquistBin)

if strcmpi(sigtype, 'real')
    cfs = cfs(1 : NyquistBin);
end

numcoefs = max(cellfun(@(x)numel(x), cfs));
coefs = zeros(numel(cfs), numcoefs);

for kk = 1 : numel(cfs)
    tmp = cfs{kk};
    x = linspace(0, 1, numel(tmp));
    xq = linspace(0, 1, numcoefs);
    f = griddedInterpolant(x, tmp);
    f.Method = 'nearest';
    coefs(kk,:) = f(xq);
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [normFreq,fs,numBins,transformType,freqLimits,...
    winName] = parseInputs(n,varargin)

normFreq = true;

nvPairs = struct('SamplingFrequency', uint32(0), 'BinsPerOctave',...
    uint32(0), 'TransformType', uint32(0), 'FrequencyLimits', uint32(0),...
    'Window', uint32(0));
options = struct('PartialMatching', true);
pstruct = coder.internal.parseParameterInputs(nvPairs, options,...
    varargin{:});

tempFs = coder.internal.getParameterValue(pstruct.SamplingFrequency, [],...
    varargin{:});
if ~isempty(tempFs)
    normFreq = false;
    fs = tempFs;
    validateattributes(fs, {'numeric'}, {'scalar', 'positive'},...
        'CQT', 'SamplingFrequency');
else
    fs = 1;
end

numBins = coder.internal.getParameterValue(pstruct.BinsPerOctave, 12,...
    varargin{:});
validateattributes(numBins, {'numeric'},...
    {'integer', 'scalar', '>=', 1, '<=', 96}, 'CQT', 'BinsPerOctave');

tempFreqLimits = coder.internal.getParameterValue(pstruct.FrequencyLimits,...
    [],varargin{:});
if ~isempty(tempFreqLimits)
    freqLimits = tempFreqLimits;
    validateattributes(freqLimits, {'numeric'}, {'numel', 2, 'positive',...
        '>=', fs/n, '<=', fs/2, 'increasing'}, 'CQT', 'FrequencyLimits');
else
    freqLimits = [fs/n fs/2];
end

if ~isempty(coder.target) && pstruct.TransformType > 0
    coder.internal.assert(...
        coder.internal.isConst(varargin{pstruct.TransformType}), ...
        'Wavelet:codegeneration:NonConstantInput', 'TransformType');
end
tempTransformType = coder.internal.getParameterValue(pstruct.TransformType,...
    'full', varargin{:});
tempTransformType = validatestring(tempTransformType, {'sparse', 'full'},...
    'CQT', 'TransformType');
if ~isempty(tempFreqLimits) && strcmpi(tempTransformType,'full')
    transformType ='reduced';
else
    transformType = tempTransformType;
end

validwin = {'hann', 'hamming', 'itersine', 'blackmanharris', 'bartlett'};
winName = validatestring(coder.internal.getParameterValue(pstruct.Window,...
    'hann', varargin{:}), validwin, 'CQT', 'Window');

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function cfs = cfsCoefs(cfs,n,sigType)

%Multiplication of cfs by scaling factors
isMATLAB = isempty(coder.target);
if strcmpi(sigType, 'real')
    if isMATLAB
        cfs = cellfun(@(x)(2*size(x,1))/n*x, cfs, 'uni', 0);
    else
        % Code to replace 'cellfun' function to find maximum number of
        % elements, as there is no code generation support for cellfun
        for ii = 1:numel(cfs)
            cfs{ii,1} = (2*size(cfs{ii},1))/n*cfs{ii};
        end
    end
else
    if isMATLAB
        cfs = cellfun(@(x)size(x,1)/n*x, cfs, 'uni', 0);
    else
        % Code to replace 'cellfun' function to find maximum number of
        % elements, as there is no code generation support for cellfun
        for ii = 1:numel(cfs)
            cfs{ii,1} = size(cfs{ii},1)/n*cfs{ii};
        end
    end
end
