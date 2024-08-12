function a = appcoef(c,l,varargin)
%APPCOEF Extract 1-D approximation coefficients.
%   APPCOEF computes the approximation coefficients of a
%   one-dimensional signal.
%
%   A = APPCOEF(C,L,'wname',N) computes the approximation
%   coefficients at level N using the wavelet decomposition
%   structure [C,L] (see WAVEDEC).
%   'wname' is a character vector containing the wavelet name.
%   Level N must be an integer such that 0 <= N <= length(L)-2. 
%
%   A = APPCOEF(C,L,'wname') extracts the approximation
%   coefficients at the last level length(L)-2.
%
%   Instead of giving the wavelet name, you can give the filters.
%   For A = APPCOEF(C,L,Lo_R,Hi_R) or
%   A = APPCOEF(C,L,Lo_R,Hi_R,N),
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter.
%   
%   See also DETCOEF, WAVEDEC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2020 The MathWorks, Inc.

filterSingle = false;
% Check arguments.
if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end

narginchk(3,5)

validateattributes(c,{'numeric'},{'vector','nonempty'},'appcoef','C');
validateattributes(l,{'numeric'},...
    {'vector','integer','finite','nonempty','positive'},'appcoef','L');

%Check if c is a column vector. l will have the same orientation.
IsColumn = iscolumn(c);
% L is in order of coarsest to finest resolution.
if IsColumn
    c = c.';
    l = l.';
end

rmax = length(l);
% The bookkeeping vector has the number of resolution levels + 2 elements
% The number of coefficients in the coarsest wavelet details is repeated
% because of the approximation coefficients.
% The original signal length is included.
nmax = rmax-2;
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r');
    next = 2;
else
    if nargin < 4
        error(message('Wavelet:FunctionInput:InvalidLoHiFilters'));
    end
    Lo_R = varargin{1};
    Hi_R = varargin{2};
    filterSingle = isUnderlyingType(Lo_R,'single') && ...
        isUnderlyingType(Hi_R,'single');
    next = 3;
end
n = nmax;
if nargin >= (2+next)
    n = varargin{next};
end

validateattributes(n,{'numeric'},...
    {'scalar','integer','nonnegative','<=',nmax},'appcoef','N');

% Initialization. Find the approximation coefficients at the coarsest
% resolution.
a = c(1:l(1));

isSingle = isUnderlyingType(a,'single');
if isSingle && ~filterSingle
    Lo_R = cast(Lo_R,'single');
    Hi_R = cast(Hi_R,'single');
end
% Iterated reconstruction.
% The maximum reconstruction index is rmax+1 because the last element is
% the length of the input signal.
imax = rmax+1;
for p = nmax:-1:n+1
    d = detcoef(c,l,p);                % extract detail
    % Here we reverse the number of coefficients per resolution level
    a = idwt(a,d,Lo_R,Hi_R,l(imax-p));
end

if IsColumn
    a = a.';
end
