function varargout = swt(x,n,varargin)
%SWT Discrete stationary wavelet transform 1-D.
%   SWT performs a multilevel 1-D stationary wavelet decomposition
%   using either a specific orthogonal wavelet ('wname' see
%   WFILTERS for more information) or specific orthogonal wavelet 
%   decomposition filters.
%
%   SWC = SWT(X,N,'wname') computes the stationary wavelet
%   decomposition of the real-valued signal X at level N, using 'wname'.
%   N must be a strictly positive integer (see WMAXLEV for more
%   information). 2^N must divide length(X).
%
%   SWC = SWT(X,N,Lo_D,Hi_D) computes the stationary wavelet
%   decomposition as above given these filters as input:
%     Lo_D is the decomposition low-pass filter and
%     Hi_D is the decomposition high-pass filter.
%     Lo_D and Hi_D must be the same length.
%
%   Output matrix SWC contains the vectors of coefficients
%   stored row-wise: 
%   for 1 <= i <= N, SWC(i,:) contains the detail 
%   coefficients of level i and
%   SWC(N+1,:) contains the approximation coefficients of
%   level N.
%
%   [SWA,SWD] = SWT(...) computes approximations, SWA, and
%   details, SWD, stationary wavelet coefficients.
%   The vectors of coefficients are stored row-wise:
%   for 1 <= i <= N,
%   SWA(i,:) contains the approximation coefficients of level i,
%   SWD(i,:) contains the detail coefficients of level i.
%
%   See also DWT, WAVEDEC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Oct-95.
%   Copyright 1995-2020 The MathWorks, Inc.

%#codegen

% Check arguments.
narginchk(3,4);
nargoutchk(0,2);

coder.extrinsic('wavemngr','wfilters');

% There must be at least one varargin
temp_parseinputs = cell(1,nargin-2);
[temp_parseinputs{:}] = convertStringsToChars(varargin{:});

validateattributes(n, {'numeric'}, ...
    {'integer', 'positive', 'scalar'}, 'swt', 'N', 2);

validateattributes(x, {'numeric'}, {'vector', 'real'}, 'swt', 'X', 1);

% Use row vector.
x = x(:)';

s = length(x);
pow = 2^n;
if rem(s,pow)>0
    sOK = ceil(s/pow)*pow;
   coder.internal.error('Wavelet:moreMSGRF:SWT_length_MSG',n,s,sOK);
end

% Compute decomposition filters.
if nargin==3 && ischar(temp_parseinputs{1})
    % The wavelet type must be orthogonal or biorthogonal.
    wtype = coder.const(@wavemngr,'type',varargin{1});
    if ~any(wtype == [1 2])
       coder.internal.error('Wavelet:FunctionInput:OrthorBiorthWavelet');
    end
    [lo,hi] = coder.const(@wfilters,varargin{1},'d');
else
    if (nargin < 4)
       coder.internal.assert(~(nargin < 4),'Wavelet:FunctionInput:InvalidLoHiFilters');
    end
    lo = temp_parseinputs{1};
    hi = temp_parseinputs{2};

    validateattributes(lo,{'numeric'},...
        {'vector','finite','real'},'swt','Lo_D',3);
    validateattributes(hi,{'numeric'},...
        {'vector','finite','real'},'swt','Hi_D',4);

    % The filters must have an even length greater than 2.
    if (length(lo) < 2) || (length(hi) < 2) || ...
            isodd(length(lo)) || isodd(length(hi))
       coder.internal.error('Wavelet:FunctionInput:Invalid_Filt_Length');
    end
end

% Compute stationary wavelet coefficients.
evenoddVal = 0;
evenLEN    = 1;
swd = zeros(n,s);
swa = zeros(n,s);
temp_lo = lo;
temp_hi = hi;

coder.varsize('temp_lo',inf(1,2));
coder.varsize('temp_hi',inf(1,2));

for k = 1:n

    % Extension.
    lf = length(temp_lo);
    x  = wextend('1D','per',x,lf/2);

    % Decomposition.
    swd(k,:) = wkeep1(wconv1(x,temp_hi),s,lf+1);
    swa(k,:) = wkeep1(wconv1(x,temp_lo),s,lf+1);

    % upsample filters.
    temp_lo = dyadup(temp_lo,evenoddVal,evenLEN);
    temp_hi = dyadup(temp_hi,evenoddVal,evenLEN);

    % New value of x.
    x = swa(k,:);

end

if nargout==2
    varargout = {swa,swd};
else
    varargout{1} = [swd ; swa(n,:)];
end

