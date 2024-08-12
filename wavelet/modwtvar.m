function varargout = modwtvar(w,varargin)
%MODWTVAR Maximal overlap discrete wavelet transform multiscale variance.
%   WVAR = MODWTVAR(W) returns unbiased estimates of the wavelet variance
%   by scale for the maximal overlap discrete wavelet transform (MODWT) in
%   the LEV+1-by-N matrix W where LEV is the level of the input MODWT. For
%   unbiased estimates, MODWTVAR returns variance estimates only where
%   there are nonboundary coefficients. This condition is satisfied when
%   the transform level is not greater than floor(log2(N/(L-1)+1)) where N
%   is the length of the input and L is the wavelet filter length. If there
%   are sufficient nonboundary coefficients at the final level, MODWTVAR
%   returns the scaling variance in the final element of WVAR. By default,
%   MODWTVAR uses the 'sym4' wavelet to determine the boundary
%   coefficients.
%
%   WVAR = MODWTVAR(W,WAV) uses the wavelet WAV to determine the number of
%   boundary coefficients by level for unbiased estimates. WAV can be a
%   string corresponding to a valid wavelet or a positive even scalar
%   indicating the length of the wavelet and scaling filters. The wavelet
%   filter length must match the length used in the MODWT of the input. If
%   WAV is specified as empty, the default 'sym4' wavelet is used.
%
%   [WVAR,WVARCI] = MODWTVAR(...) returns 95% confidence intervals for the
%   variance estimates by scale. WVARCI is an M-by-2 matrix. The first
%   column of WVARCI contains the lower 95% confidence bound. The second
%   column of WVARCI contains the upper 95% confidence bound. By default,
%   MODWTVAR calculates the interval estimate using the chi-square
%   probability density with the equivalent degrees of freedom estimated
%   using the 'Chi2Eta3' confidence method.
%
%   [...] = MODWTVAR(W,WAV,ConfLevel) uses ConfLevel for the coverage
%   probability of the confidence interval. ConfLevel is a real scalar
%   strictly greater than 0 and less than 1, (0,1). If ConfLevel is
%   unspecified, or specified as empty, the coverage probability defaults
%   to 0.95.
%
%   [...] = MODWTVAR(...,'EstimatorType',EstimatorType) uses EstimatorType
%   to compute variance estimates and confidence bounds. EstimatorType may
%   be one of 'unbiased' or 'biased'. If unspecified, EstimatorType
%   defaults to 'unbiased'. The unbiased estimate identifies and removes
%   boundary coefficients prior to computing the variance estimates and
%   confidence bounds. The 'biased' estimate uses all coefficients to
%   compute the variance estimates and confidence bounds. Unbiased
%   estimates are preferred. You must specify WAV and ConfLevel or specify
%   those inputs as empty, [], for the defaults before using the name-value
%   pair EstimatorType: modwtvar(W,[],[],'EstimatorType','biased').
%
%   [...] = MODWTVAR(...,'ConfidenceMethod',ConfidenceMethod) uses
%   ConfidenceMethod to compute the confidence intervals. ConfidenceMethod
%   may be one of 'Chi2Eta3', 'Chi2Eta1', or 'Gaussian'. The default is
%   'Chi2Eta3'. 'Gaussian' may result in a lower bound that is negative.
%   You must specify WAV and ConfLevel or specify those inputs as empty,
%   [], for the defaults before using the name-value pair ConfidenceMethod.
%   For example, modwtvar(W,[],[],'ConfidenceMethod','Gaussian').
%
%   WVAR = MODWTVAR(...,'Boundary',Boundary) uses the specified boundary to
%   compute the variance estimates and confidence bounds. Boundary may be
%   one of 'periodic' or 'reflection'. If unspecified, Boundary defaults to
%   'periodic'. If the MODWT was acquired using 'reflection' boundary
%   handling, you must specify the Boundary as 'reflection' in MODWTVAR to
%   obtain a correct unbiased estimate. If you are using biased estimators,
%   all the coefficients are used in forming the variance estimates and
%   confidence intervals regardless of the boundary handling. You must
%   specify WAV and ConfLevel or specify those inputs as empty, [], for the
%   defaults before using the name-value pair Boundary. For example,
%   modwtvar(W,[],[],'Boundary','reflection').
%
%   [WVAR,WVARCI,NJ] = MODWTVAR(...) returns the number of coefficients
%   used in forming the variance and confidence intervals by level. For
%   unbiased estimates, NJ represents the number of nonboundary
%   coefficients and decreases by level. For biased estimates, NJ is a
%   vector of constants equal to the number of columns in the input matrix.
%
%   WVAR = MODWTVAR(...,'table') outputs a MATLAB table with the following
%   variables:
%       NJ          The number of MODWT coefficients by level. For unbiased
%                   estimates, NJ represents the number of nonboundary
%                   coefficients. For biased estimates, NJ is the number of
%                   coefficients in the MODWT.
%       Lower       The lower confidence bound for the variance estimate.
%       Variance    The variance estimate by level.
%       Upper       The upper confidence bound for the variance estimate.
%
%   You can specify the 'table' option anywhere after the input MODWT, W as
%   long as you do not split up a name-value pair. If you specify 'table',
%   MODWTVAR only outputs one argument.
%
%   The row names of the table WVAR designate the type and level of each
%   estimate. For example, D1 designates that the row corresponds to a
%   wavelet or detail estimate at level 1 and S6 designates that the row
%   corresponds to the scaling estimate at level 6. The scaling variance is
%   only computed for the final level of the MODWT. For unbiased estimates,
%   MODWTVAR computes the scaling variance only when there are nonboundary
%   scaling coefficients.
%
%   MODWTVAR(...) with no output arguments plots the wavelet variances by
%   scale with lower and upper confidence bounds. Because the scaling
%   variance can be much larger than the wavelet variances, the scaling
%   variance is excluded from the plot.
%
%   %Example 1:
%   %   Obtain and plot estimates of the wavelet variance by scale
%   %   for the Kobe earthquake data.
%
%   load kobe;
%   wkobe = modwt(kobe);
%   modwtvar(wkobe)
%
%   %Example 2:
%   %   Obtain estimates of the wavelet variance by scale for the Southern
%   %   Oscillation Index (SOI) data.
%
%   load soi;
%   wsoi = modwt(soi);
%   soivar = modwtvar(wsoi,'table')
%
%   % Plot the SOI variance by scale
%   modwtvar(wsoi)
%
%   See also MODWT, MODWTCORR, MODWTXCORR, MODWTMRA, IMODWT

