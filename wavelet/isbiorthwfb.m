function [tf,checks] = isbiorthwfb(LoR,LoD,varargin)
% ISBIORTHWFB True for biorthogonal wavelet filter bank 
% TF = ISBIORTHWFB(LoR,LoD) returns true if the two-channel filter bank
% formed from the lowpass filters, LoR and LoD, satisfies the necessary and
% sufficient conditions to be a two-channel biorthogonal perfect
% reconstruction (PR) wavelet filter bank. See the documentation for
% details. For all required checks, a tolerance of
% sqrt(eps(underlyingType(LoR))) is used by default. 
% ISBIORTHWFB forms the dual highpass (wavelet) filters using the QMF 
% function: 
% HiD = qmf(LoR);
% HiR = qmf(LoD);
% LoR and LoD are not required to have equal or even length. ISBIORTHWFB 
% equalizes the lengths internally using BIORFILT. LoR and LoD should sum 
% to 1 or sqrt(2).
%
% TF = ISBIORTHWFB(LoR,LoD,HiR,HiD) uses the four filters LoR, LoD, HiR,
% and HiD to determine whether the four filters jointly satisfy the 
% necessary and sufficient conditions to be a two-channel biorthogonal
% PR wavelet filter bank. 
%
% TF = ISBIORTHWFB(...,Tolerance=TOL) uses the real-valued positive scalar
% tolerance, TOL, to determine whether the filters form a two-channel
% biorthogonal PR wavelet filter bank. If unspecified, TOL defaults to
% sqrt(eps(underlyingType(LoR))).
%
% [TF,CHECKS] = ISBIORTHWFB(...) returns a table with all biorthogonality
% checks. The table shows "pass" or "fail" for each check as well as the
% maximum error and specified test tolerance where applicable. A test
% tolerance of 0 indicates that the check is a logical pass or fail.
%
%   %Example: Obtain the biorthogonal spline wavelet filters with 3
%   %   vanishing moments in the analysis filters and 1 vanishing moment in 
%   %   the synthesis filters. Test the biorthogonality of the filters. 
%   %   Repeat the check by just obtaining the lowpass analysis and 
%   %   synthesis filters.
%
%   [LoD,HiD,LoR,HiR] = wfilters('bior3.1');
%   [tf,checks] = isbiorthwfb(LoR,LoD,HiR,HiD)
%   [df,rf] = biorwavf('bior3.1');
%   [tf,checks] = isbiorthwfb(rf,df);
%
%   See also isorthwfb wavemngr wfilters

%   Copyright 2021 The MathWorks, Inc.

%#codegen
narginchk(2,6);
popts = struct(...
                'CaseSensitivity',false, ...
                'PartialMatching','unique',...
                'SupportOverrides', false);
OPargs = struct('HiR',@(x)isnumeric(x),'HiD',@(x)isnumeric(x));
NVargs = struct('Tolerance',uint32(0));
params = coder.internal.parseInputs(OPargs,NVargs,popts,varargin{:});
HiR = coder.internal.getParameterValue(params.HiR,cast([],'like',LoR),varargin{:});
HiD = coder.internal.getParameterValue(params.HiD,cast([],'like',LoR),varargin{:});
tmptol = coder.internal.getParameterValue(params.Tolerance,...
    sqrt(eps(underlyingType(LoR))),varargin{:});
validateattributes(LoR,{'double','single'},...
    {'vector','finite','nonempty','real'},'isbiorthwfb','LoR');
validateattributes(LoD,{'double','single'},...
    {'vector','finite','nonempty','real'},'isbiorthwfb','LoD');
validateattributes(tmptol,{'numeric'},{'real','positive','scalar'},...
    'isbiorthwfb','TOL');
if ~isempty(HiR)
    validateattributes(HiR,{'double','single'},...
        {'vector','finite','nonempty','real'},'isbiorthwfb','HiR');
end

if ~isempty(HiD)
    validateattributes(HiD,{'double','single'},...
        {'vector','finite','nonempty','real'},'isbiorthwfb','HiD');
end

dataType = underlyingType(LoR);
if ~strcmpi(underlyingType(LoD),dataType)
    LoDtmp = cast(LoD,'like',LoR);
else
    LoDtmp = LoD;
end

tol = cast(tmptol,'like',LoR);
% Obtain equal-length and properly normalized filters for the
% scaling filters.
[LoDeq,~,~,~,~,~,LoReq,~] = biorfilt(LoDtmp,LoR,1);
lenLoReq = length(LoReq);
coder.varsize('HiRtmp');
coder.varsize('HiDtmp');
if isempty(HiR)
    [~,~,~,HiRtmp,~,~,~,~] = biorfilt(LoDeq,LoReq,1);
    HiReq = cast(HiRtmp,'like',LoR);
else
    HiRtmp = HiR;
    HiReq = cast(HiRtmp(:).','like',LoR);
end

if isempty(HiD)
    [~,~,~,~,~,HiDtmp,~,~] = biorfilt(LoDeq,LoReq,1);
    HiDeq = cast(HiDtmp,'like',LoR);
else
    HiDtmp = HiD;
    HiDeq = cast(HiDtmp(:).','like',LoR);
end

[tf,allChecks,maxDeviation] = wavelet.internal.CheckBiorthFilter(LoReq,...
    LoDeq,HiReq,HiDeq,tol);
tolerance = repmat(cast(0,'like',LoR),7,1);
if lenLoReq > 2
    tolerance(2:7) = tol;
else
    tolerance([2,3,4,7]) = tol;
end

checks = table(allChecks,maxDeviation,tolerance,'VariableNames',...
    {'Pass-Fail','Maximum Error','Test Tolerance'},'RowNames',...
    {'Dual filter lengths correct','Filter sums',...
    'Zero lag lowpass dual filter cross-correlation',...
    'Zero lag highpass dual filter cross-correlation', ...
    'Even lag lowpass dual filter cross-correlation'...
    'Even lag highpass dual filter cross-correlation', ...
    'Even lag lowpass-highpass cross-correlation'});







