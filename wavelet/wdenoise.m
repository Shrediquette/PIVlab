function [xden,denoisedcfs,origcfs] = wdenoise(x,varargin)
% WDENOISE Wavelet signal denoising
%   XDEN = WDENOISE(X) denoises the data in X using an empirical Bayesian
%   method with a Cauchy prior. The 'sym4' wavelet is used with a posterior
%   median threshold rule. Denoising is down to the minimum of
%   floor(log2(N)) and wmaxlev(N,'sym4') where N is the number of samples
%   in the data. X is a real-valued vector, matrix, or timetable. If X is a
%   matrix, WDENOISE denoises each column of X. If X is a timetable, X must
%   contain real-valued vectors in separate variables, or one real-valued
%   matrix of data. X cannot contain both vectors and matrices or multiple
%   matrices. X is assumed to be uniformly sampled. If X is a timetable and
%   the timestamps are not linearly spaced, WDENOISE issues a warning.
%
%   XDEN is the denoised vector, matrix, or timetable version of X. For a
%   timetable input, XDEN has the same variable names and timestamps as the
%   original timetable.
%
%   XDEN = WDENOISE(X,LEVEL) denoises X down to LEVEL. LEVEL is a positive
%   integer less than or equal to floor(log2(N)) where N is the number of
%   samples in the data. If unspecified, LEVEL defaults to the minimum of
%   floor(log2(N)) and wmaxlev(N,'sym4'). For James-Stein block
%   thresholding, 'BlockJS', there must be floor(log(N)) coefficients at
%   the coarsest resolution level, LEVEL.
%
%   XDEN = WDENOISE(...,'Wavelet',WNAME) uses the orthogonal or
%   biorthogonal wavelet WNAME for denoising. Orthogonal and biorthogonal
%   wavelets are designated as type 1 and type 2 wavelets respectively in
%   the wavelet manager. Valid built-in orthogonal wavelet families begin
%   with 'haar', 'dbN', 'fkN', 'coifN', or 'symN' where N is the number of
%   vanishing moments for all families except 'fk'. For 'fk', N is the
%   number of filter coefficients. Valid biorthogonal wavelet families begin
%   with 'biorNr.Nd' or 'rbioNd.Nr', where Nr and Nd are the number of
%   vanishing moments in the reconstruction (synthesis) and decomposition
%   (analysis) wavelet. Determine valid values for the vanishing moments by
%   using waveinfo with the wavelet family short name. For example, enter
%   waveinfo('db') or waveinfo('bior'). Use wavemngr('type',WNAME) to
%   determine if a wavelet is orthogonal (returns 1) or biorthogonal
%   (returns 2). If unspecified, WNAME defaults to 'sym4'.
%
%   XDEN = WDENOISE(...,'DenoisingMethod',DMETHOD) uses the denoising
%   method DMETHOD to determine the denoising thresholds for the data X.
%   DMETHOD can be one of 'BlockJS','Bayes','FDR','Minimax','SURE', or
%   'UniversalThreshold'. If unspecified, DMETHOD defaults to the empirical
%   Bayesian method, 'Bayes'.
%
%       * For 'FDR', there is an optional argument for the Q-value, which
%       is the proportion of false positives. Q is a real-valued scalar
%       between 0 and 1/2, (0<Q<=1/2). To specify FDR with a Q-value, use a
%       cell array where the second element is the Q-value. For example,
%       'DenoisingMethod',{'FDR',0.01}. If unspecified, Q defaults to 0.05.
%
%   XDEN = WDENOISE(...,'ThresholdRule',THRESHRULE) uses the threshold rule
%   THRESHRULE to shrink the wavelet coefficients. THRESHRULE is valid for
%   all denoising methods but the valid options and defaults depend on the
%   denoising method.
%
%   THRESHRULE valid options for the denoising methods:
%   For 'BlockJS', the only supported option is 'James-Stein'. You do not
%   need to specify THRESHRULE for 'BlockJS'.
%
%   For 'SURE','Minimax', and 'UniversalThreshold', valid options are
%   'Soft' or 'Hard'. The default is 'Soft'.
%
%   For 'Bayes', valid options are 'Median', 'Mean', 'Soft', or
%   'Hard'. The default is 'Median'.
%
%   For 'FDR', the only supported option is 'Hard'. You do not need to
%   specify THRESHRULE for 'FDR'.
%
%   XDEN = WDENOISE(...,'NoiseEstimate',NOISEESTIMATE) estimates the
%   variance of the noise in the data using NOISEESTIMATE. Valid options
%   are 'LevelIndependent' and 'LevelDependent'. If unspecified, the
%   default is 'LevelIndependent'. 'LevelIndependent' estimates the
%   variance of the noise based on the finest-scale (highest-resolution)
%   wavelet coefficients. 'LevelDependent' estimates the variance of the
%   noise based the wavelet coefficients at each resolution level. 
%   Specifying 'NoiseEstimate' with the 'BlockJS' method has no effect.
%   The block James-Stein estimator always uses a 'LevelIndependent' noise
%   estimate. 
%
%   [XDEN,DENOISEDCFS] = WDENOISE(...) returns the denoised wavelet and
%   scaling coefficients in the cell array DENOISEDCFS. The elements of
%   DENOISEDCFS are in order of decreasing resolution. The final element of
%   DENIOSEDCFS contains the approximation (scaling) coefficients.
%
%   [XDEN,DENOISEDCFS,ORIGCFS] = WDENOISE(...) returns the original wavelet
%   and scaling coefficients in the cell array ORIGCFS. The elements of
%   ORIGCFS are in order of decreasing resolution. The final element of
%   ORIGCFS contains the approximation (scaling) coefficients.
%
%   %Example 1
%   % Denoise a noisy frequency-modulated signal using the default Bayesian
%   % method.
%
%   load noisdopp;
%   xden = wdenoise(noisdopp);
%   plot([noisdopp' xden'])
%
%   %Example 2
%   % Denoise a timetable of noisy data down to level 5 using block
%   % thresholding.
%
%   load wnoisydata
%   xden = wdenoise(wnoisydata,5,'DenoisingMethod','BlockJS');
%   hl = plot(wnoisydata.t,[wnoisydata.noisydata(:,1) xden.noisydata(:,1)]);
%   hl(2).LineWidth = 2; legend('Original','Denoised');
%
%   See also WAVEDEC, WDENOISE2.