%   Copyright 2015-2019 The MathWorks, Inc.

%#codegen

% Minimum number of inputs is 1 and maximum is 10
narginchk(1,10)

% Check number of output arguments
nargoutchk(0,3);

% Converting given input strings into characters.
temp_parse = cell(1,length(varargin));
[temp_parse{:}] = convertStringsToChars(varargin{:});

% Parse user-supplied inputs
if isempty(coder.target)
    %Parses inputs in MATLAB path
    [boundary, confMethod, ConfLevel, EstimatorType, L, ...
        tableflag] = parseinputsMATLAB(w,temp_parse,varargin{:});
else
    %Parses inputs during Code generation
    [boundary, confMethod, ConfLevel, EstimatorType, L, ...
        tableflag] = parseinputsCodegen(w,temp_parse,varargin{:});
end
scalingvar = false;

% Get the level -- the final row of w are the scaling coefficients
level = size(w,1)-1;

% Extract scaling coefficients
VJ = w(end,:);

% Extract wavelet coefficients
w = w(1:end-1,:);

% make sure that we do not compute the variance where they are no
% nonboundary coefficients
if (boundary && EstimatorType)
    if isodd(size(w,2))
        coder.internal.error('Wavelet:modwt:EvenLengthInput');
    end
    N = size(w,2)/2;
else
    N = size(w,2);
end

% For an unbiased estimate
if EstimatorType
    Jmax = floor(log2((N-1)/(max(L-1))+1));
    if (Jmax<1)
        coder.internal.error('Wavelet:modwt:ZeroNonBoundaryCFS');
    end
    Jmax = min(Jmax,level);
    w = w(1:Jmax,1:N);
    VJ = VJ(1:N);

    %Determine if we use the scaling coefficients
    if (Jmax-level==0)
        scalingvar = true;
    end

    % Remove boundary coefficients for unbiased estimate
    [cfs,MJ] = removemodwtboundarycoeffs(w,VJ,N,Jmax,L,scalingvar);

else
    scalingvar = true;
    Jmax = level;
    % For biased estimates use the entire coefficient matrix
    % Includes scaling variance
    cfs = [w ; VJ];
    MJ = size(cfs,2)*ones(1,Jmax+1);
