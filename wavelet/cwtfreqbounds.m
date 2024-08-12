function varargout = cwtfreqbounds(N, varargin)
%CWTFREQBOUNDS CWT Minimum and Maximum Frequency or Period
%   [MINFREQ,MAXFREQ] = CWTFREQBOUNDS(N) returns the minimum and maximum
%   wavelet bandpass frequencies in cycles/sample for a signal of length N.
%   The minimum and maximum frequencies are determined for the default
%   Morse (3,60) wavelet. The minimum frequency is determined so that two
%   time standard deviations of the default wavelet span the N-point
%   signal at the coarsest scale. The maximum frequency is such that the
%   highest frequency wavelet bandpass filter drops to 1/2 of its peak
%   magnitude at the Nyquist.
%
%   [MINFREQ,MAXFREQ] = CWTFREQBOUNDS(N,Fs) returns the bandpass
%   frequencies in hertz for the sampling frequency Fs. Fs is a positive
%   scalar.
%
%   [MAXPERIOD,MINPERIOD] = CWTFREQBOUNDS(...,Ts) returns the wavelet
%   bandpass periods for the sampling period Ts. Ts is a positive scalar
%   <a href="matlab:help duration">duration</a>.
%   MAXPERIOD and MINPERIOD are scalar durations with the same format as Ts.
%   If the number of standard deviations is set so that
%   log2(MAXPERIOD/MINPERIOD) < 1/NV, MAXPERIOD is adjusted to MINPERIOD*2^(1/NV).
%
%   [MINFREQ,MAXFREQ] = CWTFREQBOUNDS(...,'Wavelet',WNAME) determines the
%   bandpass frequencies for the wavelet WNAME. Valid options for WNAME are
%   'Morse', 'amor', or 'bump'. For Morse wavelets, you can also
%   parameterize the wavelet using the 'TimeBandwidth' or
%   'WaveletParameters' name-value pairs.
%
%   [MINFREQ,MAXFREQ] = CWTFREQBOUNDS(...,'Cutoff',CO) specifies the
%   percentage of the peak magnitude for the wavelet filter with the 
%   highest center frequency at the Nyquist. CO is a value between
%   0 and 100. A CO value of 0 indicates that the response of the 
%   wavelet filter with the highest center frequency decays to 0 at the 
%   Nyquist. A CO value of 100 indicates that the value of the 
%   highest-frequency wavelet bandpass filter peaks at the Nyquist. For 
%   CWTFILTERBANK, the analytic wavelets filters peak at a value of 2.
%   As a result, you can ensure the highest frequency wavelet decays to a
%   value of alpha at the Nyquist frequency by setting Cutoff = 100*alpha/2. 
%   In that case, you must have 0<= alpha <= 2. If unspecified, CO defaults
%   to 50 for the Morse wavelets and 10 for the 'amor' and 'bump' wavelets.
%
%   [MINFREQ,MAXFREQ] = CWTFREQBOUNDS(...,'StandardDeviations',NUMSD) uses
%   NUMSD time standard deviations to determine the minimum frequency
%   (longest scale). NUMSD is a positive integer greater than or equal to
%   2. For the Morse, analytic Morlet, and bump wavelets, four standard
%   deviations generally ensures that the wavelet decays to zero at the
%   ends of the signal support. Incrementing 'StandardDeviations' by
%   multiples of 4, for example 4*M, ensures that M whole wavelets fit
%   within the signal length. If unspecified, 'StandardDeviations' defaults
%   to 2. If the number of standard deviations is set so that
%   log2(MINFREQ/MAXFREQ) > -1/NV where NV is the number of voices per
%   octave, MINFREQ is adjusted to MAXFREQ*2^(-1/NV).
%
%   [MINFREQ,MAXFREQ] = CWTFREQBOUNDS(...,'TimeBandwidth',TB) returns the
%   bandpass frequencies for the Morse wavelet characterized by the
%   time-bandwidth parameter, TB. TB is a positive number greater than or
%   equal to 3 and less than or equal to 120. The larger the time-bandwidth
%   parameter, the more spread out the wavelet is in time and narrower the
%   wavelet bandpass filter is in frequency. If unspecified, TB defaults to 
%   60. You cannot specify both the 'TimeBandwidth' and 'WaveletParameters'
%   name-value pairs.
%
%   [MINFREQ,MAXFREQ] = CWTFREQBOUNDS(...,'WaveletParameters',PARAM) uses
%   the parameters PARAM to specify the Morse wavelet. PARAM is a
%   two-element vector, which defaults to [3,60]. The first element is the
%   symmetry parameter (gamma), which must be greater than or equal to 1.
%   The second element is the time-bandwidth parameter, which must be 
%   greater than or equal to gamma. The ratio of the time-bandwidth 
%   parameter to gamma cannot exceed 40. When gamma is equal to 3, the 
%   Morse wavelet is perfectly symmetric in the frequency domain. The
%   skewness is equal to 0. Values of gamma greater than 3 result in 
%   positive skewness, while values of gamma less than 3 result in negative 
%   skewness. WaveletParameters is only valid if the Wavelet property is 
%   'Morse'. The WaveletParameters and TimeBandwidth properties cannot both 
%   be specified.
%
%   [...] = CWTFREQBOUNDS(...,'VoicesPerOctave',NV) uses NV voices per
%   octave in determining the necessary separation between the maximum and
%   minimum scales. The maximum and minimum scales are equivalent to the
%   minimum and maximum frequencies or maximum and minimum periods
%   respectively. NV is an integer between 1 and 48. The default value of 
%   NV is 10.
%
%   %Example: Obtain the minimum and maximum frequencies for the default
%   %   Morse wavelet for a signal of length 10,000 and a sampling
%   %   frequency of 1 kHz. Use a cutoff of 100 percent so that the highest
%   %   frequency wavelet bandpass filter peaks at the Nyquist. Construct
%   %   the filter bank using the values returned by CWTFREQBOUNDS and plot
%   %   the frequency responses.
%
%   [minfreq,maxfreq] = cwtfreqbounds(1e4,1000,cutoff=100);
%   fb = cwtfilterbank(SignalLength=1e4,SamplingFrequency=1000,...
%   FrequencyLimits=[minfreq maxfreq]);
%   freqz(fb)
%
%   %Example: Obtain the minimum and maximum frequencies for the bump
%   %   wavelet for a signal of length 5,000 and a sampling
%   %   frequency of 10 kHz. Use a cutoff of 100*1e-8/2 percent so that the 
%   %   highest frequency wavelet bandpass filter decays to 1e-8 at the 
%   %   Nyquist. Construct the filter bank using the values returned by 
%   %   CWTFREQBOUNDS and plot the frequency responses.
%   [minfreq,maxfreq] = cwtfreqbounds(5e3,1e4,cutoff=100*1e-8/2);
%   fb = cwtfilterbank(Wavelet="bump",SignalLength=5e3,SamplingFrequency=1e4,...
%       FrequencyLimits=[minfreq maxfreq]);
%   freqz(fb)
%
% See also CWT, CWTFILTERBANK, ICWT

