function xrec = icwt(wt,varargin)
%ICWT Inverse continuous 1-D wavelet transform
%   XREC = ICWT(CFS) inverts the continuous wavelet transform (CWT)
%   coefficient matrix, CFS, using Morlet's single integral formula.
%   By default, ICWT uses the default Morse (3,60)
%   wavelet and default scales in the inversion. CFS is a 2-D or 3-D matrix
%   with complex-valued elements. If CFS is a 2-D matrix, ICWT assumes that
%   the CWT was obtained from a real-valued signal. If CFS is a 3-D matrix,
%   ICWT assumes the CWT was obtained from a complex-valued signal. For a
%   3-D matrix, the first page of CFS is the CWT of the positive
%   (counterclockwise) component and the second page of CFS is the CWT of
%   the negative (clockwise) component. These represent the analytic and
%   anti-analytic parts of the CWT, respectively.
%
%   XREC = ICWT(...,WNAME) uses the wavelet WNAME in the inversion. Valid
%   options for WNAME are: 'morse', 'amor', or 'bump'. ICWT must use
%   the same wavelet as CWT. WNAME is ignored if the analysis filter
%   bank is used. 
%
%   XREC = ICWT(...,F,FREQRANGE) inverts the CWT over the frequency range
%   specified in FREQRANGE. If CFS is a 2-D matrix, FREQRANGE must be a
%   two-element vector. If CFS is a 3-D matrix, FREQRANGE can be a
%   two-element vector or a 2-by-2 matrix. If CFS is a 3-D matrix and
%   FREQRANGE is a vector, inversion is performed over the same frequency
%   range in both the positive (analytic) and negative (anti-analytic)
%   components of CFS. If FREQRANGE is a 2-by-2 matrix, the first row
%   contains the frequency range for the positive part of CFS (first page)
%   and the second row contains the frequency range for the negative part
%   of CFS (second page). For a vector, the elements of FREQRANGE must be
%   strictly increasing and contained in the range of the frequency vector
%   F. For a matrix, each row of FREQRANGE must be strictly increasing and
%   contained in the range of F. F is the scale-to-frequency conversion
%   obtained in CWT. For the inversion of a complex-valued signal, you can
%   specify one row of FREQRANGE as a vector of zeros. If the first row of
%   FREQRANGE is a vector of zeros, only the negative (anti-analytic part)
%   is used in the inversion. For example [0 0; 1/10 1/4] inverts the
%   negative (clockwise) component over the frequency range [1/10 1/4]. The
%   positive (counterclockwise) component is first set to all zeros before
%   performing the inversion. Similarly, [1/10 1/4; 0 0] inverts the CWT by
%   selecting the frequency range [1/10 1/4] from the positive
%   (counterclockwise) component and setting the negative component to all
%   zeros. 
%
%   If you specify the F,FREQRANGE inputs, you must precede these inputs
%   either by the wavelet name or use an empty input for the default
%   'Morse' wavelet. For example, icwt(cfs,'Morse',F,FREQRANGE) or
%   icwt(cfs,[],F,FREQRANGE).
%
%   XREC = ICWT(..,P,PERIODRANGE) inverts the CWT over the two-element
%   range of periods in PERIODRANGE. You cannot specify both a frequency
%   range and a period range. If CFS is a 2-D matrix, PERIODRANGE must be a
%   two-element vector of durations. If CFS is a 3-D matrix, PERIODRANGE
%   can be a two-element vector of durations or 2-by-2 matrix of durations.
%   If PERIODRANGE is a vector of durations and CFS is a 3-D matrix,
%   inversion is performed over the same frequency range in both the
%   positive (analytic) and negative (anti-analytic) components of CFS. If
%   PERIODRANGE is a 2-by-2 matrix of durations, the first row contains the
%   period range for the positive part of CFS (first page) and the second
%   row contains the period range for the negative part of CFS (second
%   page). For a vector, the elements of PERIODRANGE must be strictly
%   increasing and contained in the range of the period vector P. The
%   elements of PERIODRANGE and P must have the same units. For a matrix,
%   each row of PERIODRANGE must be strictly increasing and contained in
%   the range of the period vector P. P is an array of durations obtained
%   from CWT with a duration input. For the inversion of a complex-valued
%   signal, you can specify one row of PERIODRANGE as a vector of zero
%   durations. If the first row of PERIODRANGE is a vector of zero
%   durations, only the negative (anti-analytic part) is used in the
%   inversion. For example [seconds(0) seconds(0); seconds(1/10)
%   seconds(1/4)] inverts the negative (clockwise) component over the
%   period range [seconds(1/10) seconds(1/4)]. The positive
%   (counterclockwise) component is first set to all zeros before
%   performing the inversion. Similarly, [seconds(1/10) seconds(1/4);
%   seconds(0) seconds(0)] inverts the CWT by selecting the period range
%   [1/10 1/4] from the positive (counterclockwise) component and setting
%   the negative component to all zeros.
%
%   If you specify P,PERIODRANGE you must precede these inputs either by 
%   the wavelet name or use an empty input for the default 'Morse'
%   wavelet. For example, icwt(cfs,'Morse',P,PERIODRANGE) or
%   icwt(cfs,[],P,PERIODRANGE).
%
%   XREC = ICWT(...,'TimeBandwidth',TB) uses the positive scalar
%   time-bandwidth parameter, TB, to invert the CWT using the Morse
%   wavelet. The symmetry parameter (gamma) of the Morse wavelet is assumed
%   to equal 3. The inverse CWT must use the same time-bandwidth value used
%   in the CWT. This syntax is not valid if you specify the 
%   'AnalysisFilterBank' input.
%
%   XREC = ICWT(...,'WaveletParameters',PARAM) uses the parameters PARAM to
%   specify the Morse wavelet used in the inversion of the CWT. PARAM is a
%   two-element vector. The first element is the symmetry parameter (gamma)
%   and the second parameter is the time-bandwidth parameter. The inverse
%   CWT must use the same wavelet parameters used in obtaining the wavelet
%   transform. This syntax is not valid if you specify the 
%   'AnalysisFilterBank' input.
%
%   XREC = ICWT(...,'SignalMean',MEAN) adds the scalar or vector MEAN to
%   the output of ICWT. If MEAN is a vector, it must be the same length as
%   the column size of the wavelet coefficient matrix.  If CFS is a 2-D
%   matrix, MEAN must be a real-valued scalar or vector. If CFS is a 3-D
%   matrix, MEAN must be a complex-valued scalar or vector. Because the
%   continuous wavelet transform does not preserve the signal mean, the
%   inverse CWT is a zero-mean signal by default. Note that adding a
%   non-zero MEAN to a frequency- or period-limited reconstruction adds a
%   zero-frequency component to the reconstruction. This syntax is not
%   valid if you specify the 'AnalysisFilterBank' input.
%
%   XREC = ICWT(...,'ScalingCoefficients',SCALCFS) uses the scaling
%   coefficients, SCALCFS, in the inverse CWT. SCALCFS are the scaling
%   coefficients obtained as an optional output of CWT. SCALCFS is a real-
%   or complex-valued vector which is the same length as the column size of
%   the wavelet coefficient matrix. You cannot specify both the
%   'SignalMean' and 'ScalingCoefficients' name-value pairs. If you only
%   specify 'ScalingCoefficients' without the 'AnalysisFilterBank' input,
%   the single-integral approximation is used to obtain the inverse CWT. If
%   you specify SCALCFS with the 'AnalysisFilterBank' input, the synthesis
%   filters are used to obtain the inverse CWT.
%
%   XREC = ICWT(...,'AnalysisFilterBank',PSIF) uses the bank of analysis
%   filters, PSIF, in inverting the CWT. The approximate synthesis filters,
%   or dual frame, are used in the inversion. In most cases, use of the
%   approximate synthesis filters results in a more accurate signal
%   reconstruction. To use the analysis filters, you must obtain the CWT
%   with the signal extension set to false in the CWT function or
%   equivalently Boundary set to 'periodic' in CWTFILTERBANK. Obtain
%   the analysis filters from the FREQZ function of the filter bank with
%   FrequencyRange='twosided' and IncludeLowpass=true. The wavelet name
%   input is ignored if you specify the analysis filters.
%
%   XREC = ICWT(...,'VoicesPerOctave',NV) specifies the number of voices
%   per octave used in inverting the CWT. If you input a frequency vector
%   or array of durations, you cannot specify the VoicesPerOctave
%   name-value pair. The number of voices per octave is determined by the
%   frequency or duration vector. If you do not specify the number of
%   voices per octave or a frequency or duration vector, ICWT uses the
%   default of 10. NV is an integer between 1 and 48 and must agree
%   with the value used in obtaining the wavelet transform. This syntax is
%   not valid if you specify the 'AnalysisFilterBank' input.
%
%   % Example 1
%   %   Obtain the CWT of the Kobe earthquake data. Invert the CWT
%   %   and compare the result with the original signal.
%   load kobe;
%   sigmean = mean(kobe);
%   CFS = cwt(kobe);
%   xrec = icwt(CFS,'SignalMean',sigmean);
%   plot((1:numel(kobe))./60,kobe);
%   xlabel('mins'); ylabel('nm/s^2');
%   hold on
%   plot((1:numel(kobe))./60,xrec,'r');
%   legend('Inverse CWT','Original Signal');
%   hold off
%
%   % Example 2
%   %   Reconstruct a frequency-localized approximation to the Kobe
%   %   earthquake data by extracting information from the CWT
%   %   corresponding to frequencies in the range of [0.030, 0.070] Hz. Use
%   %   an empty input to denote the default wavelet family 'Morse'.
%
%   load kobe;
%   [CFS,f] = cwt(kobe,1);
%   xrec = icwt(CFS,[],f,[0.030 0.070],'SignalMean',mean(kobe));
%   subplot(211)
%   plot(kobe); grid on;
%   title('Original Data');
%   subplot(212)
%   plot(xrec); grid on;
%   title('Bandpass Filtered Reconstruction [0.030 0.070] Hz');
%
%   % Example 3
%   %   Obtain the CWT of a 100-Hz complex exponential sampled at 1 kHz.
%   %   Invert the CWT and plot the real and imaginary parts.
%
%   Fs = 1000;
%   t = 0:1/Fs:1;
%   z = exp(1i*2*pi*100*t);
%   cfs = cwt(z,Fs,'ExtendSignal',false);
%   xrec = icwt(cfs);
%   subplot(211)
%   plot([real(xrec.') real(z.')])
%   title('Real Part');
%   ylim([-1.5 1.5])
%   subplot(212)
%   plot([imag(xrec.') imag(z.')])
%   title('Imaginary Part');
%   ylim([-1.5 1.5])
%
%   %Example 4
%   %   Obtain the CWT of the NPG2006 dataset. Invert the CWT and add in a
%   %   time-varying trend. Plot the real and imaginary parts of the
%   %   original data along with the reconstructions for comparison.
%
%   load npg2006
%   cfs = cwt(npg2006.cx);
%   trend = smoothdata(npg2006.cx,'movmean',100);
%   xrec = icwt(cfs,'SignalMean',trend);
%   subplot(2,1,1)
%   plot([real(xrec)' real(npg2006.cx)])
%   grid on;
%   subplot(2,1,2)
%   plot([imag(xrec)' imag(npg2006.cx)])
%   grid on;
%
%   %Example 5
%   %   Obtain the CWT of the NPG2006 dataset with the bump wavelet.
%   %   Invert the CWT and add the scaling coefficients to capture
%   %   the low-frequency behavior. Plot the real and imaginary parts of 
%   %   the original data along with the reconstructions for comparison.
%
%   load npg2006
%   [cfs,~,~,~,scalcfs] = cwt(npg2006.cx,'bump');
%   xrec = icwt(cfs,'bump','ScalingCoefficients',scalcfs);
%   subplot(2,1,1)
%   plot([real(xrec)' real(npg2006.cx)])
%   grid on;
%   subplot(2,1,2)
%   plot([imag(xrec)' imag(npg2006.cx)])
%   grid on;
%
%   %Example 6
%   %   Obtain the CWT of an ECG waveform using the default Morse wavelet
%   %   with periodic boundary handling. Use the analysis filters to
%   %   reconstruct the input. Compare the maximum reconstruction error
%   %   with that obtained using the default Morlet single-integral
%   %   formula.
%   load wecg
%   fb = cwtfilterbank(SignalLength=length(wecg),Boundary='periodic');
%   [cfs,~,~,scalcfs] = wt(fb,wecg);
%   psif = freqz(fb,FrequencyRange='twosided',IncludeLowpass=true);
%   xrec = icwt(cfs,[],ScalingCoefficients=scalcfs,...
%       AnalysisFilterBank=psif);
%   xrec1 = icwt(cfs,[],ScalingCoefficients=scalcfs);
%   norm(xrec'-wecg,Inf)
%   norm(xrec1'-wecg,Inf)
%   subplot(2,1,1)
%   plot([xrec' wecg])
%   axis tight
%   legend('synthesis filters','Original',Location='eastoutside')
%   subplot(2,1,2)
%   plot([xrec1' wecg])
%   axis tight
%   legend('single-integral formula','Original',Location='eastoutside')
%
%   See also CWT, CWTFILTERBANK

%   Copyright 2016-2021 The MathWorks, Inc.

%#codegen

narginchk(1,8);
nargoutchk(0,1);
validateattributes(wt,{'double','single'},{'3d','nonempty','finite'},'ICWT','WT');
coder.internal.errorIf(isrow(wt) || iscolumn(wt) || size(wt,3) > 2,'Wavelet:cwt:InvalidCWTSize');
coder.internal.prefer_const(varargin);
datatype = underlyingType(wt);
% Determine if input came from real or complex signal
if ndims(wt) == 3
    sigtype = 'complex';
else
    sigtype = 'real';
end

Na = size(wt,1);
N = size(wt,2);

params = parseInputs(Na,N,sigtype,datatype,varargin{:});

if startsWith(params.invMethod,'m')
    xrec = invMorletMethod(wt,params.ds,sigtype,params);
else
    xrec = wavelet.internal.cwt.inverseCWT(wt,sigtype,params);
end

%---------------------------------------------------------------------
function ds = getScType(scales)
DF2 = diff(log2(scales),2);
thresh = cast(1e-3,'like',scales);
if all(abs(DF2) < thresh)
    % 'all' is needed for code generation
    ds = mean(diff(log2(scales)),'all');
else
    coder.internal.error('Wavelet:cwt:UnsupportedScales');
end

%--------------------------------------------------------------------------
function [psifR,invMethod] = validateAnalysisFB(N,Na,psif,datatype)
validateattributes(psif,{'double','single'},{'finite','2d','real'},'ICWT','AnalysisFilters');
Nf = size(psif,1);
Nt = size(psif,2);
if Nt ~= N
    coder.internal.error('Wavelet:cwt:AnalysisFilterSizeTime',N);
end
if Nf ~= Na+1
    coder.internal.error('Wavelet:cwt:AnalysisFilterSizeFreq',Na+1);
end
psifR = cast(psif,datatype);
invMethod = 'synthesis';

%--------------------------------------------------------------------------
function xrec = invMorletMethod(wt,ds,sigtype,params)

if startsWith(sigtype,'r')
    isReal = true;
else
    isReal = false;
end
Na = size(wt,1);
if startsWith(sigtype,'c')
    wtPos = wt(:,:,1);
    wtNeg = wt(:,:,2);
else
    wtPos = wt(:,:,1);
    wtNeg = zeros(0,0,'like',wtPos);

end

if isempty(params.wavname)
    params.wavname = 'morse';
end

if ~isempty(params.f)

    if isReal
        idxZero = wavelet.internal.cwt.findFreqIndices(Na,params.f,params.freqrange,isReal);
        wtPos(idxZero,:) = 0;
    else 
        [idxZeroPos,idxZeroNeg] = wavelet.internal.cwt.findFreqIndices(Na,params.f,params.freqrange,isReal);
        wtPos(idxZeroPos,:) = 0;
        wtNeg(idxZeroNeg,:) = 0;
    end

elseif ~isempty(params.periods)

    coder.internal.errorIf(~isvector(params.periods),'Wavelet:cwt:InvalidFreqPeriodInput');
    if isReal
        idxZero = wavelet.internal.cwt.findPeriodIndices(Na,params.periods,params.periodrange,isReal);
        wtPos(idxZero,:) = zeros(1,1,'like',wtPos);
    else
        [idxZeroPos,idxZeroNeg] = wavelet.internal.cwt.findPeriodIndices(Na,params.periods,params.periodrange,isReal);
        wtPos(idxZeroPos,:) = zeros(1,1,'like',wtPos);
        wtNeg(idxZeroNeg,:) = zeros(1,1,'like',wtPos);
    end

end

% In case the Morse parameters were entered as single
morseparams = cast([params.ga params.be],'double');
% Obtain admissibility constant
cpsi = real(cast(wavelet.internal.cwt.admConstant(params.wavname,morseparams),...
    'like',wtPos));


% Invert using Morlet's single integral formula. The synthesis wavelet
% is a delta distribution
a0 = 2^ds;
if strcmpi(sigtype,'real')
    Wr = 2*log(a0)*(1/cpsi)*real(wtPos);
else
    Wr = 2*log(a0)*(1/cpsi)*(wtPos+wtNeg);
end

xrec = sum(Wr,1);
% Add in possibly time-varying mean or scaling coefficients
if ~isempty(params.SignalMean)
    xrec = xrec+params.SignalMean;
elseif ~isempty(params.LPcfs)
    xrec = xrec+params.LPcfs;
end

%-------------------------------------------------------------------------
function [params,psif] = parseInputs(Na,N,sigtype,datatype,varargin)
coder.varsize('LPCoefs',[1 Inf],[0 1]);
coder.varsize('SignalMean',[1 Inf],[0 1]);
coder.varsize('pfvecN');
coder.varsize('freqrange');
coder.varsize('fvec');
pfvecN = zeros(0,0,datatype);
fvec = zeros(0,0,datatype);
freqrange = zeros(0,0,datatype);
ga = zeros(0,0,datatype);
be = zeros(0,0,datatype);

defaultWav = "morse";
opArgs =  {'wname','f','frange'};
pvNames = {'AnalysisFilterBank','WaveletParameters','ScalingCoefficients',...
    'VoicesPerOctave','TimeBandwidth','SignalMean'};
poptions = struct( ...
    'CaseSensitivity',false, ...
    'PartialMatching','unique', ...
    'StructExpand',false, ...
    'IgnoreNulls',true);
% Parse inputs for code generation
pstruct = coder.internal.parseInputs(opArgs,pvNames,poptions,varargin{:});
pwname = coder.internal.getParameterValue(pstruct.wname,defaultWav,varargin{:});
validateattributes(pwname,{'char','string'},{'scalartext'},'icwt','wname');
pfvec = coder.internal.getParameterValue(pstruct.f,zeros(0,0,datatype),varargin{:});
pfreqrange = coder.internal.getParameterValue(pstruct.frange,zeros(0,0,datatype),varargin{:});
ptmpAnalF = coder.internal.getParameterValue(pstruct.AnalysisFilterBank,[],varargin{:});
pWaveP = coder.internal.getParameterValue(pstruct.WaveletParameters,zeros(0,0,datatype),varargin{:});
pLPCoefs = coder.internal.getParameterValue(pstruct.ScalingCoefficients,zeros(0,0,datatype),varargin{:});
LPCoefs = validateScalingCoefficients(pLPCoefs,N,sigtype,datatype);
pSignalMean = coder.internal.getParameterValue(pstruct.SignalMean,zeros(0,0,datatype),varargin{:});
SignalMean = validateSignalMean(pSignalMean,N,sigtype,datatype);
pVoices = coder.internal.getParameterValue(pstruct.VoicesPerOctave,zeros(0,0,datatype),varargin{:});
pTimeB = coder.internal.getParameterValue(pstruct.TimeBandwidth,zeros(0,0,datatype),varargin{:});
if underlyingType(ptmpAnalF) ~= datatype
    pAnalF = cast(ptmpAnalF,datatype);
else
    pAnalF = ptmpAnalF;
end
validateattributes(pfvec,{'numeric','duration'},{},'icwt','F');
validateattributes(pfreqrange,{'numeric','duration'},{},'icwt','FREQRANGE');
% Exclude options not compatible with analysis filters
coder.internal.errorIf( ~isempty(pAnalF) && ...
    (~isempty(pVoices) || ~isempty(pSignalMean) || ~isempty(pTimeB) ...
        || ~isempty(pWaveP)),'Wavelet:cwt:AnalysisMorlet');

% Illegal to specify time-bandwidth and Morse parameters
coder.internal.errorIf(~isempty(pTimeB) && ~isempty(pWaveP),...
    'Wavelet:cwt:paramsTB');

% Cannot specify signal mean and scaling coefficients
coder.internal.errorIf(~isempty(pLPCoefs) && ~isempty(pSignalMean), ...
    'Wavelet:cwt:scalcfsmean')

% A frequency or period vector must come in a pair frequency range or
% period range
coder.internal.errorIf((isempty(pfvec) && ~isempty(pfreqrange)) || ...
    (~isempty(pfvec) && isempty(pfreqrange)),'Wavelet:cwt:FreqPeriod');

% Validate wavelet name
wname = validatestring(pwname,{'Morse','amor','bump'},'icwt','WNAME');
coder.internal.errorIf(wname ~= "Morse" && ...
    (~isempty(pWaveP) || ~isempty(pTimeB)),'Wavelet:cwt:InvalidParamsWavelet');

if ~isempty(pVoices)
    validateattributes(pVoices,{'double','single'},{'scalar','>=',1,'<=',48},'ICWT','VoicesPerOctave');
    Voices = cast(pVoices,datatype);
end
    
% Validate timebandwidth
if ~isempty(pTimeB)
    validateattributes(pTimeB,{'numeric'},{'scalar','>=',3,'<=',120},...
        'ICWT','TimeBandwidth');
    TimeB = cast(pTimeB,datatype);
    ga = cast(3,datatype);
    be = TimeB/ga;    
end

% Validate Morse parameters
if ~isempty(pWaveP)
    validateattributes(pWaveP,{'numeric'},{'vector','numel',2},...
        'ICWT','WaveletParameters');
    validateattributes(pWaveP(1),{'numeric'},{'scalar','>=',1});
    validateattributes(pWaveP(2),{'numeric'},{'scalar','>=',pWaveP(1)});
    coder.internal.errorIf(pWaveP(2)/pWaveP(1) > 40,'Wavelet:cwt:TBupperbound');
    % assign \gamma and \beta
    WaveP = cast(pWaveP,datatype);
    TB = WaveP(2);
    ga = WaveP(1);
    be = TB/ga; 
end

if isempty(pWaveP) && isempty(pTimeB)
    ga = cast(3,datatype);
    be = cast(20,datatype);
end

if ~isempty(pLPCoefs)
   validateattributes(pLPCoefs,{'double','single'},{'vector','finite'}); 
   LPCoefs = pLPCoefs;    
end

% Set frequency input and period input initially to false. Initialze 
% frequency and period vectors and ranges for code generation.
FrequencyInput = false;
PeriodInput = false;

if isempty(pfvec) && isempty(pfreqrange)
    FrequencyInput = true;
end

% Here we detect a frequency vector
if ~isempty(pfvec) && isnumeric(pfvec)
    % Must equal the number of scales
    validateattributes(pfvec,{datatype},{'vector','decreasing',...
        'numel',Na},'icwt','Frequencies');
    fvec = pfvec(:);
    FrequencyInput = true;
end

pvecFormat = '';
prangeFormat = '';
% If it is a duration array, then we convert to the proper numeric input.
if ~isempty(pfvec) && isduration(pfvec)
    coder.internal.errorIf(isempty(pfreqrange) || ~isduration(pfreqrange),...
        'Wavelet:cwt:PeriodOrFrequency');
    % We use pfvecN in the function but need the original for validation
    [pfvecN,pvecFormat] = durationToNumeric(pfvec,datatype);
    validateattributes(pfvecN,{datatype},{'vector','increasing',...
        'numel',Na},'icwt','Periods');
    fvec = pfvecN(:);
    PeriodInput = true;
    FrequencyInput = false;
end

% For frequencies and frequency range
if ~isempty(pfreqrange) && isnumeric(pfreqrange)
    % If the frequency range is numeric but the frequencies are durations
    coder.internal.errorIf(isduration(pfvec) && isnumeric(pfreqrange),...
        'Wavelet:cwt:PeriodOrFrequency');

    % General validation of element type in FREQRANGE
    validateattributes(pfreqrange,{datatype},...
        {'finite','real','2d'},'FREQRANGE','icwt');
    isVector = isrow(pfreqrange) || iscolumn(pfreqrange);
    if isVector
        validateattributes(pfreqrange,{'numeric'},...
            {'numel',2,'increasing'},'icwt','FREQRANGE');
    else
        validateattributes(pfreqrange,{'numeric'},...
            {'size',[2,2]},'icwt','FREQRANGE')
        coder.internal.errorIf(...
            ~issorted(pfreqrange,2,'ComparisonMethod','real'),...
            'Wavelet:cwt:SortedFreqRange');
    end
    if isVector
        freqrange = pfreqrange(:)';
    else
        freqrange = pfreqrange;
    end
end

% For periods and period range
if ~isempty(pfreqrange) && isduration(pfreqrange)
    coder.internal.errorIf(isnumeric(pfvec) && isduration(pfreqrange),...
        'Wavelet:cwt:PeriodOrFrequency');
    % Convert to numeric and capture format. Format must agree with range.
    [pfreqRN,prangeFormat] = durationToNumeric(pfreqrange,datatype);
    PeriodInput = true;
    % General validation of element type in FREQRANGE
    validateattributes(pfreqRN,{datatype},{'finite','real','2d'});
    isVector = isrow(pfreqRN) || iscolumn(pfreqRN);
    if isVector
        validateattributes(pfreqRN,{'numeric'},...
            {'numel',2,'increasing'},'icwt','PERIODRANGE');
    else
        validateattributes(pfreqRN,{datatype},...
            {'size',[2,2]},'icwt','PERIODRANGE')
        coder.internal.errorIf(...
            ~issorted(pfreqRN,2,'ComparisonMethod','real'),...
            'Wavelet:cwt:SortedPeriodRange');
    end

    if isVector
        freqrange = pfreqRN(:)';
    else
        freqrange = pfreqRN;
    end
    
end

if ~isempty(pvecFormat) && ~isempty(prangeFormat)
    % These will always be scalars but code generation gets confused
    coder.internal.errorIf(pvecFormat(1) ~= prangeFormat(1),'Wavelet:cwt:PeriodUnits');
end

coder.internal.errorIf(FrequencyInput && PeriodInput,...
    'Wavelet:cwt:PeriodOrFrequency')

if ~isempty(pAnalF)
    [psif,invMethod] = validateAnalysisFB(N,Na,pAnalF,datatype);
else
    psif = zeros(0,0,datatype);
    invMethod = 'morlet';
end

mustUseMorlet = startsWith(invMethod,'s') &&  (~isempty(pTimeB) || ~isempty(pWaveP) ...
    || ~isempty(pSignalMean) || ~isempty(pVoices));
coder.internal.errorIf(mustUseMorlet,'Wavelet:cwt:AnalysisMorlet');

coder.internal.errorIf(~isempty(pVoices) && ~isempty(pfvec),...
    'Wavelet:cwt:NVandFrequencies');

% assign ds
if ~isempty(pVoices) && isempty(pfvec)
    ds = 1/Voices;   
elseif isempty(pVoices) && (~isempty(pfvec) && isnumeric(pfvec))
    ds = getScType(1./pfvec);
elseif isempty(pVoices) && (~isempty(pfvec) && isduration(pfvec))
    ds = getScType(pfvecN);
else
    ds = cast(0.1,datatype);
end

% Create structure array for Morlet single-integral method
params = struct('wavname',wname,'ga',ga,'be',be,...
        'SignalMean',SignalMean,'LPcfs',LPCoefs,'ds',ds,...
        'freqrange',zeros(0,0,datatype),'f',zeros(0,0,datatype),...
        'periodrange',zeros(0,0,datatype),'periods',zeros(0,0,datatype),...
        'invMethod',invMethod,'AnalysisFilters',psif);
coder.varsize('params.AnalysisFilters');
coder.varsize('params.freqrange');
coder.varsize('params.f');
if FrequencyInput && startsWith(invMethod,'m')
    params = struct('wavname',wname,'ga',ga,'be',be,...
        'SignalMean',SignalMean,'LPcfs',LPCoefs,'ds',ds,...
        'freqrange',freqrange,'f',fvec,'periodrange',zeros(0,0,datatype),...
        'periods',zeros(0,0,datatype),'invMethod',invMethod,...
        'AnalysisFilters',psif);
elseif PeriodInput && startsWith(invMethod,'m')
    params = struct('wavname',wname,'ga',ga,'be',be,...
        'SignalMean',SignalMean,'LPcfs',LPCoefs,'ds',ds,...
        'freqrange',zeros(0,0,datatype),'f',zeros(0,0,datatype),'periodrange',freqrange,...
        'periods',fvec,'invMethod',invMethod,'AnalysisFilters',psif);

end

%--------------------------------------------------------------------------
function [d,tsformat] = durationToNumeric(p,datatype)
tsformat = p.Format(1);
switch tsformat
    case 's'
        d = cast(seconds(p),datatype);
    case 'm'
        d = cast(minutes(p),datatype);
    case 'h'
        d = cast(hours(p),datatype);
    case 'd'
        d = cast(days(p),datatype);
    case 'y'
        d = cast(years(p),datatype);
    otherwise
        coder.internal.error('Wavelet:FunctionInput:IncorrectDuration');
end
%--------------------------------------------------------------------------
function meanvec = validateSignalMean(sigmean,N,sigtype,datatype)

if isempty(sigmean)
    meanvec = cast(sigmean,datatype);
    return;
else
    % Ensure that the signal mean is correct if entered. Must be a scalar or
    % vector and match the complexity of the input
    validateattributes(sigmean,{datatype},{'finite','nonsparse'},...
        'icwt','SignalMean');
         
    coder.internal.errorIf(...
        ~(numel(sigmean) == 1 || numel(sigmean) == N),...
        'Wavelet:cwt:InvalidSignalMean');

    imagMean = any(imag(sigmean));
    coder.internal.errorIf((imagMean && startsWith(sigtype,'r')) || ...
        (~imagMean && startsWith(sigtype,'c')), 'Wavelet:cwt:InvalidSignalMean');
end

if ~isscalar(sigmean)
    meanvec = sigmean(:).';
else
    meanvec = sigmean;
end

%--------------------------------------------------------------------------
function scalcfs = validateScalingCoefficients(LPCoefs,N,sigtype,datatype)

if isempty(LPCoefs)
    scalcfs = LPCoefs;
    return;
else
    % Ensure that the signal mean is correct if entered. Must be a scalar or
    % vector and match the complexity of the input
    validateattributes(LPCoefs,{datatype},{'vector','finite','nonsparse','numel',N},...
        'icwt','ScalingCoefficients');
    imagScal = any(imag(LPCoefs));
    coder.internal.errorIf((imagScal && startsWith(sigtype,'r')) || ...
        (~imagScal && startsWith(sigtype,'c')), 'Wavelet:cwt:InvalidSignalMean');
end

if iscolumn(LPCoefs)
    scalcfs = LPCoefs(:).';
else
    scalcfs = LPCoefs;
end