end

%Allocate arrays for wvartmp and AJ
wvartmp = NaN(1,size(cfs,1));
%wvartmp = zeros(1,size(cfs,1));
AJ = zeros(1,size(cfs,1));

% Calculate the estimate of the wavelet variance
for jj = 1:size(cfs,1)
    cfsNoNaN = cfs(jj,~isnan(cfs(jj,:)));
    wacs = modwtACS(cfsNoNaN,MJ(jj));
    %wvar(jj) = sum(abs(cfsNoNaN).^2)/MJ(jj);
    wvartmp(jj) = real(wacs(1));
    AJ(jj) = real(wacs(1))^2/2+sum(abs(wacs(2:end)).^2);
end

% Obtain critical value for Chi-square or Gaussian PDFs.
critvalue = (1+ConfLevel)/2;

J = 1:Jmax;

% If scalingvar is true we append the final level to represent
% the final-level scaling coefficients

if scalingvar
    J = [J Jmax];
end

if confMethod == 1 % Check if confMethod is Gaussian
    critvalue = -sqrt(2)*erfcinv(2*critvalue);
    lowerci = wvartmp-critvalue*sqrt(2*AJ./MJ);
    upperci = wvartmp+critvalue*sqrt(2*AJ./MJ);

elseif confMethod == 2 % Check if confMethod is chi2eta1
    eta = modwtEDOF(wvartmp,MJ,AJ);
    lowercritvalues = 2*gammaincinv(critvalue,eta/2);
    uppercritvalues = 2*gammaincinv(1-critvalue,eta/2);
    lowerci = (eta.*wvartmp)./lowercritvalues;
    upperci = (eta.*wvartmp)./uppercritvalues;

else % Default case for confMethod('chi2eta3')
    % EDOF calculation
    etatmp = MJ./2.^J;
    eta = max(etatmp,1);
    % chi-square lower and upper critical values
    lowercritvalues = 2*gammaincinv(critvalue,eta/2);
    uppercritvalues = 2*gammaincinv(1-critvalue,eta/2);
    lowerci = (eta.*wvartmp)./lowercritvalues;
    upperci = (eta.*wvartmp)./uppercritvalues;
end