%   Copyright 2017-2021 The MathWorks, Inc.
%#codegen

% Check number of input and output arguments
narginchk(1,12);
nargoutchk(0,2);
coder.internal.prefer_const(varargin);
validateattributes(N,{'numeric'},{'integer','scalar','positive','>=',4}, ...
    'cwtfreqbounds', 'N');

[params,wname] = parseinputs(varargin{:});

[minfreq,maxperiod,~,~,maxfreq,minperiod] = ...
    wavelet.internal.cwt.cwtfreqlimits(...
    wname, N, params.cutoff, params.ga, params.be, ...
    params.SampleTimeOrFrequency, params.numsd, params.nv);

if coder.target('MATLAB')
    if isduration(params.SampleTimeOrFrequency)
        varargout{1} = maxperiod;
        varargout{2} = minperiod;
    else
        varargout{1} = minfreq;
        varargout{2} = maxfreq;
    end
else
    varargout{1} = minfreq;
    varargout{2} = maxfreq;    
end

%--------------------------------------------------------------------------
function [params, wname] = parseinputs(varargin)

coder.internal.prefer_const(varargin);

defaultWAV = 'morse';
params = struct(...
    'TB',NaN, ...
    'WP',[NaN NaN], ...
    'nv',10, ...
    'numsd',2,...
    'cutoff',Inf,...
    'ga',3,...
    'be',20,...
    'SampleTimeOrFrequency',1);

