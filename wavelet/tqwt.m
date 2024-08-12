function [wt,info] = tqwt(x,varargin)
%Tunable Q-factor wavelet transform
%   WT = TQWT(X) returns the tunable Q-factor wavelet transform (TQWT) of
%   X. X is a double- or single-precision real- or complex-valued vector,
%   matrix, or 3-D array. If X is a matrix or 3-D array, the tunable
%   Q-factor wavelet transform is computed along the columns of X. For 3-D
%   arrays, TQWT interprets the first dimension as time, the second
%   dimension as channel, and the third dimension as batch.
%
%   The default quality factor is 1.
%
%   The tunable Q-factor wavelet transform is defined for even-length
%   signals. If the number of samples in X is odd, the last sample of X is
%   repeated to obtain an even-length signal. 
%
%   Note in the following description of maximum and minimum decomposition
%   levels, the signal length, N, is one sample greater than the input
%   length for odd-length signals.
%
%   The TQWT is computed down to the maximum decomposition level by
%   default. The maximum decomposition level depends on the signal length,
%   N, and the quality factor, Q.
%
%   The maximum decomposition level is:
%
%   floor(log(N/(4*Q+4))/log((3*Q+3)/(3*Q+1)))
%
%   The minimum level also depends on the signal length and quality factor. 
%   The logarithm of N, log(N), must satisfy the following inequality: 
%
%   log(N) >= log(4*Q+4)-log(3*Q+1)+log(3*Q+3) 
%
%   If log(N) < log(4*Q+4)-log(3*Q+1)+log(3*Q+3), the maximum level is less
%   than 1 and TQWT throws an error. 
%
%   WT is a cell array with length equal to the maximum level of the
%   tunable Q-factor wavelet transform plus one. The i-th element of WT
%   contains the tunable Q-factor wavelet transform coefficients for the
%   i-th subband. The subbands are ordered by decreasing center frequency.
%   The final element of WT contains the lowpass subband coefficients. If X
%   is a vector, each element of WT is a column vector containing the
%   tunable Q-factor wavelet transform coefficients. If X is a matrix or
%   3-D array, the column and page sizes of each element of WT match the
%   column and page sizes of X. The wavelet coefficients in WT match X in
%   data type and complexity.
%
%   WT = TQWT(...,'Level',LEVEL) specifies the level of the TQWT as a
%   positive integer between 1 and the maximum level. If you specify a
%   decomposition level greater than the maximum level, TQWT is computed
%   down to the maximum level.
% 
%   WT = TQWT(...,'QualityFactor',Q) specifies the quality factor. The
%   quality factor is a real-valued scalar greater than or equal to 1. If
%   unspecified, the quality factor defaults to 1.
%
%   [WT,INFO] = TQWT(...) returns the structure array, INFO, with
%   information about the tunable Q-factor wavelet transform. The fields of
%   INFO are:
%
%   CenterFrequencies:  The normalized center frequencies (cycles/sample)
%                       of the wavelet subbands in the TQWT of X. Multiply
%                       INFO.CenterFrequencies by the sample rate to
%                       convert these frequencies to hertz. See the 
%                       documentation for details on how the center 
%                       frequencies are determined.
%
%   Bandwidths:         The approximate bandwidths of the wavelet subbands
%                       in normalized frequency (cycles/sample). Multiply
%                       INFO.Bandwidths by the sample rate to convert the
%                       bandwidths to hertz. See the documentation for 
%                       details on how the bandwidths are determined.
%
%   Level:              Level of the TQWT. Note this may be different from
%                       your specified level if you specify a level greater
%                       than the maximum supported level for your signal
%                       length and quality factor.
%
%   Beta:               Highpass scaling factor. The highpass scaling
%                       factor is computed from the quality factor as
%                       2/(Q+1). Accordingly, 0 < Beta <= 1. See the
%                       documentation for a detailed explanation of the
%                       role of Beta in the TQWT.
%
%   Alpha:              Lowpass scaling factor. The lowpass scaling factor
%                       is computed from the highpass scaling factor as
%                       1-Beta/3. Accordingly, 2/3 <= Alpha < 1. See the
%                       documentation for a detailed explanation of the
%                       role of Alpha in the TQWT.
%
%   %Example: Obtain the tunable Q-factor wavelet transform down to level
%   %    5 of an ECG signal with a quality factor of 2.
%   load wecg
%   wt = tqwt(wecg,QualityFactor = 2, Level = 5);
%
%
%   %Example: Obtain the tunable Q-factor wavelet transform of a 
%   %   multichannel EEG signal to the maximum level using the default 
%   %   quality factor of 1. Reconstruct the multichannel signal and
%   %   demonstrate the perfect reconstuction property of the tunable 
%   %   Q-factor wavelet transform.
%   load Espiga3
%   wt = tqwt(Espiga3);
%   xrec = itqwt(wt,size(Espiga3,1));
%   max(abs(xrec-Espiga3))
%
%   See also itqwt, tqwtmra

