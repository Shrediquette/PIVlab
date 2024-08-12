function [wcoh,wcs,P,coi,wtx,wty] = wcoherence(x,y,varargin)
%Wavelet coherence
% WCOH = WCOHERENCE(X,Y) returns the magnitude-squared wavelet coherence
% between the equal-length 1-D real-valued signals X and Y using the
% analytic Morlet wavelet. X and Y must have at least 4 samples. The
% wavelet coherence is computed over logarithmic scales using 12 voices per
% octave. The number of octaves is equal to floor(log2(numel(X)))-1.
%
% [WCOH,WCS] = WCOHERENCE(X,Y) returns the wavelet cross spectrum of X and
% Y in WCS.
%
% [WCOH,WCS,PERIOD] = WCOHERENCE(X,Y,Ts) uses the positive <a href="matlab:help duration">duration</a>, Ts,
% to compute the scale-to-period conversion, PERIOD. PERIOD is
% an array of durations with the same Format property as Ts.
%
% [WCOH,WCS,F] = WCOHERENCE(X,Y,Fs) uses the positive sampling frequency,
% Fs, in hertz to compute the scale-to-frequency conversion, F. If you
% output F without specifying a sampling frequency or specifying the
% sampling frequency as empty, WCOHERENCE uses normalized frequency in
% cycles/sample. The Nyquist frequency is 1/2. You cannot specify both a
% sampling frequency and a duration.
%
% [WCOH,WCS,F,COI] = WCOHERENCE(...) returns the cone of influence in
% cycles/sample for the wavelet coherence. If you specify a sampling
% frequency, Fs, in hertz, the cone of influence is returned in hertz.
%
% [WCOH,WCS,F,COI,WTX,WTY] = WCOHERENCE(...) returns the continuous wavelet
% transforms (CWT) of X and Y in WTX and WTY, respectively. WTX and WTY are
% used in the formation of the wavelet cross spectrum and coherence
% estimates.
%
% [...] = WCOHERENCE(...,'FrequencyLimits',FLIMITS) specifies the frequency
% limits to use in WCOHERENCE as a two-element vector with positive
% elements. The elements of FLIMITS must be strictly increasing. The first
% element of FLIMITS specifies the lowest peak passband frequency
% and must be greater than or equal to the product of the wavelet peak
% frequency in hertz and two time standard deviations divided by the signal
% length. The second element of FLIMITS must be less than or equal to the
% Nyquist frequency. The base 2 logarithm of the ratio of the maximum
% frequency to the minimum frequency must be greater than or equal to 1/NV
% where NV is the number of voices per octave. If you specify FLIMITS
% outside the permissible range, WCOHERENCE truncates the limits to the
% minimum and maximum valid values. Use <a href="matlab:help
% cwtfreqbounds">cwtfreqbounds</a> with the wavelet set to 'amor' to
% determine frequency limits for different parameterizations of the wavelet
% coherence.
%
% [...] = WCOHERENCE(...,'PeriodLimits',PLIMITS) specifies the period
% limits to use in WCOHERENCE as a two-element duration array with positive
% elements. The elements of PLIMITS must be strictly increasing. The first
% element of PLIMITS must be greater than or equal to 2*Ts where Ts is the
% sampling period. The base 2 logarithm of the ratio of the minimum period
% to the maximum period must be less than or equal to -1/NV where NV is the
% number of voices per octave. The maximum period cannot exceed the signal
% length divided by the product of two time standard deviations of the
% wavelet and the wavelet peak frequency. If you specify PLIMITS outside
% the permissible range, CWT truncates the limits to the minimum and
% maximum valid values. Use <a href="matlab:help
% cwtfreqbounds">cwtfreqbounds</a> with the wavelet set to 'amor' to
% determine period limits for different parameterizations of the wavelet
% coherence.
%
% [WCOH,WCS,PERIOD,COI] = WCOHERENCE(...,Ts) returns the cone of influence
% in periods for the wavelet coherence. Ts is a positive <a href="matlab:help duration">duration</a>. COI is
% an array of durations with same Format property as Ts.
%
% [...] = WCOHERENCE(...,'VoicesPerOctave',NV) specifies the number of
% voices per octave to use in the wavelet coherence. NV is an even
% integer in the range [10,32]. If unspecified, NV defaults to 12.
%
% [...] = WCOHERENCE(...,'NumScalesToSmooth', NS) specifies the number of
% scales to smooth as a positive integer less than or equal to one half
% the number of scales. If unspecified, NS defaults to the number of voices
% per octave. A moving average filter is used to smooth across scale.
%
% [...] = WCOHERENCE(...,'NumOctaves',NOCT) specifies the number of octaves
% to use in the wavelet coherence. NOCT is a positive integer between 1 and
% floor(log2(numel(X)))-1. NOCT cannot exceed log2(fmax/fmin) where fmax
% and fmin are the maximum and minimum CWT frequencies (or periods) as
% determined by the signal length, sampling frequency, and wavelet. See
% <a href ="matlab:help cwtfreqbounds">cwtfreqbounds</a> for details.
% The 'NumOctaves' name-value pair is not recommended and will be removed
% in a future release. The recommended way to modify the frequency or
% period range of wavelet coherence is with the 'FrequencyLimits' or
% 'PeriodLimits' name-value pairs. You cannot specify both the 'NumOctaves'
% and 'FrequencyLimits' or 'PeriodLimits' name-value pairs.
%
% WCOHERENCE(...) with no output arguments plots the wavelet coherence in
% the current figure window along with the cone of influence. For areas
% where the coherence exceeds 0.5, arrows are also plotted to show the
% phase lag between X and Y. The phase is plotted as the lag between Y and
% X. The arrows are spaced in time and scale.
%
% WCOHERENCE(...,'PhaseDisplayThreshold',PT) displays phase vectors for
% regions of coherence greater than or equal to PT. PT is a real-valued
% scalar between 0 and 1. This name-value pair is ignored if you call
% WCOHERENCE with output arguments.
%
%   % Example 1:
%   %   Plot the wavelet coherence for two signals. Both signals consist
%   %   of two sine waves (10 and 50 Hz) in white noise. The sine waves
%   %   have different time supports. The sampling interval frequency is
%   %   1000 Hz. Set the phase display threshold to 0.7.
%   t = 0:0.001:2;
%   x = cos(2*pi*10*t).*(t>=0.5 & t<1.1)+ ...
%       cos(2*pi*50*t).*(t>= 0.2 & t< 1.4)+0.25*randn(size(t));
%   y = sin(2*pi*10*t).*(t>=0.6 & t<1.2)+...
%       sin(2*pi*50*t).*(t>= 0.4 & t<1.6)+ 0.35*randn(size(t));
%   wcoherence(x,y,1000,'PhaseDisplayThreshold',0.7)
%
%   % Example 2:
%   %   Plot the wavelet coherence between the El Nino time series and the
%   %   All Indian Average Rainfall Index. The data are sampled monthly.
%   %   Set the phase display threshold to 0.7. Specify the sampling
%   %   interval as 1/12 of a year to display the periods in years.
%   load ninoairdata;
%   wcoherence(nino,air,years(1/12),'PhaseDisplayThreshold',0.7);
%
%   See also cwtfilterbank, cwtfreqbounds, duration

