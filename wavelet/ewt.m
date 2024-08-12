function [varargout] = ewt(x,varargin)
% MRA = EWT(X) returns the empirical wavelet transform (EWT)
% multiresolution analysis (MRA) components of X. X is a real- or
% complex-valued vector or single-variable timetable containing a single
% column vector. X must have at least two samples. X can be double- or
% single-precision. When X is a vector, MRA is a matrix where each column
% stores an extracted MRA component. For real-valued X, the MRA components
% are ordered by decreasing center frequencies. See the INFO structure
% array for a description of the frequency bounds for the empirical wavelet
% and scaling filters. The final column of MRA corresponds to the lowpass
% scaling filter. For complex-valued X, the MRA components start near -1/2
% cycles per sample and decrease in center frequency until the lowpass
% scaling coefficients are obtained. The frequency then increases toward 
% +1/2 cycles per sample.
%
% When X is a timetable, MRA is a timetable with multiple single
% variables where each variable stores an MRA component.
%
% By default, the number of empirical wavelet filters is automatically
% determined by identifying peaks in a multitaper power spectral estimate
% of X. See the EWT documentation for details on the algorithm for
% segmenting the spectrum of X.
%
% If X has less than 64 samples, EWT works on a zero-padded version of X of
% length 64. The MRA components are truncated to the original length.
% 
% [MRA,CFS] = EWT(X) returns the EWT analysis coefficients of X. CFS is a
% matrix where each column stores the EWT coefficients for the
% corresponding MRA component. The frequency bands of the EWT analysis
% coefficients are identical to the ordering of the MRA components. If X
% has less than 64 samples, CFS contains the EWT analysis coefficients
% obtained from the zero-padded version of X.
%
% [MRA,CFS,WFB] = EWT(X) returns the empirical wavelet filter bank used in
% the analysis of X. The center frequencies of the filters in WFB match
% the order in MRA and CFS. 
%
% If X has less than 64 samples, WFB are the empirical wavelet and scaling
% filters for the zero-padded version of X.
%
% Because the empirical wavelets form a Parseval tight frame, the analysis
% filter bank is equal to the synthesis filter bank.
%
% [MRA,CFS,WFB,INFO] = EWT(X) returns a structure array, INFO, with the
% following fields:
%
%   PeakFrequencies: The peak normalized frequencies in cycles/sample
%   identified in X as a column vector. For real-valued X, the frequencies
%   are positive in the interval (0,1/2) in decreasing order. For
%   complex-valued X, the frequencies are ordered from (-1/2, 1/2). If
%   PeakFrequencies is empty, EWT did not find any peaks and a default
%   one-level discrete wavelet transform (DWT) subdivision is used. See the
%   EWT documentation for details.
%
%   FilterBank: FilterBank is a MATLAB table with two variables:
%   MRAComponent and Passbands. MRAComponent is the column index of the MRA
%   component in MRA. Passbands is a L-by-2 matrix where L is the number of
%   MRA components. Each row of Passbands is the approximate frequency
%   passband in cycles/sample for the corresponding EWT filter and MRA
%   component.
%
% [...] = EWT(...,'PeakThresholdPercent',THRESH) uses the percentage,
% THRESH, to determine which peaks to retain in the multitaper power
% spectrum of X. Local maxima in the multitaper power spectral estimate of
% X are normalized to lie in the range [0,1] with the maximum peak equal to
% 1. All peaks with values strictly greater than THRESH percent of the
% maximum peak are retained. THRESH is a real number in the interval
% (0,100). If unspecified THRESH defaults to 70.
%
% [...] = EWT(...,'SegmentMethod',SMETHOD) determines the EWT filter
% passbands using either the geometric mean of adjacent peaks or the first
% local minimum between adjacent peaks. Valid options are 'geomean' or
% 'localmin'. If unspecified, SegmentMethod defaults to 'geomean'. If no
% local minimum is identified between adjacent peaks, the geometric mean is
% used.
%
% [...] = EWT(...,'MaxNumPeaks',NP) uses the largest NP peaks to determine
% the EWT filter passbands. MaxNumPeaks and PeakThresholdPercent cannot
% both be specified. If EWT finds less than NP peaks, EWT uses the maximum
% number of peaks. If no peaks are identified, EWT uses a level-one DWT
% filter bank.
%
% [...] = EWT(...,'FrequencyResolution',FR) specifies the frequency
% resolution bandwidth of the multitaper power spectral estimate as a
% real-valued scalar. The value of FR determines how many sine tapers are
% used in the multitaper power spectrum estimate. The approximate bandwidth
% of a sine multitaper power spectral estimate is (K+1/2)/(N+1) where K is
% the number of tapers and N is the length of the signal. The minimum value
% of FR is 2.5/N where N is the maximum of the length of the signal or 64.
% The maximum value of FR is 0.25. The number of sine tapers is determined
% by round((N+1)*FR/N-1/2) when FrequencyResolution is specified. The
% default value is 5.5/N, which means that 5 sine tapers are used in the
% spectral estimate.
%
% [...] = EWT(...,'LogSpectrum',TF) uses the log of the multitaper power
% spectrum to determine the peak frequencies if TF is true. By default, TF
% is false. Consider setting TF to true if using the PeakThresholdPercent
% segmentation method and there is a dominant peak frequency which is
% significantly larger in magnitude than other peaks.
%
% EWT(...) with no output arguments plots the original signal along with
% the empirical wavelet MRA in the same figure. For complex-valued data,
% the real part is plotted in the first color in the MATLAB color order
% matrix and the imaginary part is plotted in the second color.
% 
% 
%   %Example: Plot the empirical wavelet transform of an ECG signal. Set
%   %   the maximum number of peaks to 5.  
%
%   load wecg;
%   ewt(wecg,'MaxNumPeaks',5)
%
%   %Example: Create a synthetic complex-valued signal sampled at 1000 Hz
%   %   consisting of 4 sinusoidal components in additive noise. Obtain the
%   %   EWT of the signal. Display the identified peak frequencies and
%   %   associated EWT filter passbands. The peak frequencies and passbands
%   %   are returned as normalized frequencies. Multiply both by the sample
%   %   rate to obtain both in Hz.
%
%   t = 0:0.001:2-0.001;
%   z = exp(-1j*2*pi*200*t)+exp(-1j*2*pi*100*t)+exp(1j*2*pi*50*t)+...
%       exp(1j*2*pi*150*t)+0.1*(randn(size(t))+1j*randn(size(t)));
%   [mra,~,~,info] = ewt(z);
%   info.PeakFrequencies*1e3
%   info.FilterBank.Passbands*1e3
% 
%
% See also EMD, MODWTMRA, signalMultiresolutionAnalyzer, VMD