%   Copyright 2017-2020 The MathWorks, Inc.

%#codegen

% Check number of input arguments
narginchk(1,10);

% Handle both timetable and vector inputs
TTable = false;
if isempty(coder.target)
    if istimetable(x)
        tt = x;
        TTable = true;
        % Check whether the time-table is valid for WDENOISE
        % Get the RowTimes from the timetable
        SampleTimes = tt.Properties.RowTimes;
        % Convert the RowTimes from a duration or datetime array to
        % time vector.
        times = wavelet.internal.convertDuration(SampleTimes);
        % Check the time vector for uniform sampling
        Tunif = wavelet.internal.isuniform(times);
        if ~Tunif
            coder.internal.warning('Wavelet:FunctionInput:NonuniformlySampled');
        end
        % validate that the times are increasing
        validateattributes(times,{'double'},{'increasing'},'WDENOISE','RowTimes');
        % Extract valid numeric data from time table
        % Return VariableNames as cell array
        [x,VariableNames] = wavelet.internal.CheckAndExtractTT(tt);
    end
end

% Validate the data
validateattributes(x,{'double'},{'real','nonempty','finite','2d'},'WDENOISE','X');
IsRow = isrow(x);

% Work on column vectors -- return orientation to row on output if needed
if isvector(x) && IsRow
    temp_x = double(x(:));
else
    temp_x = double(x);
end

N = size(temp_x,1);
if N < 2
    coder.internal.error('Wavelet:modwt:LenTwo');
end

% Check if GPU is enabled. As "level" is converted to compile-time constant
% if not passed by the user, and will be taken as it is if passed by the
% user as one of the input arguments. "level" doesn't remain compile-time
% constant after passing it to "parseinputs" function even if user passed it as
% compile-time constant. This condition checks if user passed "level" and
% will not call "parseinputs" function for "level".
if coder.gpu.internal.isGpuEnabled
    if ~isempty(varargin) && isscalar(varargin{1})
        [~,qvalue,~,DenoisingMethod,ThresholdRule,...
            NoiseEstimate,Lo_D,Hi_D,Lo_R,Hi_R] = parseinputs(N,varargin{:});
        level = varargin{1};
    else
        [level,qvalue,~,DenoisingMethod,ThresholdRule,...
            NoiseEstimate,Lo_D,Hi_D,Lo_R,Hi_R] = parseinputs(N,varargin{:});
    end
else
[level,qvalue,~,DenoisingMethod,ThresholdRule,...
            NoiseEstimate,Lo_D,Hi_D,Lo_R,Hi_R] = parseinputs(N,varargin{:});
end