%   Copyright 2015-2020 The MathWorks, Inc.

%#codegen

% Minimum number of legal inputs is 2 and maximum is 11
narginchk(2,11);

IsMATLAB = isempty(coder.target);

if IsMATLAB
    nargoutchk(0,6);
else
    nargoutchk(1,6);
end

%Check input vector size
nx = numel(x);
ny = numel(y);

if (~isequal(nx,ny) || numel(x) < 4)
    coder.internal.error('Wavelet:FunctionInput:EqualLengthInput');
end

validateattributes(x,{'single','double'},{'real','finite'},...
    'wcoherence', 'X');
validateattributes(y,{'single','double'},{'real','finite'},...
    'wcoherence', 'Y');

PLimits=[0 0]; %#ok<NASGU>

% Casting input data to the correct type
castType = getPrototypeForCastLike(x,y);
tempx = cast(x,'like',castType);
tempy = cast(y,'like',castType);

% Parse user-supplied inputs
if IsMATLAB
    %Parses inputs in MATLAB path
    [Ts,fs,FLimits,PLimits,nv,nos,~,mincoherence,tsFlag,fsFlag,...
        normalizedfreq] = parseinputsMATLAB(numel(tempx), varargin{:});
else
    %Parses inputs during Code generation
    [Ts,fs,FLimits,PLimits,nv,nos,~,mincoherence,tsFlag,fsFlag,...
        normalizedfreq] = parseinputsCodegen(numel(tempx), varargin{:});
