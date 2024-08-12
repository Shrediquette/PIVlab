function [tf,checks] = isorthwfb(Lo,varargin)
% ISORTHWFB True for orthogonal wavelet filter bank 
% TF = ISORTHWFB(Lo) returns true if the two-channel filter bank formed
% from the lowpass filter, Lo, satisfies the necessary and sufficient
% conditions to be a two-channel orthonormal perfect reconstruction (PR)
% wavelet filter bank. See the documentation for details. Lo must have an
% even number of samples. For all required checks, a tolerance of
% sqrt(eps(underlyingType(Lo))) is used by default. 
% ISORTHWFB forms the highpass (wavelet) filter using the QMF function:
% Hi = qmf(Lo);
% Lo should sum to 1 with an L2 norm of 1/sqrt(2) or sum to sqrt(2) with
% an L2 norm of 1.
%
% TF = ISORTHWFB(Lo,Hi) uses the highpass filter, Hi, to determine whether
% Lo and Hi jointly satisfy the necessary and sufficient conditions to be a
% two-channel orthonormal PR wavelet filter bank. Lo and Hi must have the 
% same number of samples and be even-length vectors. ISORTHWFB assumes that
% Lo and Hi form an orthogonal quadrature mirror filter pair. For the
% checks to return accurate results, ensure that you provide either both
% analysis filters or both synthesis filters.
%
% TF = ISORTHWFB(...,Tolerance=TOL) uses the real-valued positive scalar
% tolerance, TOL, to determine whether the filters form a two-channel
% orthonormal PR wavelet filter bank. If unspecified, TOL defaults to 
% sqrt(eps(underlyingType(Lo))).
%
% [TF,CHECKS] = ISORTHWFB(...) returns a table with all orthogonality
% checks. The table shows "pass" or "fail" for each check as well as the
% maximum error and specified test tolerance where applicable. A test
% tolerance of 0 indicates that the check is a logical pass or fail.
%
%   %Example: Check the orthogonality conditions for the 'db8' scaling
%   %   filter. Seeing that all checks pass, form the orthogonal scaling
%   %   and wavelet analysis and synthesis filters.
%   h = dbwavf('db8');
%   [tf,checks] = isorthwfb(h)
%   [LoD,HiD,LoR,HiR] = orthfilt(h);
%   
%   See also isbiorthwfb wavemngr wfilters

%   Copyright 2021 The MathWorks, Inc.

%#codegen
narginchk(1,4);
popts = struct(...
                'CaseSensitivity',false, ...
                'PartialMatching','unique',...
                'SupportOverrides', false);
OPargs = struct('Hi',@(x)isnumeric(x));
NVargs = struct('Tolerance',uint32(0));
params = coder.internal.parseInputs(OPargs,NVargs,popts,varargin{:});
Hi = coder.internal.getParameterValue(params.Hi,cast([],'like',Lo),varargin{:});
tmptol = coder.internal.getParameterValue(params.Tolerance,...
    sqrt(eps(underlyingType(Lo))),varargin{:});
validateattributes(Lo,{'double','single'},...
    {'vector','finite','nonempty','real'},'ISORTHWFB','Lo');
validateattributes(tmptol,{'double','single'},...
    {'scalar','positive','finite'},'ISORTHWFB','TOL');

tol = cast(tmptol,'like',Lo);
[~,~,LoNormed] = orthfilt(Lo);
coder.varsize('Hitmp');
if isempty(Hi)
    Hitmp = qmf(LoNormed);
else
    validateattributes(Hi,{'double','single'},...
    {'vector','finite','nonempty','real'},'ISORTHWFB','Hi');
    Hitmp = cast(Hi,'like',Lo);
end
lenLo = length(LoNormed);
lenHi = length(Hitmp);
coder.internal.errorIf(lenLo < 2 || signalwavelet.internal.isodd(lenLo),...
    'Wavelet:FunctionInput:OrthEvenFilt');
coder.internal.errorIf(lenHi < 2 || signalwavelet.internal.isodd(lenHi),...
    'Wavelet:FunctionInput:OrthEvenFilt');
[tf,allChecks,maxDeviation] = wavelet.internal.CheckOrthFilter(LoNormed,Hitmp,tol);
tolerance = repmat(cast(0,'like',Lo),7,1);
if lenLo > 2
    tolerance(3:7) = tol;
else
    tolerance(3:5) = tol;
end
checks = table(allChecks,maxDeviation,tolerance,'VariableNames',...
    {'Pass-Fail','Maximum Error','Test Tolerance'},'RowNames',...
    {'Equal-length filters','Even-length filters','Unit-norm filters',...
    'Filter sums','Even and odd downsampled sums',...
    'Zero autocorrelation at even lags', 'Zero crosscorrelation at even lags'});