% The following denoising methods are handled by wden()
% Select denoising method
if strcmpi(DenoisingMethod,'UniversalThreshold') || ...
        strcmpi(DenoisingMethod,'SURE') || ...
        strcmpi(DenoisingMethod,'Minimax')
    % Denoising for any one of universal threshold, minimax estimation
    % and stein's unbiased risk estimation(SURE) methods
    [DenoisingMethod_cal, ThresholdRule_cal] = ...
        DJInputs(DenoisingMethod,ThresholdRule);
    
    % Check if GPU is enabled.
    if coder.gpu.internal.isGpuEnabled
        % If "level" is not passed as one of the input arguments.
        if (isempty(varargin)) || (~isempty(varargin) && ~isscalar(varargin{1}))
            % If the input signal is fixed size input.
            if coder.internal.isConst(size(temp_x))
                % Converting "level" to compile-time constant for optimized
                % GPU Code generation.
                coder.internal.const(level);
            else
                % Displaying a warning if input signal is a varDim. 
                coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseVarDimInputs');
            end
        % If "level" is passed as one of the input arguments.
        else
            % Displaying a warning if "level" passed as one of the input arguments is not
            % compile-time constant. 
            if ~coder.internal.isConst(level)
                coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseNonConstantLevelValue');
                % Displaying a warning if input signal is a varDim. 
                if ~coder.internal.isConst(size(temp_x))
                    coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseVarDimInputs');
                end
            end
        end
        
        % GPU specific implementation of DonohoJohnstone denoising algorithm.
        [txden,denoisedcfs,origcfs] = ...
            wavelet.internal.gpu.donohoJohnstone(temp_x,level,Lo_D,Hi_D,Lo_R,Hi_R,...
            DenoisingMethod_cal,ThresholdRule_cal,NoiseEstimate);
    else
        [txden,denoisedcfs,origcfs] = ...
            wavelet.internal.DonohoJohnstone(temp_x,level,Lo_D,Hi_D,Lo_R,Hi_R,...
            DenoisingMethod_cal,ThresholdRule_cal,NoiseEstimate);
    end
    
elseif strcmpi(DenoisingMethod,'fdr')
    % Displaying a warning if GPU is enabled for FDR denoising method.
    if coder.gpu.internal.isGpuEnabled
        % Check if DenoisingMethod passed is compile-time constant.
        if coder.internal.isConst(DenoisingMethod)
            % Displaying a compile-time warning if DenoisingMethod is
            % passed as compile-time constant.
            coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseUnsupportedMethods');
        end
    end
             
    % Denoising for false discovery rate(FDR)
    [txden,denoisedcfs,origcfs] = ...
        wavelet.internal.FDRDenoise(...
            temp_x,Lo_D,Hi_D,Lo_R,Hi_R,level,qvalue,NoiseEstimate);
    
elseif strcmpi(DenoisingMethod,'Bayes')
    % Check if GPU is enabled.
    if coder.gpu.internal.isGpuEnabled
        % If "level" is not passed as one of the input arguments.
        if (isempty(varargin)) || (~isempty(varargin) && ~isscalar(varargin{1}))
            % If the input signal is fixed size input.
            if coder.internal.isConst(size(temp_x))
                % Converting "level" to compile-time constant for optimized
                % GPU Code generation.
                coder.internal.const(level);
            else
                % Displaying a warning if input signal is a varDim. 
                coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseVarDimInputs');
            end
        % If "level" is passed as one of the input arguments.
        else
            % Displaying a warning if "level" passed as one of the input arguments is not
            % compile-time constant. 
            if ~coder.internal.isConst(level)
                coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseNonConstantLevelValue');
                % Displaying a warning if input signal is a varDim. 
                if ~coder.internal.isConst(size(temp_x))
                    coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseVarDimInputs');
                end
            end
        end
        
        % GPU specific implementation of Bayes denoising algorithm.
        [txden,denoisedcfs,origcfs] = ...
            wavelet.internal.gpu.ebayesdenoise(temp_x,Lo_D,Hi_D,Lo_R,Hi_R,level,NoiseEstimate,ThresholdRule);
    else
        % Denoising with empirical Bayes
        [txden,denoisedcfs,origcfs] = ...
            wavelet.internal.ebayesdenoise(...
                temp_x,Lo_D,Hi_D,Lo_R,Hi_R,level,NoiseEstimate,ThresholdRule);
    end