%   Copyright 2020 The MathWorks, Inc.

%#codegen

narginchk(1,9);
% 0 to 4 output arguments
if coder.target('MATLAB')
    nargoutchk(0,4);
else
    nargoutchk(1,4);
end
% Parse inputs
[x,params,isTT] = parseinputs(x,varargin{:});


% Reshape vector as column vector.
x = x(:);
%Input must contain at least two samples
coder.internal.errorIf(length(x) < 2,'Wavelet:modwt:LenTwo');

% If original length is less than 64, we pad out to 64.
Norig = length(x);
if Norig < 64
    Npad = cast(64,class(x));
else
    Npad = cast(Norig,class(x));
end
% Determine the number of sine tapers from the frequency resolution and
% the possibly padded length
numtapers = iNumTapers(params.FR,Npad);

% This is the frequency resolution in radians/sample.
domega = (2*pi)/Npad;

% Fourier transform of the input. Note that xdft is different from the
% power spectrum used to segment the spectrum.
xdft = fft(x,Npad);

% MT power spectrum estimate
% Pad the data if the number of points is less than 64.
xr = [x ; zeros(Npad-Norig,1)];
% Sine tapers
[h,bw,~] = ...
    wavelet.internal.sinetapers(length(xr),numtapers,class(xr));

% Bandwidth in DFT bins. Now that we know the bandwidth in DFT bins
% and have potentially padded the input data, we can validate the maximum
% number of peaks if requested. 
if ~isempty(params.MaxNumPeaks)
   UL = round(length(xr)/bw);
   validateattributes(params.MaxNumPeaks,{'numeric'},...
       {'scalar','integer','nonnan','positive'},'EWT','MaxNumPeaks');
   % SPRINTF() and cast to integer is for MATLAB Coder
   coder.internal.errorIf(params.MaxNumPeaks > UL,...
       'Wavelet:ewt:BeyondUL',sprintf('%d',cast(UL,'int32')));