end

% Construct filter bank inputs
if ~nnz(PLimits)
    % Input to CWTFILTERBANK
    fb = cwtfilterbank(coder.const('SignalLength'), nx,...
        coder.const('Wavelet'), 'amor', coder.const('FrequencyLimits'),...
        FLimits, coder.const('SamplingFrequency'), fs,...
        coder.const('VoicesPerOctave'), nv);
    
elseif nnz(PLimits) && IsMATLAB
    if ~nnz(PLimits)
        SampPeriod = seconds(1);
    else
        SampPeriod = Ts;
    end
    
    % Input to CWTFILTERBANK
    fb = cwtfilterbank('SignalLength', nx,'Wavelet', 'amor',...
        'PeriodLimits', PLimits, 'SamplingPeriod', SampPeriod,...
        'VoicesPerOctave', nv);
end
scales = fb.Scales;

% We need the following for plotting
[FourierFactor,sigmaT] = wavelet.internal.cwt.wavCFandSD(fb.Wavelet);

% Get number of voices per octave
nov = nv;

% Obtain minimum coherence level
mc = mincoherence;

% Number of scales to smooth
if isempty(nos)
    ns = min(floor(numel(scales)/2),nov);
else
    ns = nos;
end

% CWT of x
[cwtx,f,coitmp] = fb.wt(tempx);

% CWT of y
cwty = fb.wt(tempy);

% Validate smooth factor now that we know the number of scales obtained in
% the CWT
Nscale = fix(size(cwtx,1)/2);
validateattributes(ns,{'numeric'},{'scalar','integer','positive','<=',...
    Nscale},'wcoherence','NumScalesToSmooth');
cfs1 = wavelet.internal.cwt.smoothCFS(abs(cwtx).^2,scales,ns);
cfs2 = wavelet.internal.cwt.smoothCFS(abs(cwty).^2,scales,ns);
crossCFS = cwtx.*conj(cwty);
crossCFS = wavelet.internal.cwt.smoothCFS(crossCFS,scales,ns);
crosspec = crossCFS./(sqrt(cfs1).*sqrt(cfs2));
wtc = abs(crossCFS).^2./(cfs1.*cfs2);

if IsMATLAB
    wtc = min(wtc,1,'includenan');
else
    wtc(wtc > 1) = 1;
end

if IsMATLAB
    if nargout == 0
        N = size(cfs1,2);
        % If sampling frequency is specified, dt = 1/fs
        if (~fsFlag && ~tsFlag)
            % The default sampling interval is 1 for normalized frequency
            dt = 1;
        elseif (fsFlag && ~tsFlag)
            % Accept the sampling frequency in hertz
            dt = 1/fs;
        elseif (~fsFlag&& tsFlag)
            % Get the dt and Units from the duration object
            [dt,~,plotstring,~,dtFunc] = wavelet.internal.parseDuration(...
                Ts,Ts.Format(1));
        end
        
        % General time vector
        t = 0:dt:N*dt-dt;
    end
    
    if ((nargout == 0) && tsFlag)
        plotcoherenceperiod(wtc,crosspec,dtFunc(f),t,dtFunc(coitmp),...
            nov,mc,plotstring);
        
    elseif (nargout==0 && (fsFlag || normalizedfreq))
        plotcoherencefreq(wtc,crosspec,FourierFactor,sigmaT,f,t,...
            nov,mc,normalizedfreq);
    end
end

if nargout > 0
    wcoh = wtc;
    wcs = crosspec;
    coi = coitmp';
    P = f;
    wtx = cwtx;
    wty = cwty;
end
end
%-------------------------------------------------------------------------

function [ts,fs,FLimits,PLimits,nv,...
    nos,numoct,mincoherence,tsFlag,fsFlag,normalizedfreq,...
    engunits] = parseinputsMATLAB(N,varargin)

% Set up defaults
[defaultPLimits,defaultFLimits,defaultval_freqper,~,...
    defaultnv,~,defaultnumoct,defaultmincoherence,...
    tsFlag,fsFlag,PL_flg,FL_flg,errFlag] = defaultValues(N);