else
    % lambda is solution of equation
    % \lambda \ln{(3)} - 3 = 0
    % See section 6 for the derivation of the values for \lambda and L
    %
    % Cai, T.T. (1999) Adaptive wavelet estimation: A block thresholding and
    % oracle inequality approach. The Annals of Statistics, 27(3), 898-924.
    
    % Displaying a warning if GPU is enabled for BlockJS denoising method.
    if coder.gpu.internal.isGpuEnabled
        % Check if DenoisingMethod passed is compile-time constant.
        if coder.internal.isConst(DenoisingMethod)
            % Displaying a compile-time warning if DenoisingMethod is
            % passed as compile-time constant.
            coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseUnsupportedMethods');
        end
    end
    
    lambda = 4.50524;
    L = max(floor(log(size(temp_x,1))),1);
    % Denoising by block JS
    [txden,denoisedcfs,origcfs] = ...
        wavelet.internal.blockthreshold(...
            temp_x,Lo_D,Hi_D,Lo_R,Hi_R,level,lambda,L);
end


% Return row vector if input is row vector
if IsRow
    xden = txden.';
else
    xden = txden;
end

if TTable && isempty(coder.target)
    % Create timetable output
    xden = wavelet.internal.createTimeTable(SampleTimes,xden,VariableNames);
end
end

%-------------------------------------------------------------------------
function [Level,Q,Wavelet,DenoisingMethod,ThresholdRule,...
    NoiseEstimate,LO_D,HI_D,LO_R,HI_R,wavtype] = parseinputs(N,varargin)

coder.extrinsic('wfilters','wavemngr');

% Default parameter values.
defaultWavelet = 'sym4';
defaultDenoisingMethod = 'Bayes';
defaultThresholdRule = 'Median';
defaultLevel = wavelet.internal.dwtmaxlev(N,8);
if defaultLevel == 0
    defaultLevel = floor(log2(N));
elseif defaultLevel > 0
    defaultLevel = min(defaultLevel,floor(log2(N)));
end
maxlev = floor(log2(N));
defaultQ = [];
defaultNoiseEstimate = 'LevelIndependent';

if isempty(varargin)
    Wavelet = defaultWavelet;
    DenoisingMethod = defaultDenoisingMethod;
    NoiseEstimate = defaultNoiseEstimate;
    if isempty(coder.target)
        [LO_D,HI_D,LO_R,HI_R] = wfilters("sym4");
    else
        [LO_D,HI_D,LO_R,HI_R] = coder.const(@wfilters, "sym4");
    end
    Level = defaultLevel;
    ThresholdRule = defaultThresholdRule;
    Q = defaultQ;