% Concatenate lower and upper confidence bounds with variance
% estimates
wvartmp = [lowerci' wvartmp' upperci'];

if nargout>1 && tableflag
    coder.internal.error('Wavelet:modwt:InvalidOutput');
end

if  nargout == 1 && tableflag
    % Create row names for table
    rownames = coder.nullcopy(cell(numel(J),1));
    J_int = int32(J);
    for ii = 1:numel(J)
        rownames{ii} = sprintf('D%d',J_int(ii));
    end

    if scalingvar
        rownames{end} = sprintf('S%d',int32(level));
    end
    temp_wvar = [MJ' wvartmp];
    varargout{1} = array2table(temp_wvar,'VariableNames',{'NJ','Lower','Variance','Upper'},...
        'RowNames',rownames);
elseif nargout > 0 && ~tableflag
    varargout{1} = wvartmp(:,2);
    varargout{2} = [lowerci' upperci'];
    varargout{3} = MJ';
end

if nargout == 0 && isempty(coder.target)
    plotmodwtvar(wvartmp,scalingvar);
elseif nargout == 0 && ~isempty(coder.target)
    coder.internal.assert(~(nargout == 0 && ~isempty(coder.target)),...
        'Wavelet:codegeneration:Plotting');
end

%--------------------------------------------------------------------%
function wacs = modwtACS(cfs,MJ)
N = size(cfs,2);
cfs = cfs - repmat(mean(cfs),size(cfs));
fftpad = 2^nextpow2(2*N);
wacsDFT = fft(cfs,fftpad,2).*conj(fft(cfs,fftpad,2));
wacs = ifftshift(ifft(wacsDFT,[],2),2);
wacs = 1/MJ*(wacs(fftpad/2+1:fftpad/2+MJ));
%-------------------------------------------------------------------%

%-------------------------------------------------------------------%
function eta1 = modwtEDOF(wvar,MJ,AJ)
eta1 = (MJ.*wvar.^2)./AJ;

function [boundary, confMethod, ConfLevel, EstimatorType, L, ...
    tableflag] = parseinputsMATLAB(w,parse_char,varargin)

% Validate w
validate_w(w);

% Parse and Validate varargin

%Get default values for Estimator Type, Confidence method, boundary,
%Confidence level and table flag.
[EstimatorType,confMethod,boundary,ConfLevel,L,tableflag] = defaultValues;

if isempty(varargin)
    return;
else
    tempboundary = 'periodic';
    tempconfMethod = 'chi2eta3';
    tempEstimatorType = 'unbiased';
    tftable = strcmpi('table',parse_char);
    if any(tftable)
        tableflag = true;
        parse_char(tftable>0) = [];
    end
    if ~isempty(parse_char)
        Length_inputargs = length(parse_char);

        % The wavelet must be the first input argument in varargin after removing
        % the 'table' flag
        wavlen = parse_char{1};

        % Handle cases where the wavelet is a string or a scalar
        % empty
        if ischar(wavlen)
            [~,~,Lo,~] = wfilters(wavlen);
            L = length(Lo);
        elseif isscalar(wavlen) && isnumeric(wavlen)
            L = double(wavlen);
        elseif isempty(wavlen)
            L = 8;
        else
            coder.internal.error('Wavelet:modwt:InvalidWavelet');
        end

        % If there is more than one variable input, the second input must be the
        % confidence level
        if (Length_inputargs>1)
            ConfLevel = parse_char{2};
            if isempty(ConfLevel)
                ConfLevel = 0.95;
            end
        end

        if Length_inputargs>2
            parse_char = parse_char(3:end);

            % Parse any PV pairs
            if isodd(length(parse_char))
                coder.internal.error('Wavelet:modwt:PVPairs');
            end

            parse_char = lower(parse_char);
            Npv = length(parse_char);
            Npv = Npv/2;

            varname = cell(Npv,1);
            varvalue = cell(Npv,1);

            for ii = 1:Npv
                varname{ii} = parse_char{2*ii-1};
                varvalue{ii} = parse_char{2*ii};
            end

            % Look for valid names in the Name-Value pairs
            tfconfmethod = strncmp(varname,'confidencemethod',1);
            tfesttype = strncmp(varname,'estimatortype',1);
            tfboundary = strncmp(varname,'boundary',1);

            if any(tfconfmethod)
                tempconfMethod = varvalue(tfconfmethod>0);
            end

            if any(tfesttype)
                tempEstimatorType = varvalue(tfesttype>0);
            end

            if any(tfboundary)
                tempboundary = varvalue(tfboundary>0);
            end
        end
    end

    %Validate parsed input arguments
    [confMethod,boundary,EstimatorType] = validate_varargin(L,ConfLevel,...
        tempconfMethod,tempboundary,tempEstimatorType,false);
end

function [boundary, confMethod, ConfLevel, EstimatorType, L, ...
    tableflag] = parseinputsCodegen(w,parse_char,varargin)

% Validate w
validate_w(w);

% Parse and Validate varargin

%Get default values for Estimator Type, Confidence method, boundary,
%Confidence level and table flag.
[EstimatorType,confMethod,boundary,ConfLevel,L,tableflag] = defaultValues;

%Calling wfilters with extrinsic and coder.const
coder.extrinsic('wfilters');

if isempty(varargin)
    return;
else
    tempboundary = 'periodic';
    tempconfMethod = 'chi2eta3';
    tempEstimatorType = 'unbiased';
    errflag_pv = false;
    idxArr = 1:length(parse_char);
    idx = 0;
    for i = coder.unroll(1:length(parse_char))
        if (i ~= length(varargin))
            if ischar(parse_char{i}) && strncmpi(varargin{i},'estimatortype',3)...
                    && coder.internal.isConst(varargin{i}) && idxArr(i)
                tempEstimatorType = parse_char{i+1};
                idxArr(i) = 0;
                idxArr(i+1) = 0;
            end

            if ischar(parse_char{i}) && strncmpi(varargin{i},'confidencemethod',4)...
                    && coder.internal.isConst(varargin{i}) && idxArr(i)
                tempconfMethod = parse_char{i+1};
                idxArr(i) = 0;
                idxArr(i+1) = 0;
            end

            if ischar(parse_char{i}) && strncmpi(varargin{i},'boundary',1)...
                    && coder.internal.isConst(varargin{i}) && idxArr(i)
                tempboundary = parse_char{i+1};
                idxArr(i) = 0;
                idxArr(i+1) = 0;
            end
        end
        if ischar(parse_char{i}) && strcmpi(parse_char{i},'table')...
                && coder.internal.isConst(varargin{i}) && idxArr(i)
            tableflag = true;
            idxArr(i) = 0;
        end
    end
    
    nargs = nnz(idxArr);
    args = coder.nullcopy(cell(1,nargs));
    idx_wname = 1;
    for i = 1:length(parse_char)
        if  idxArr(i) ~= 0
            idx = idx+ 1;
            if ischar(parse_char{i})
                idx_wname = coder.const(i);
            end
            args{idx} = parse_char{i};
        end
    end

    length_args = length(args);
    for i = 1:length_args
        if ischar(args{i}) && coder.internal.isConst(varargin{idx_wname}) && i == 1
            [~,~,Lo,~] = coder.const(@wfilters,varargin{idx_wname});
            L = length(Lo);
        elseif isscalar(args{i}) && isnumeric(args{i}) && i == 1
            L = double(args{i});
        elseif isempty(args{i}) && isnumeric(args{i}) && i == 1
            L = 8;
        elseif i == 1
            coder.internal.error('Wavelet:modwt:InvalidWavelet');
        end

        if length_args > 1 && isscalar(args{i}) && isnumeric(args{i})
            ConfLevel = args{i}(1);
        elseif length_args > 1 && isempty(args{i}) && isnumeric(args{i})
            ConfLevel = 0.95;
        end
    end

    %Validate parsed input arguments
    [confMethod,boundary,EstimatorType] = validate_varargin(L,ConfLevel,...
        tempconfMethod,tempboundary,tempEstimatorType,errflag_pv);
end

function validate_w(w)
% Ensure that the input has at least two rows
if (isrow(w) || iscolumn(w))
    coder.internal.error('Wavelet:modwt:InvalidCFSSize');
end

% Input must be double-precision and real-valued with no NaNs or Infs
validateattributes(w,{'double'},{'real','nonnan','finite','nonempty'}, ...
    'modwtvar','W',1);

function [confMethod,boundary,EstimatorType] = validate_varargin(L,...
    ConfLevel,tempconfMethod,tempboundary,tempEstimatorType,errflag_pv)

[EstimatorType,confMethod,boundary,~,~,~] = defaultValues;

%Check that the confidence level is valid
validateattributes(ConfLevel,{'numeric'},{'scalar','real','>',0,'<',1});

% The wavelet length must be a positive integer
validateattributes(L,{'numeric'},{'real','positive','even','scalar'});

%%% validation of input arguments
if strcmpi(tempconfMethod,'chi2eta1')
    confMethod = 2;
elseif strncmpi(tempconfMethod,'gaussian',1)
    confMethod = 1;
elseif ~strcmpi(tempconfMethod,'chi2eta3')
    errflag_pv = true;
end

if strncmpi(tempboundary,'reflection',1)
    boundary = true;
elseif ~strncmpi(tempboundary,'periodic',1)
    errflag_pv = true;
end

if strncmpi(tempEstimatorType,'biased',1)
    EstimatorType = false;
elseif ~strncmpi(tempEstimatorType,'unbiased',1)
    errflag_pv = true;
end

% Parse any PV pairs
if errflag_pv
    coder.internal.error('Wavelet:modwt:PVPairs');
end

function [EstimatorType,confMethod,boundary,ConfLevel,L,tableflag] = defaultValues

% Declare defaults
EstimatorType = true;
confMethod = 3;
boundary = false;
ConfLevel = 0.95;
L = 8;  % Length of default 'sym4' wavelet filter
tableflag = false;

%---------------------------------------------------------------------
function plotmodwtvar(wvartmp,scalingvar)
% Plots the estimates of the wavelet variance by scale. Because the scaling
% variance is often much larger than the wavelet variances, we do not plot
% the scaling variance here.
if scalingvar
    wvar = wvartmp(1:end-1,:);
else
    wvar = wvartmp;
end

levels = 1:size(wvar,1);
wavescale = (2.^levels);

varest = wvar(:,2);
lower = varest-wvar(:,1);
upper = wvar(:,3)-varest;

errorbar(log2(wavescale),varest,lower,upper,'bx','markersize',12,...
    'markerfacecolor',[0 0 1]);
grid on;
Ax = gca;
Ax.XLim = [-0.25 levels(end)+0.5];
Ax.XTick = log2(wavescale);
xlabel('Log(scale) -- base 2');
ylabel('Variance');
title('Wavelet Variance by Scale');