if isempty(varargin)
    ts = seconds([]);
    fs = defaultval_freqper;
    FLimits = defaultFLimits;
    PLimits = defaultPLimits;
    normalizedfreq = 1;
    nos = [];
    numoct = defaultnumoct;
    mincoherence = defaultmincoherence;
    nv = defaultnv;
else
    % MATLAB path
    tfcalendarDuration = cellfun(@iscalendarduration,varargin);
    
    % Error out if there are any calendar duration objects
    if any(tfcalendarDuration)
        error(message('Wavelet:FunctionInput:CalendarDurationSupport'));
    end
    
    p = inputParser;
    p.addParameter('periodlimits',defaultPLimits);
    p.addParameter('frequencylimits',defaultFLimits);
    p.addParameter('phasedisplaythreshold',defaultmincoherence);
    p.addParameter('numoctaves',defaultnumoct);
    p.addParameter('voicesperoctave',defaultnv);
    p.addParameter('numscalestosmooth',[]);
    p.addOptional('optional1',defaultval_freqper);
    p.addOptional('optional2',seconds([]));
    
    p.parse(varargin{:});
    
    PLimits = p.Results.periodlimits;
    FLimits = double(p.Results.frequencylimits);
    mincoherence = double(p.Results.phasedisplaythreshold);
    numoct = double(p.Results.numoctaves);
    nv = double(p.Results.voicesperoctave);
    nos = double(p.Results.numscalestosmooth);
    temp_op1 = p.Results.optional1;
    temp_op2 = p.Results.optional2;
    
    if isempty(temp_op2)
        if (isnumeric(temp_op1) && isscalar(temp_op1))
            fs = double(temp_op1);
            fsFlag = true;
            normalizedfreq = false;
            engunits = true;
        else
            fs = defaultval_freqper;
            normalizedfreq = true;
            engunits = false;
        end
        
        if isduration(temp_op1)
            ts = temp_op1;
            tsFlag = true;
        else
            ts = seconds([]);
        end
    else
        if (isduration(temp_op1) && isduration(temp_op2)) || ...
                ((isnumeric(temp_op1) && isscalar(temp_op1)) && ...
                (isnumeric(temp_op2) && isscalar(temp_op2)))
            errFlag = true;
        else
            tsFlag = true;
            fsFlag = true;
        end
        ts = seconds(0);
        fs = defaultval_freqper;
    end
    
    if ~(isequal(PLimits,defaultPLimits))
        PL_flg = true;
    end
    
    if tsFlag && (ts>0) && (isequal(PLimits,defaultPLimits))
        [~,minperiod] = cwtfreqbounds(N,ts,'Wavelet','amor',...
            'VoicesPerOctave',nv);
        maxperiod = minperiod*(2^numoct);
        PLimits = [minperiod maxperiod];
    end
    
    if ~(isequal(FLimits,defaultFLimits))
        FL_flg = true;
    end
end

% Validate Inputs
FLimits = validateinputs(N,FLimits,PLimits,nv,mincoherence,nos,numoct,...
    fs,ts,tsFlag,fsFlag,PL_flg,FL_flg,errFlag);
end

function [ts,fs,FLimits,PLimits,nv,...
    nos,numoct,mincoherence,tsFlag,fsFlag,normalizedfreq,...
    engunits] = parseinputsCodegen(N,varargin)

% Set up defaults
ts = seconds([]);
fs = 1;

[defaultPLimits,defaultFLimits,defaultval_freqper,...
    ~,defaultnv,~,defaultnumoct,...
    defaultmincoherence,tsFlag,fsFlag,PL_flg,FL_flg,...
    errFlag]  = defaultValues(N);

normalizedfreq = true;
engunits = false;

if isempty(varargin)
    ts = seconds([]);
    fs = defaultval_freqper;
    FLimits = defaultFLimits;
    PLimits = defaultPLimits;
    normalizedfreq = true;
    nos = [];
    numoct = defaultnumoct;
    mincoherence = defaultmincoherence;
    nv = defaultnv;