%   Selesnick, Ivan W. "Wavelet Transform With Tunable Q-Factor."
%   IEEE Transactions on Signal Processing 59, no. 8 (2011): 3560-75. 
%   https://doi.org/10.1109/tsp.2011.2143711. 


% Copyright 2021 The MathWorks, Inc.


%#codegen
narginchk(1,5);
nargoutchk(0,2);
if isempty(coder.target)
    nargoutchk(0,2);
else
    nargoutchk(1,2);
end
validateattributes(x,{'double','single'},{'nonempty'},'TQWT','X');
dtype = underlyingType(x);
[~,~,~,q] = size(x);
isReal = ~any(imag(x(:)));
coder.internal.errorIf(q>1,'Wavelet:tqwt:FourDims');
if isvector(x) && isrow(x) 
    xt = x(:);
else
    xt = x;
end
Norig = size(xt,1);
TFodd = signalwavelet.internal.isodd(Norig);
if TFodd
    xtext = [xt ; xt(end,:,:)];
    N = Norig+1;
else
    xtext = xt;
    N = Norig;
end
params = parseinputs(N,dtype,varargin{:});
% sprintf() required for code generation because params.Alpha and
% params.Beta are not constants.
coder.internal.assert(params.Alpha + params.Beta > 1,'Wavelet:tqwt:NotOS',...
    sprintf('%1.3f',params.Alpha),sprintf('%1.3f',params.Beta));
if isempty(coder.target)
    wt = cell(params.Level+1,1);
else
    cfstemp = {zeros(0,1,'like',xtext)};
    wt = repmat(cfstemp,params.Level+1,1);
end

% Unitary DFT of input
coder.varsize('xdft');
coder.varsize('details');
xdft = wavelet.internal.tqwt.udft(xtext);

% Loop through levels of the transform
for jj = 1:params.Level
   Nscale = 2*round(params.Alpha^jj*N/2); 
   Nwav = 2*round(params.Beta*params.Alpha^(jj-1)*N/2);
   [xdft,details] = ...
       wavelet.internal.tqwt.analysisFilterBank(xdft,Nscale,Nwav);
   wt{jj} = wavelet.internal.tqwt.uidft(details,isReal);
end

wt{params.Level+1} = wavelet.internal.tqwt.uidft(xdft,isReal);


if nargout > 1
   jj = 1:params.Level;
   fc = params.Alpha.^(jj-1).*(2-params.Beta)/4;
   bw = 1/4*params.Beta*params.Alpha.^(jj-1);
   info = struct('CenterFrequencies',fc,'Bandwidths',bw,...
       'Level',params.Level,'Alpha', params.Alpha,'Beta',params.Beta);
end


%--------------------------------------------------------------------------
function params = parseinputs(N,dtype,varargin)
params = struct('Beta',cast(0.0,dtype),'Alpha',cast(0.0,dtype),...
    'Level',cast(0,dtype));
parms = struct('QualityFactor',uint32(0),'Level',uint32(0));
defaultQ = 1;
% In 2021b we are only supporting the redundancy factor of 3.
R = 3;
% Structure array for options
popts = struct('CaseSensitivity',false,'PartialMatching',true);
% Parse structure array with options
pstruct = coder.internal.parseParameterInputs(parms,popts,varargin{:});
qfactor = ...
    coder.internal.getParameterValue(pstruct.QualityFactor,...
    defaultQ,varargin{:});
validateattributes(qfactor,{'numeric'},{'scalar','>=',1,'real'},...
    'TQWT','QualityFactor');
minSigLen = ceil(exp(log(4*qfactor+4)-log(3*qfactor+1)+log(3*qfactor+3)));
% SPRINTF needed for MATLAB Coder. The explicit cast to an integer type is
% needed for the %d format specifier
 coder.internal.errorIf(N < minSigLen,'Wavelet:tqwt:minLen',...
    sprintf('%d',cast(minSigLen,'int32')), sprintf('%2.2f',qfactor));

% Both beta and alpha are computed based on the desired Q-factor and r
params.Beta = cast(2/(qfactor+1),dtype);
params.Alpha = cast(1-params.Beta/R,dtype);
% Validate level now that \alpha and \beta are known
Jmax = floor(log(params.Beta*N/8)/log(1/params.Alpha));
coder.internal.errorIf(Jmax <= 0, 'Wavelet:tqwt:Jmax');
tmplevel = ...
    coder.internal.getParameterValue(pstruct.Level,Jmax,varargin{:});
validateattributes(tmplevel,{'numeric'},{'scalar','positive','integer'},...
    'TQWT','Level');
params.Level = cast(tmplevel,dtype);
if params.Level > Jmax
    params.Level = Jmax;
end





    