end


xr = xr -mean(xr);
% Implicit expansion not supported for code generation.
if coder.target('MATLAB')
    tmpx = xr.*h;
else
    tmpx = bsxfun(@times,xr,h);
end

% MT power spectral estimate using sine tapers
tmpxdft = mean(abs(fft(tmpx)).^2,2);

% We are explicitly not including the Nyquist, \pi radians/sample.
% Work on 1/2 the spectrum for real-valued.
M = round(Npad/2);

if params.real 
    sigtype = 'real';
    %omega = 0:domega:pi;
    % For code generation
    tmpxdft2 = tmpxdft(1:M);    
else
     sigtype = 'complex';
     % working on full frequency vector for complex-valued signals for 
     % peak identification.
    % omega = 0:domega:2*pi-domega;  
     tmpxdft2 = tmpxdft;
end


if ~isempty(params.MaxNumPeaks)
    NC = params.MaxNumPeaks;
    DFTKeptBins = wavelet.internal.maxnumpeaks(tmpxdft2,NC,bw,params.log);
else
    DFTKeptBins = ...
        wavelet.internal.peakThresh(tmpxdft2,bw,params.PT,params.log);   
    
end


% Guard against empty spectral segmentation.
if isempty(DFTKeptBins) && params.real
    boundaries = cast(pi/2,class(xr));
elseif isempty(DFTKeptBins) && ~params.real
    boundaries = cast([-pi/2 ; pi/2],class(xr));
elseif ~isempty(DFTKeptBins) && strcmpi(params.segmethod,'localmin')
    boundaries = wavelet.internal.localminBounds(tmpxdft2,DFTKeptBins,bw,Npad);
    %boundaries = wavelet.internal.localminBounds(tmpxdft2,DFTKeptBins,bw);
    boundaries = (boundaries-1)*domega;
else
    boundaries = wavelet.internal.geomeanBounds(DFTKeptBins,Npad);
    boundaries = (boundaries-1)*domega;

end
PeakFrequencies = (DFTKeptBins-1)./Npad;
PeakFrequencies(PeakFrequencies > 1/2) = ...
    -1+PeakFrequencies(PeakFrequencies > 1/2);
if params.real
    PeakFrequencies = sort(PeakFrequencies,'descend');
else
    PeakFrequencies = sort(PeakFrequencies);
end
if params.real
    boundaries(boundaries > pi-3*domega) = [];
else
    boundaries(boundaries > pi) = -(2*pi)+boundaries(boundaries > pi);
    boundaries = sort(boundaries);
end

% Based on the frequency boundaries, determine gamma.
gamma = determineGamma(boundaries,class(x),domega);

% We build the corresponding filter bank
w = wavelet.internal.omvector(Npad,'angular','centered');
[wfb,adjboundaries] = wavelet.internal.EWTFB(w,boundaries,Npad,gamma,sigtype);
% Output boundaries as cycles/sample
fbounds = adjboundaries./(2*pi);
if strcmpi(sigtype,'real')
    Boundaries = cast([0 ; fbounds; 1/2],class(x));
    Boundaries = sort(Boundaries,'descend');
else
    Boundaries = cast([-1/2 ; fbounds; 1/2],class(x));
end