else
    temp_parse = cell(1,length(varargin));
    [temp_parse{:}] = convertStringsToChars(varargin{:});
    
    tidx = 0;
    
    for i = int8(1:length(temp_parse))
        if (iscalendarduration(temp_parse{i}))
            coder.internal.error(...
                'Wavelet:FunctionInput:CalendarDurationSupport');
        elseif ((i~=1 && ~ischar(temp_parse{i-1}))||i==1)...
                && isscalar(temp_parse{i}) && isnumeric(temp_parse{i})
            fs = double(temp_parse{i});
            fsFlag = true;
            normalizedfreq = false;
            engunits = true;
            tidx = 1;
        elseif isduration(temp_parse{i})
            ts = temp_parse{i};
            tsFlag = true;
            tidx = 1;
        end
    end
    
    m = length(varargin);
    idx = 0;
    %if there are only nv pairs present in varargin
    if mod(m,2)==0 && tidx==0
        idx = 1;
        % if there are both nv pairs & two optional arguments (or) if
        % only optional arguments are present
    elseif mod(m,2)==0 && tidx==1
        idx = 3;
        %if there one optional argument and nv pairs
    elseif mod(m,2)~=0 && tidx==1
        idx = 2;
    else
        coder.internal.assert(~(idx == 0),'Wavelet:FunctionInput:Invalid_ArgNum');
    end
    
    parms = struct('periodlimits',uint32(0),'frequencylimits',uint32(0),...
        'voicesperoctave',uint32(0),'numoctaves',uint32(0),...
        'phasedisplaythreshold',uint32(0),'numscalestosmooth',uint32(0));
    
    popts = struct('CaseSensitivity',false, ...
        'PartialMatching',true);
    
    pStruct = coder.internal.parseParameterInputs(parms,popts,...
        varargin{idx:end});
    
    PLimits = coder.internal.getParameterValue(pStruct.periodlimits,...
        defaultPLimits,varargin{idx:end});
    FLimits = double(coder.internal.getParameterValue(pStruct.frequencylimits,...
        defaultFLimits,varargin{idx:end}));
    numoct = double(coder.internal.getParameterValue(pStruct.numoctaves,...
        defaultnumoct,varargin{idx:end}));
    mincoherence = double(coder.internal.getParameterValue(...
        pStruct.phasedisplaythreshold,defaultmincoherence,...
        varargin{idx:end}));
    nos = double(coder.internal.getParameterValue(pStruct.numscalestosmooth,...
        [],varargin{idx:end}));
    nv = double(coder.internal.getParameterValue(pStruct.voicesperoctave,...
        defaultnv,varargin{idx:end}));
    
    if ~(isequal(PLimits,defaultPLimits))
        PL_flg = true;
    end
    
    % cwtfilterbank limitation
    if (tsFlag && (ts>0) && (isequal(PLimits,defaultPLimits)))
        coder.internal.assert(false,...
            'Wavelet:codegeneration:DurationNotSupported');
    elseif PL_flg
        coder.internal.assert(false,...
            'Wavelet:FunctionArgVal:Invalid_ArgNamVar','PeriodLimits');
    end
    
    if ~(isequal(FLimits,defaultFLimits))
        FL_flg = true;
    end
end
  % Validate input arguments
    FLimits = validateinputs(N,FLimits,PLimits,nv,mincoherence,nos,numoct,...
        fs,ts,tsFlag,fsFlag,PL_flg,FL_flg,errFlag);
end

function FLimits = validateinputs(N,FLimits,PLimits,nv,mincoherence,...
    nos,numoct,Frequency,Period,tsFlag,fsFlag,PL_flg,FL_flg,errFlag)

[defaultPLimits,defaultFLimits,~,maxnumoctaves,~,~,defaultnumoct,...
    ~,~,~] = defaultValues(N);

validateattributes(FLimits,{'double'},{'numel',2,'finite'});

if isempty(coder.target)
    % Error out if both frequency and period limits are specified
    if (FL_flg && PL_flg)
        coder.internal.error('Wavelet:cwt:freqperiodrange');
    end
    
    if ((numel(Period) ~= 1) || Period < 0) && tsFlag && ~fsFlag
        coder.internal.error('Wavelet:FunctionInput:PositiveScalarDuration');
    end
    
    % Error out if frequency limits are specified and a sampling interval
    % is specified
    if  ~isequal(FLimits,defaultFLimits) && tsFlag && ~fsFlag
        coder.internal.error('Wavelet:cwt:freqrangewithts');
    end
    
    % Error out if period limits are not accompanied by a sampling interval
    if ~isequal(PLimits,defaultPLimits) && ~tsFlag && fsFlag
        coder.internal.error('Wavelet:wcoherence:periodwithsampfreq');
    end
    
    % Error out if both frequency and period is specified
    if fsFlag && tsFlag
        coder.internal.error('Wavelet:FunctionInput:SamplingIntervalOrDuration');
    end