coder.internal.prefer_const(params);

ivarargin = coder.internal.indexInt(1);
isTs = false;
isFs = false;

if ~isempty(varargin)
    if coder.target('MATLAB')
        isTs = isduration(varargin{1});
    end
    if isnumeric(varargin{1})
        isFs = true;
    end
end

if isFs && ~isempty(varargin)
    params.SampleTimeOrFrequency = varargin{1};
    validateattributes(params.SampleTimeOrFrequency,{'numeric'},...
        {'positive','scalar','nonempty','finite'},'cwtfreqbounds','Fs');
    ivarargin = coder.internal.indexInt(2);
elseif isTs && coder.target('MATLAB') && ~isempty(varargin)
    params.SampleTimeOrFrequency = varargin{1};
    validateattributes(params.SampleTimeOrFrequency,...
        {'duration'},{'scalar','nonempty'},...
        'cwtfreqbounds','Ts');
    ivarargin = coder.internal.indexInt(2);
end

if coder.target('MATLAB')
    p = inputParser;
    addParameter(p,'Wavelet',defaultWAV);
    addParameter(p,'TimeBandwidth',[]);
    addParameter(p,'WaveletParameters',[]);
    addParameter(p,'Cutoff',[]);
    addParameter(p,'StandardDeviations',params.numsd);
    addParameter(p,'VoicesPerOctave',params.nv);
    parse(p,varargin{ivarargin:end});
    wname = p.Results.Wavelet;
    params.TB = p.Results.TimeBandwidth;
    params.WP = p.Results.WaveletParameters;
    params.cutoff = p.Results.Cutoff;
    params.numsd = p.Results.StandardDeviations;
    params.nv = p.Results.VoicesPerOctave;
    [params,wname] = validateInputsMATLAB(params, wname);
else
    
    parms = struct('Wavelet',uint32(0), ...
        'TimeBandwidth',uint32(0), ...
        'WaveletParameters',uint32(0), ...
        'Cutoff',uint32(0), ...
        'StandardDeviations',uint32(0),...
        'VoicesPerOctave',uint32(0));
    popts = struct('CaseSensitivity',false,...
        'PartialMatching','unique');

    pstruct = coder.internal.parseParameterInputs(...
        parms, popts, varargin{ivarargin:end});

    wname = coder.internal.getParameterValue(...
        pstruct.Wavelet, defaultWAV, varargin{ivarargin:end});

    params.TB = coder.internal.getParameterValue(...
        pstruct.TimeBandwidth, params.TB, varargin{ivarargin:end});

    params.WP = coder.internal.getParameterValue(...
        pstruct.WaveletParameters, params.WP, varargin{ivarargin:end});

    params.cutoff = coder.internal.getParameterValue(...
        pstruct.Cutoff, params.cutoff, varargin{ivarargin:end});

    params.numsd = coder.internal.getParameterValue(...
        pstruct.StandardDeviations, params.numsd, varargin{ivarargin:end});

    params.nv = coder.internal.getParameterValue(...
        pstruct.VoicesPerOctave, params.nv, varargin{ivarargin:end});

    [params, wname] = validateInputsCODEGEN(params, wname);
end

%--------------------------------------------------------------------------
function [params, wname] = validateInputsMATLAB(params, wname)
validwavelets = {'morse','amor','bump'};
wname = validatestring(wname,validwavelets, ...
    'cwtfreqbounds', 'Wavelet');