else
    temp = nargin - 1;
    % See if a level is specified
    if isempty(coder.target)
        temp_parseinputs = varargin;
        levelidx = cellfun(@(x) isscalar(x) && ~ischar(x) && ~isstring(x),varargin);
    else
        temp_parseinputs = cell(1,temp);
        levelidx = zeros(1,temp,'logical');
        for i = 1:temp
            temp_parseinputs{i} = varargin{i};
            levelidx(i) = (isscalar(temp_parseinputs{i}) && ~ischar(temp_parseinputs{i})...
                && ~isstring(temp_parseinputs{i}))*i;
        end
    end
    % Defining Level
    Level = defaultLevel;
    if any(levelidx) && nnz(levelidx)==1
        Level = temp_parseinputs{levelidx};
        validateattributes(Level,{'numeric'},...
            {'integer','scalar','<=',maxlev,'>=',1},'WDENOISE','LEVEL');
        temp = temp - 1;
    elseif nnz(levelidx) > 1
        coder.internal.error('Wavelet:FunctionInput:Invalid_LevelInput');
    end
    
    % Final input definition
    if isempty(levelidx(levelidx))
        tempidx = 1:nargin - 1;
    else
        xtempidx = 1:nargin - 1;
        tempidx = xtempidx(~levelidx);
    end
    
    if isempty(coder.target)
        temp_finalParse = {temp_parseinputs{tempidx}};
    else
        temp_finalParse = cell(1,temp);
        idx = 1;
        for j = tempidx
            temp_finalParse{idx} = temp_parseinputs{j};
            idx = idx +1;
        end
    end
    
    %%% Parsing input arguments.
    if isempty(coder.target)
        p = inputParser;
        p.addParameter("Wavelet",defaultWavelet);
        p.addParameter("DenoisingMethod",defaultDenoisingMethod);
        p.addParameter("NoiseEstimate",defaultNoiseEstimate);
        p.addParameter("ThresholdRule",char([]));
        p.parse(temp_finalParse{1:end});
        
        Wavelet = p.Results.Wavelet;
        temp_DenoisingMethod = p.Results.DenoisingMethod;
        ThresholdRule = deblank(p.Results.ThresholdRule);
        NoiseEstimate = p.Results.NoiseEstimate;
    else
        parms = struct('Wavelet',uint32(0), 'DenoisingMethod',uint32(0),...
            'NoiseEstimate',uint32(0), 'ThresholdRule',uint32(0));
        
        parmsstruct = eml_parse_parameter_inputs(parms,[],temp_finalParse{:});
        coder.varsize('ThresholdRule');
        Wavelet = eml_get_parameter_value(parmsstruct.Wavelet,...
            defaultWavelet,temp_finalParse{:});
        temp_DenoisingMethod = eml_get_parameter_value(parmsstruct.DenoisingMethod,...
            defaultDenoisingMethod,temp_finalParse{:});
        ThresholdRule = eml_get_parameter_value(parmsstruct.ThresholdRule,...
            char([]),temp_finalParse{:});
        NoiseEstimate = eml_get_parameter_value(parmsstruct.NoiseEstimate,...
            defaultNoiseEstimate,temp_finalParse{:});
    end
    
    if isempty(coder.target)
        % Check for Wave type
        wavtype = wavemngr('type',Wavelet);
        % Check for Level
        [LO_D,HI_D,LO_R,HI_R] = wfilters(Wavelet);
    else
        wavtype = coder.const(@wavemngr,'type',Wavelet);
        [LO_D,HI_D,LO_R,HI_R] = coder.const(@wfilters, Wavelet);
    end
    
    coder.internal.errorIf(~(wavtype == 1 || wavtype == 2),...
        'Wavelet:FunctionInput:OrthorBiorthWavelet');
        
    % Check for DenoisingMethod
    % Only for FDR is a cell array input support
    if iscell(temp_DenoisingMethod)
        Q = temp_DenoisingMethod{2};
        validateattributes(Q,{'numeric'},{'scalar','nonempty','>',0,'<=',1/2},...
            'WDENOISE','Q');
        DenoisingMethod = temp_DenoisingMethod{1};
        validatestring(DenoisingMethod, {'FDR'},...
            'WDENOISE','DENOISINGMETHOD');
    else
        DenoisingMethod = validatestring(temp_DenoisingMethod,...
            {'SURE','Bayes', 'UniversalThreshold','FDR','Minimax',...
            'BlockJS'},'WDENOISE','DENOISINGMETHOD');
        Q = defaultQ;
    end
    
    % Check for ThresholdRule
    if ~isempty(ThresholdRule) && ~any(strcmpi(DenoisingMethod,{'Bayes',...
            'FDR','BlockJS'}))
        ThresholdRule = validatestring(ThresholdRule,{'soft','hard'}, ...
            'WDENOISE', 'THRESHRULE');
    elseif ~isempty(ThresholdRule) && strcmpi(DenoisingMethod,'FDR')
        ThresholdRule = validatestring(ThresholdRule, {'hard'}, ...
            'WDENOISE', 'THRESHRULE');
    elseif ~isempty(ThresholdRule) && strcmpi(DenoisingMethod,'blockJS')
        ThresholdRule = validatestring(ThresholdRule,{'James-Stein'}, ...
            'WDENOISE', 'THRESHRULE');
    elseif ~isempty(ThresholdRule) && strcmpi(DenoisingMethod,'Bayes')
        ThresholdRule = validatestring(ThresholdRule,{'median','mean',...
            'soft','hard'}, 'WDENOISE', 'THRESHRULE');
    elseif isempty(ThresholdRule) && strcmpi(DenoisingMethod,'FDR')
        ThresholdRule = 'hard';
    elseif isempty(ThresholdRule) && any(strcmpi(DenoisingMethod,{'SURE',...
            'UniversalThreshold','Minimax'}))
        ThresholdRule = 'Soft';
    elseif isempty(ThresholdRule) && strcmpi(DenoisingMethod,'Bayes')
        ThresholdRule = 'median';
    elseif isempty(ThresholdRule) && strcmpi(DenoisingMethod,'blockJS')
        ThresholdRule = 'James-Stein';
    end
    
    % Check for Noise Estimate.
    validatestring(NoiseEstimate,...
        {'LevelIndependent','LevelDependent'},'WDENOISE2','NOISEESTIMATE');
end
end

%------------------------------------------------------------------------
function [DenoisingMethod_cal, ThresholdRule_cal] = ...
    DJInputs(DenoisingMethod,ThresholdRule)

if strcmpi(DenoisingMethod,'sure')
    DenoisingMethod_cal = 'rigrsure';
elseif strcmpi(DenoisingMethod, 'universalthreshold')
    DenoisingMethod_cal = 'sqtwolog';
else
    DenoisingMethod_cal = 'minimaxi';
end

if strcmpi(ThresholdRule, 'soft')
    ThresholdRule_cal = 's';
else
    ThresholdRule_cal = 'h';
end

end