end

validateattributes(Frequency,{'numeric'},{'positive'},...
    'wcoherence','Fs');

% Error out if numoctaves is specified with Period or Frequency Limits
if (numoct~=defaultnumoct) && (~isequal(PLimits,defaultPLimits)...
        || ~isequal(FLimits,defaultFLimits))
    coder.internal.error('Wavelet:cwt:numoctavesfreqperiod');
end

if errFlag
    coder.internal.error('Wavelet:FunctionInput:Invalid_ScalNum');
end

validateattributes(nv,{'numeric'},{'positive','integer',...
    'scalar','>=',10,'<=',32},'wcoherence','VoicesPerOctave');
validateattributes(mincoherence,{'numeric'},{'scalar','>=',0,...
    '<=',1},'wcoherence','PhaseDisplayThreshold');
validateattributes(nos,{'numeric'},{'positive','integer'},...
    'wcoherence','NumScalesToSmooth');
validateattributes(numoct,{'numeric'},{'positive','integer',...
    '<=',maxnumoctaves},'wcoherence','NumOctaves');

% If there are no Frequency limits
if ~any(Frequency) && ~tsFlag && isequal(FLimits,defaultFLimits)
    [~,maxfreq] = cwtfreqbounds(N,1,'Wavelet','amor',...
        'VoicesPerOctave',nv);
    minfreq = 2^(-numoct)*maxfreq;
    FLimits = [minfreq maxfreq];
elseif ~tsFlag && any(Frequency) && isequal(FLimits,defaultFLimits)
    [~,maxfreq] = cwtfreqbounds(N,Frequency,'Wavelet','amor',...
        'VoicesPerOctave',nv);
    minfreq = 2^(-numoct)*maxfreq;
    FLimits = [minfreq maxfreq];
end
end

function [defaultPLimits,defaultFLimits,defaultFs,...
    maxnumoctaves,defaultnv,defaultns,defaultnumoct,...
    defaultmincoherence,tsFlag,fsFlag,PL_flg,FL_flg,...
    errFlag] = defaultValues(N)

% Define default values
defaultPLimits = zeros(1,2);
defaultFLimits = zeros(1,2);
defaultFs = 1;
maxnumoctaves = fix(log2(N))-1;
defaultnv = 12;
defaultns = 12;
defaultnumoct = maxnumoctaves;
defaultmincoherence = 0.5;
tsFlag = false;
fsFlag = false;
PL_flg = false;
FL_flg = false;
errFlag = false;

end
%-------------------------------------------------------------------------

function plotcoherenceperiod(wcoh,wcs,period,t,coitmp,nov,mc,plotstring)

minPeriod = min(period);
maxPeriod = max(period);

switch plotstring
    case 'years'
        Yticks = 2.^(round(log2(minPeriod)):round(log2(maxPeriod)));
        logYticks = log2(Yticks(:));
        YtickLabels = num2str(sprintf('%g\n',Yticks));
    case 'days'
        Yticks = 2.^(round(log2(minPeriod)):round(log2(maxPeriod)));
        logYticks = log2(Yticks(:));
        YtickLabels = num2str(sprintf('%g\n',Yticks));
    case 'hours'
        Yticks = 2.^(round(log2(minPeriod)):round(log2(maxPeriod)));
        logYticks = log2(Yticks(:));
        YtickLabels = num2str(sprintf('%g\n',Yticks));
    case 'minutes'
        Yticks = 2.^(round(log2(minPeriod),1):round(log2(maxPeriod),1));
        logYticks = log2(Yticks(:));
        YtickLabels = num2str(sprintf('%g\n',Yticks));
    case 'seconds'
        Yticks = 2.^(round(log2(minPeriod),2):round(log2(maxPeriod),2));
        logYticks = log2(Yticks(:));
        YtickLabels = num2str(sprintf('%g\n',Yticks));
end
%
AX = newplot;
f = ancestor(AX,'figure');
setappdata(AX,'evstruct',[]);
cla(AX,'reset');
imagesc(t,log2(period),wcoh);

