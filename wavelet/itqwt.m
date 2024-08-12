function xrec = itqwt(wt,N,varargin)
%Inverse tunable Q-factor wavelet transform
%   XREC = ITQWT(WT,N) returns the inverse tunable Q-factor wavelet
%   transform (TQWT) of the analysis coefficients in WT. WT is a cell array
%   containing the wavelet subband and lowpass coefficients obtained from
%   TQWT using the default quality factor of 1. N is the original signal
%   length specified as a positive scalar. If N is odd, N+1 is used
%   internally to invert the tunable Q-factor transform and the first N
%   samples are returned.
%
%   XREC = ITQWT(...,'Level',LEVEL) returns the inverse TQWT at level
%   LEVEL. LEVEL is a nonnegative integer less than or equal to
%   length(WT)-2. If unspecified, LEVEL defaults to 0, which reconstructs
%   the tunable Q-factor transform up to the resolution level of the
%   original signal.
%
%   XREC = ITQWT(...,'QualityFactor',Q) uses the quality factor Q to
%   reconstruct XREC. Q must match the value used in TQWT.
%
%   %Example: Obtain the tunable Q-factor wavelet transform of the Kobe
%   %   earthquake data using a quality factor of 3. Reconstruct the data
%   %   from the subband coefficients.
%   load kobe
%   wt = tqwt(kobe,Q = 3);
%   xrec = itqwt(wt,numel(kobe),Q = 3);
%   norm(xrec-kobe,Inf)
%
%   See also tqwt, tqwtmra

%   Selesnick, Ivan W. "Wavelet Transform With Tunable Q-Factor."
%   IEEE Transactions on Signal Processing 59, no. 8 (2011): 3560-75. 
%   https://doi.org/10.1109/tsp.2011.2143711. 

% Copyright 2021 The MathWorks, Inc.

%#codegen

narginchk(2,6);
nargoutchk(0,1);
coder.internal.errorIf(~iscell(wt),'Wavelet:tqwt:WTCell');
validateattributes(N,{'numeric'},{'scalar','positive','integer'},...
    'ITQWT','N');
Level = coder.internal.const(length(wt)-1);
OddSigLength = signalwavelet.internal.isodd(N);
if OddSigLength
    Norig = N;
    N = N+1;
else
    Norig = N;
end
if isempty(coder.target)
    isReal = all(cellfun(@(x)~any(imag(x(:))),wt));
else
    realcfs = false(length(wt),1);
    for ii = 1:length(wt)
        realcfs(ii) = ~any(imag(wt{ii}(:)));
    end
    isReal = all(realcfs);
end
% The following is unecessary from a MATLAB only perspective but needed for
% code generation. The following is required to ensure that Coder
% classifies the cell array as homogenous.
if ~isempty(coder.target)
    coder.varsize('tmpwt');
    tmpwt = wt;
end
coder.internal.prefer_const(varargin{:});
params = parseinputs(varargin{:});
validateattributes(params.Level,{'numeric'},{'scalar','>=',0,'<=',Level},...
    'ITQWT','Level');

coder.internal.assert(params.Alpha + params.Beta > 1,'Wavelet:tqwt:NotOS',...
    sprintf('%1.3f',params.Alpha),sprintf('%1.3f',params.Beta));
if isempty(coder.target) && params.Level
    for ii = 1:params.Level
        wt{ii} = zeros(size(wt{ii}),'like',wt{ii});
    end
elseif ~isempty(coder.target) && params.Level
    for ii = 1:params.Level
        tmpwt{ii} = zeros(size(tmpwt{ii}),'like',tmpwt{ii});
    end
end
coder.varsize('scalDFT');
coder.varsize('wcfs');
scalDFT = wavelet.internal.tqwt.udft(wt{Level+1});

if ~isempty(coder.target)
    for jj = Level:-1:1
        wcfs = wavelet.internal.tqwt.udft(tmpwt{jj});
        M = 2*round(params.Alpha^(jj-1) * N/2);
        scalDFT = wavelet.internal.tqwt.synthesisFilterBank(scalDFT, wcfs, M);
    end
else
    for jj = Level:-1:1
        wcfs = wavelet.internal.tqwt.udft(wt{jj});
        M = 2*round(params.Alpha^(jj-1) * N/2);
        scalDFT = wavelet.internal.tqwt.synthesisFilterBank(scalDFT, wcfs, M);
    end
    
end

xrectmp = wavelet.internal.tqwt.uidft(scalDFT,isReal);
% Adjustment for desired output length
xrec = xrectmp(1:Norig,:,:);

%--------------------------------------------------------------------------
function params = parseinputs(varargin)

params = struct('Beta',0.0,'Alpha',0.0,'Level',0.0);
parms = struct('QualityFactor',uint32(0),'Level',uint32(0));
defaultQ = 1;
% In 2021b, the redundancy factor is fixed at 3.
R = 3;
defaultLev = 0;
% Structure array for options
popts = struct('CaseSensitivity',false,'PartialMatching',true);
% Parse structure array with options
pstruct = coder.internal.parseParameterInputs(parms,popts,varargin{:});
qfactor = ...
    coder.internal.getParameterValue(pstruct.QualityFactor,...
    defaultQ,varargin{:});
validateattributes(qfactor,{'numeric'},{'scalar','>=',1,'real'},...
    'ITQWT','QualityFactor');
params.Level = ...
    coder.internal.getParameterValue(pstruct.Level,defaultLev,varargin{:});

% Both beta and alpha are computed based on the desired Q-factor
params.Beta = 2/(qfactor+1);
params.Alpha = 1-params.Beta/R;