if (~isempty(params.WP) || ~isempty(params.TB))...
        && ~strcmpi(wname,'morse')
    error(message('Wavelet:cwt:InvalidParamsWavelet'));
end

if ~isempty(params.TB) && isempty(params.WP)
    
    validateattributes(params.TB,{'numeric'},{'scalar',...
        '>=',params.ga},'cwtfreqbounds','TimeBandwidth');
    params.be = params.TB/params.ga;
    
elseif (isempty(params.TB) && ~isempty(params.WP))
    params.ga = params.WP(1);
    validateattributes(params.ga,{'numeric'},{'scalar',...
        'positive','>=',1},'cwtfreqbounds','gamma');
    % beta must be greater than 1
    validateattributes(params.WP(2),{'numeric'},...
        {'scalar','>=',params.ga},'cwtfreqbounds','TimeBandwidth');
    params.be = params.WP(2)/params.ga;
    if params.be>40
        error(message('Wavelet:cwt:TBupperbound'));
    end
elseif ~isempty(params.TB) && ...
        ~isempty(params.WP)
    error(message('Wavelet:cwt:paramsTB'));

end

if isempty(params.cutoff) && strcmpi(wname,'morse')
    params.cutoff = 50;
elseif isempty(params.cutoff) && ~strcmpi(wname,'morse')
        params.cutoff = 10;
else
    validateattributes(params.cutoff,{'numeric'},{'scalar','>=',0,'<=',100},...
        'cwtfreqbounds','CutOff');
end

validateattributes(params.nv,{'numeric'},{'integer','scalar','>=',1,...
    '<=',48},'cwtfreqbounds','voicesperoctave');

validateattributes(params.numsd,{'numeric'},{'>=',2}, ...
    'cwtfreqbounds', 'StandardDeviations');

function [params,wname] = validateInputsCODEGEN(params,wname)

coder.internal.prefer_const(params);
coder.internal.prefer_const(wname);

wname = validatestring(wname,...
    {'morse','amor','bump'},'cwtfreqbounds','wavelet');

    
checkwavparams = @(x) isnumeric(x) && numel(x)==2 && ...
                x(1) >= 1 && x(2)>x(1) && x(2)/x(1) <= 40;

waveParamsDefined = ~(isnan(params.WP(1)) && isnan(params.WP(2)));
timeBandwidthDefined = ~isnan(params.TB);


settingInvalidMorseParms = ...
    (waveParamsDefined || timeBandwidthDefined) && ...
    ~strcmpi(wname,'morse');
coder.internal.errorIf(settingInvalidMorseParms, ...
    'Wavelet:cwt:InvalidParamsWavelet');

coder.internal.errorIf(timeBandwidthDefined && waveParamsDefined, ...
    'Wavelet:cwt:paramsTB');

if timeBandwidthDefined
    validateattributes(params.TB,{'numeric'}, ...
        {'>=',3, '<=',120},'cwtfilterbank','TimeBandwidth');
    params.be = params.TB/params.ga;
elseif waveParamsDefined
    checkWP = checkwavparams(params.WP);
    coder.internal.errorIf(~checkWP,'Wavelet:codegeneration:WavParams');
    params.ga = params.WP(1);
    params.be = params.WP(2)/params.ga;
end

if isinf(params.cutoff) && strcmpi(wname,'morse')
        params.cutoff = 50;
elseif isinf(params.cutoff) && ~strcmpi(wname,'morse')
        params.cutoff = 10;
else
    validateattributes(params.cutoff,{'numeric'},{'scalar','>=',0,'<=',100},...
        'cwtfreqbounds','CutOff');
end

validateattributes(params.nv,{'double'},{'integer','scalar','>=',1,...
    '<=',48},'cwtfreqbounds','voicesperoctave');

validateattributes(params.numsd,{'numeric'},{'>=',2}, ...
    'cwtfreqbounds', 'StandardDeviations');