AX.CLim = [0 1];
AX.YLim = log2([minPeriod, maxPeriod]);
AX.YTick = logYticks;
AX.YDir = 'normal';
set(AX,'YLim',log2([minPeriod,maxPeriod]), ...
    'layer','top', ...
    'YTick',logYticks, ...
    'YTickLabel',YtickLabels, ...
    'layer','top');
ylabel([getString(message('Wavelet:wcoherence:Period')) ' (' plotstring ') ']);
xlabel([getString(message('Wavelet:wcoherence:Time'))  ' (' plotstring ')']);
title(getString(message('Wavelet:wcoherence:CoherenceTitle')));
hold(AX,'on');
hcol = colorbar;
hcol.Label.String = 'Magnitude-Squared Coherence';

plot(AX,t,log2(coitmp),'w--','linewidth',2);
theta = angle(wcs);
theta(wcoh< mc) = NaN;
if all(isnan(theta))
    return;
end

% Create mesh grid for phase plot
tspace = ceil(size(theta,2)/40);
pspace = round(2^log2(size(theta,1)/nov/2));
tax = t(1:tspace:size(theta,2));
pax = period(1:pspace:size(theta,1));
plotPhaseVectors(AX,theta,tax,pax,tspace,pspace);
hzoom = zoom(f);
cbzoom = @(~,evd)zoomArrows(evd,theta,tax,pax,tspace,pspace);
cbfig = @(hobject,evd)ResizeFig(hobject,evd,theta,tax,pax,tspace,pspace);
evstruct.sclistener = event.listener(f,'SizeChanged',cbfig);
evstruct.ylimlistener = event.proplistener(AX,AX.findprop('YLim'),...
    'PostSet',cbfig);
evstruct.xlimlistener = event.proplistener(AX,AX.findprop('XLim'),...
    'PostSet',cbfig);
setappdata(AX,'evstruct',evstruct);
set(hzoom,'ActionPostCallback',cbzoom);
% Set NextPlot property to 'replace'
f.NextPlot = 'replace';
end
%-------------------------------------------------------------------------

function plotcoherencefreq(wcoh,wcs,FourierFactor,sigmaT,...
    freq,t,nov,mc,normfreqflag)

if normfreqflag
    frequnitstrs = wavelet.internal.wgetfrequnitstrs;
    ylbl = frequnitstrs{1};
    coifactorfreq = 1;
    
elseif ~normfreqflag
    [freq,eng_exp,uf] = engunits(freq,'unicode');
    coifactorfreq = eng_exp;
    ylbl = wavelet.internal.wgetfreqlbl([uf 'Hz']);
    
end
if normfreqflag
    ut = 'Samples';
    dt = 1;
    coifactortime = 1;
else
    [t,eng_exp,ut] = engunits(t,'unicode','time');
    coifactortime = eng_exp;
    dt = mean(diff(t));
end

N = size(wcoh,2);

% We have to recompute the cone of influence for whatever scaling
% is done in time and frequency by engunits
% dt = dt*coifactortime;

FourierFactor = FourierFactor/coifactorfreq;
sigmaT = sigmaT*coifactortime;
coiScalar = FourierFactor/sigmaT;
samples = createCoiIndices(N);
coi = coiScalar*dt*samples;
invcoi = 1./coi;

maxFreq = cast(max(freq),'like',invcoi);
minFreq = cast(min(freq),'like',invcoi);

invcoi = min(invcoi,maxFreq,'includenan');

Yticks = 2.^(round(log2(minFreq)):round(log2(maxFreq)));

AX = newplot;
setappdata(AX,'evstruct',[]);

f = ancestor(AX,'figure');
cla(AX,'reset');
imagesc(t,log2(freq),wcoh);

AX.CLim = [0 1];
AX.YLim = log2([minFreq, maxFreq]);
AX.YTick = log2(Yticks);
AX.YDir = 'normal';
set(AX,'YLim',log2([minFreq, maxFreq]), ...
    'layer','top', ...
    'YTick',log2(Yticks(:)), ...
    'YTickLabel',num2str(sprintf('%g\n',Yticks)), ...
    'layer','top');