% For the analysis filters in a frame, we would normally use the complex
% conjugate of the vector. But in this case, the EWT filters are
% real-valued in the Fourier domain.
if strcmpi(sigtype,'real') && coder.target('MATLAB')
    cfs = real(ifft(wfb.*xdft,Npad));
    
elseif strcmpi(sigtype,'real') && ~coder.target('MATLAB')
    cfs = real(ifft(bsxfun(@times,wfb,xdft),Npad));
elseif strcmpi(sigtype,'complex') && coder.target('MATLAB')
    cfs = ifft(wfb.*xdft,Npad);
else
    cfs = ifft(bsxfun(@times,wfb,xdft),Npad);
end

if strcmpi(sigtype,'real') && coder.target('MATLAB')
    MRA = real(ifft(fft(cfs).*wfb,Npad));
elseif strcmpi(sigtype,'real') && ~coder.target('MATLAB')
    MRA = real(ifft(bsxfun(@times,fft(cfs),wfb),Npad));
elseif strcmpi(sigtype,'complex') && coder.target('MATLAB')
    MRA = ifft(fft(cfs).*wfb,Npad);
else
    MRA = ifft(bsxfun(@times,fft(cfs),wfb),Npad);
end

MRA = MRA(1:Norig,:);


if (nargout == 0) && coder.target('MATLAB')
    if strcmpi(sigtype,'real')
        mratype = 'RealEWT';
    else
        mratype = 'ComplexEWT';
    end
    hplot = wavelet.internal.mraPlot([x(:) MRA],mratype,params.td);
    % Prepare for next figure
    hplot.hFig.NextPlot = 'replacechildren';
end

if nargout > 0 
    if isTT && coder.target('MATLAB')
        MRA = array2timetable(MRA,'RowTimes',params.td);
      
    end
    varargout{1} = MRA;
    varargout{2} = cfs;
    varargout{3} = wfb;   
    MRAComponent = 1:size(MRA,2);
    MRAComponent = MRAComponent(:);
    if params.real
        Passbands = [Boundaries(2:end) Boundaries(1:end-1)];
    else
        Passbands = [Boundaries(1:end-1) Boundaries(2:end)];
    end
    % Create info structure array
    info = struct('PeakFrequencies',PeakFrequencies,'FilterBank',...
        table(MRAComponent,Passbands,...
        'VariableNames',{'MRAComponent','Passbands'}));
    varargout{4} = info;
end


function [x,params,isTT] = parseinputs(x,varargin)
isTT = isa(x,'timetable');

if isTT
    if ~coder.target('MATLAB')
        coder.internal.error('shared_signalwavelet:vmd:vmd:TimetableNotSupportedCodegen');
    else
        signalwavelet.internal.util.utilValidateattributesTimetable(x,...
            {'sorted','singlechannel','regular'});
        [x, ~, td] = signalwavelet.internal.util.utilParseTimetable(x);
        params.td = td;
    end
else
    td = 1:length(x);
    params.td = td(:);
end  

validateattributes(x,{'double','single'},{'vector','finite'},'EWT','X');
    
validSegment = {'localmin','geomean'};



% Is the input real
params.real = ~any(imag(x(:)));
% We will pad any vector with less than 64 samples to 64.
Nsamp = max(64,length(x));

maxnumpks = [];
defaultAlpha = 0.70;
defaultseg = 'geomean';
defaultFR = 5.5/Nsamp;
minFR = 2.5/(Nsamp+1);
if coder.target('MATLAB')
    p = inputParser;
    p.addParameter('MaxNumPeaks',maxnumpks);
    p.addParameter('PeakThresholdPercent',[]);
    p.addParameter('LogSpectrum',false);
    p.addParameter('FrequencyResolution',defaultFR);
    p.addParameter('SegmentMethod',defaultseg);
    p.parse(varargin{:});
    params.MaxNumPeaks = p.Results.MaxNumPeaks;
    % For code generation do not assign directly to params.PT. Validate
    % on ptval and then assign to params.PT
    ptval = p.Results.PeakThresholdPercent;
    params.log = p.Results.LogSpectrum;
    params.FR = p.Results.FrequencyResolution;
    params.segmethod = ...
        validatestring(p.Results.SegmentMethod,validSegment,'EWT');