ylabel(ylbl)
xlbl = [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
xlabel(xlbl);
title(getString(message('Wavelet:wcoherence:CoherenceTitle')));
hold(AX,'on');
hcol = colorbar;
hcol.Label.String = 'Magnitude-Squared Coherence';
plot(AX,t,log2(invcoi),'w--','linewidth',2);
theta = angle(wcs);
theta(wcoh< mc)= NaN;
if all(isnan(theta))
    return;
end

% Create mesh grid for phase plot
tspace = ceil(size(theta,2)/40);
pspace = round(2^log2(size(theta,1)/nov/2));
tax = t(1:tspace:size(theta,2));
pax = freq(1:pspace:size(theta,1));
plotPhaseVectors(AX,theta,tax,pax,tspace,pspace);
hzoom = zoom(f);
cbzoom = @(~,evd)zoomArrows(evd,theta,tax,pax,tspace,pspace);
cbfig = @(hobject,evd)ResizeFig(hobject,evd,theta,tax,pax,tspace,pspace);
evstruct.sclistener = event.listener(f,'SizeChanged',cbfig);
evstruct.ylimlistener = event.proplistener(AX,AX.findprop('YLim'),...
    'PostSet',cbfig);
evstruct.xlimlistener = event.proplistener(AX,AX.findprop('XLim'),...
    'PostSet',cbfig);
setappdata(AX,'evstruct',evstruct);
set(hzoom,'ActionPostCallback',cbzoom);
% Set NexPlot to replace
f.NextPlot = 'replace';
end
%--------------------------------------------------------------------------

function plotPhaseVectors(axhandle,theta,tax,pax,tspace,pspace)
if ~isempty(findobj(axhandle,'type','patch'))
    delete(findobj(axhandle, 'type', 'patch'));
end

[tgrid,pgrid]=meshgrid(tax,log2(pax));
theta = theta(1:pspace:size(theta,1),1:tspace:size(theta,2));

idx = find(~any(isnan([tgrid(:) pgrid(:) theta(:)]),2));

tgrid = tgrid(idx);
pgrid = pgrid(idx);
theta = theta(idx);

% Determine extent of phase arrows in plot
[dx,dy] = determinearrowextent(axhandle);
%

% Create the arrow patch object for plotting the phase
arrowpatch = [-1 0 0 1 0 0 -1; 0.1 0.1 0.5 0 -0.5 -0.1 -0.1]';

for ii=numel(tgrid):-1:1
    % Multiply each arrow by the rotation matrix for the given theta
    rotarrow = arrowpatch*[cos(theta(ii)) sin(theta(ii));...
        -sin(theta(ii)) cos(theta(ii))];
    patch(tgrid(ii)+rotarrow(:,1)*dx,pgrid(ii)+rotarrow(:,2)*dy,[0 0 0],...
        'edgecolor','none' ,'Parent',axhandle);
end
end
%--------------------------------------------------------------------------

function [dx,dy] = determinearrowextent(axhandle)
% Get the data aspect ratio of the y and x axis
dataaspectratio = get(axhandle,'DataAspectRatio');
axesposition = get(axhandle,'position');
widthheight = axesposition(3:4);
ar = widthheight./dataaspectratio(1:2);

ar(2)=ar(1)/ar(2);
ar(1)=1;

xlim = axhandle.XLim;
dxlim = xlim(2)-xlim(1);

dx=ar(1).*0.02*dxlim;
dy=ar(2).*0.02*dxlim;
end

function ResizeFig(source,evd,theta,tax,pax,tspace,pspace)
if strcmpi(class(evd),'event.PropertyEvent')
    AX = evd.AffectedObject;
elseif strcmpi(class(source),'matlab.ui.Figure')
    AX = gca;
end

plotPhaseVectors(AX,theta,tax,pax,tspace,pspace);
end

function zoomArrows(evd,theta,tax,pax,tspace,pspace)
% resizes arrows in event of zoom

AX = evd.Axes;
plotPhaseVectors(AX,theta,tax,pax,tspace,pspace);
end
%--------------------------------------------------------------------------

function indices = createCoiIndices(N)
if isodd(N)  % is odd
    indices = 1:ceil(N/2);
    indices = [indices, fliplr(indices(1:end-1))];
else % is even
    indices = 1:N/2;
    indices = [indices, fliplr(indices)];
end
end

%--------------------------------------------------------------------------
function prototype = getPrototypeForCastLike(X,Y)
% Outputs a protoype that can be used in:
% cast(variable,'like',prototype)
prototype = X([]) + Y([]);
end