else
    % Code generation input parsing. Structure array for parameters
    parms = struct('MaxNumPeaks',uint32(0),...
                    'PeakThresholdPercent',uint32(0),...
                    'LogSpectrum',uint32(0),...
                    'SegmentMethod',uint32(0),...
                    'FrequencyResolution',uint32(0));
    % Structure array for options
    popts = struct('CaseSensitivity',false, ...
                    'PartialMatching',true);
    % Parse structure array with options
    pstruct = coder.internal.parseParameterInputs(parms,popts,varargin{:});
    maxnumpks = ...
            coder.internal.getParameterValue(pstruct.MaxNumPeaks,maxnumpks,varargin{:});
    params.MaxNumPeaks = maxnumpks;
    ptval = ...
        coder.internal.getParameterValue(pstruct.PeakThresholdPercent,[],varargin{:});
    % For code generation. Initialize params.PT to a scalar so that we can
    % then assign another scalar value.
    params.PT = 0;
    logspec = ...
        coder.internal.getParameterValue(pstruct.LogSpectrum,false,varargin{:});
    params.log = logspec;
    segmeth = ...
        coder.internal.getParameterValue(pstruct.SegmentMethod,defaultseg,varargin{:});
    segmeth = validatestring(segmeth,validSegment,'EWT','SegmentMethod');
    params.segmethod = segmeth;
    fres = ...
        coder.internal.getParameterValue(pstruct.FrequencyResolution,defaultFR,varargin{:});
    params.FR = fres;
    
    
end


if ~isempty(ptval)
    validateattributes(ptval,{'numeric'},{'scalar','>',0,'<',100},...
    'EWT','PeakThresholdPercent');
    params.PT = ptval/1e2;
end

validateattributes(params.FR, {'numeric'},...
    {'scalar','>=',minFR,'<=',1/4},'EWT','FrequencyResolution');
validateattributes(params.log,{'logical','numeric'},...
    {'scalar','real','finite','nonnan','nonempty'},'EWT','LogSpectrum');
coder.internal.errorIf(~isempty(params.MaxNumPeaks)...
    && ~isempty(ptval),'Wavelet:ewt:NumPeaksThresh');
if isempty(params.MaxNumPeaks) && isempty(ptval)
    params.PT = defaultAlpha;
end


%--------------------------------------------------------------------------
function gamma = determineGamma(boundaries,prec,dom)
neggamma = cast(0.0,prec);
posgamma = cast(0.0,prec);
gamma = cast(0.0,prec);
boundaries = boundaries(:);
negbounds = boundaries(boundaries < 0);
if ~isempty(negbounds)
    negbounds = cast([-pi; negbounds],prec);
end
posbounds = boundaries(boundaries > 0);
if ~isempty(posbounds)
    posbounds = cast([posbounds ; pi],prec);
end
numneg = diff(negbounds);
numpos = diff(posbounds);
negdenom = movsum(abs(negbounds),2);
negdenom = negdenom(2:end,:);
posdenom = movsum(posbounds,2);
posdenom = posdenom(2:end,:);
if  ~isempty(numneg) && ~isempty(negdenom)
    neggamma = min(numneg./negdenom);
end
if ~isempty(numpos) && ~isempty(posdenom)
    posgamma = min(numpos./posdenom);
end
if ~isempty(negbounds) && ~isempty(posbounds)
    gamma = min(neggamma,posgamma);
elseif ~isempty(posbounds) && isempty(negbounds)
    gamma = min(posgamma);
elseif isempty(posbounds) && ~isempty(negbounds)
    gamma = min(neggamma);
end
gamma = max(gamma-dom,4*dom);

%--------------------------------------------------------------------------
function nt = iNumTapers(fres,Norig)

nt = round((Norig+1)*fres-0.5);






