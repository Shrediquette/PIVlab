function [A,D] = dualtree3(x,varargin)
% Kingsbury Q-shift 3-D Dual-tree complex wavelet transform
%   [A,D] = DUALTREE3(X) returns the 3-D dual-tree complex wavelet
%   transform of X at the maximum level, floor(log2(min(size(X)))). X is a
%   real-valued 3-D array (M-by-N-by-P) where all three dimensions (M,N,P)
%   must be even and greater than or equal to 4. 
%   
%   By default, DUALTREE3 uses the near-symmetric biorthogonal wavelet
%   filter pair with lengths 5 (scaling filter) and 7 (wavelet filter) for
%   level 1 and the orthogonal Q-shift Hilbert wavelet filter pair of
%   length 10 for levels greater than or equal to 2. A is the matrix of
%   real-valued final-level scaling (lowpass) coefficients. D is a 1-by-L
%   cell array of wavelet coefficients, where L is the level of the
%   transform. There are 28 wavelet subbands in the 3-D dual-tree transform
%   at each level. The wavelet coefficients are complex-valued.
%
%   [A,D] = DUALTREE3(X,LEVEL) obtains the 3-D dual-tree transform down to
%   LEVEL. LEVEL is a positive integer greater than or equal to 2 and less
%   than or equal to floor(log2(min(size(X))).
%
%   [A,D] = DUALTREE3(...,'FilterLength',FLEN) uses the orthogonal Hilbert
%   Q-shift filter pair with length FLEN for levels two and higher. Valid
%   options for FLEN are 6, 10, 14, 16, and 18. If unspecified, FLEN
%   defaults to 10.
%
%   [A,D] = DUALTREE3(...,'LevelOneFilter',FAF) uses the biorthogonal
%   filter specified by the string or character array FAF, as the 
%   first-level analysis filter. Valid options for FAF are 'nearsym5_7'
%   ("nearsym5_7"), 'nearsym13_19', 'antonini', or 'legall'. If
%   unspecified, FAF defaults to 'nearsym5_7'.
%
%   [A,D] = DUALTREE3(...,'ExcludeL1') (or "ExcludeL1") excludes the
%   first-level wavelet (detail) coefficients. Excluding the first-level
%   wavelet coefficients can speed up the algorithm and saves memory. The
%   first-level wavelet coefficients are not computed using the Hilbert
%   wavelet filter pairs and do not exhibit the directional selectivity of
%   levels 2 and higher. The perfect reconstruction property of the
%   dual-tree wavelet transform holds only if the first-level wavelet
%   coefficients are included. If unspecified, the default is 'IncludeL1'
%   ("IncludeL1").
%
%   %Example:
%   %    Obtain the 3-D dual-tree transform of a sphere and invert the 
%   %    transform. Check for perfect reconstruction.  
%   load sphr;
%   [a,d] = dualtree3(sphr);
%   xrec = idualtree3(a,d);
%   max(abs(sphr(:)-xrec(:)))
%
%   See also IDUALTREE3, WAVEDEC3, WAVEREC3, DDDTREE2

%   Copyright 2016-2020 The MathWorks, Inc.

%   Kingsbury, N.G. "Complex wavelets for shift invariant analysis and
%   "filtering of signals", Journal of Applied and Computational Harmonic
%   Analysis, Vol. 10, No. 3, May 2001, pp. 234-253.
%
%   Chen, H. & Kingsbury, N.G. "Efficient registration of nonrigid 3-D
%   bodies", IEEE Transactions on Image Processing, Vol. 21, No. 1, Jan
%   2012, pp. 262-272.


% Check number of input and output arguments
narginchk(1,7);
nargoutchk(0,2);

% Ensure the input is numeric, real, and that it is three-dimensional
validateattributes(x,{'numeric'},{'real','nonempty','finite','ndims',3},...
    'DUALTREE3','X');

% Case x to double
x = double(x);

% Check that all the dimensions of x are even and every dimension is
% greater than or equal to 4
origsizedata = size(x);
if any(isodd(origsizedata)) || any(origsizedata < 4)
    error(message('Wavelet:FunctionInput:Invalid3DDTCWT'));
end

% Check for 'ExcludeLeve1Details' or "ExcludeLevel1Details"
validopts = ["ExcludeL1","IncludeL1"];
defaultopt = "IncludeL1";
[opt, varargin] = ...
    wavelet.internal.getmutexclopt(validopts,defaultopt,varargin);

% Parse the inputs
params = parseinputs(origsizedata,varargin{:});

% Obtain the first-level analysis filter and q-shift filters
[LoD,HiD] = qbiorthfilt(params.Faf);
[LoDa,LoDb,HiDa,HiDb] = qorthwavf(params.af);

level = params.level;

% First level filters
h0o = LoD;
h1o = HiD;

% Filters for levels >= 2
h0a = LoDa;
h1a = HiDa;

% Normalize analysis filters
hscale = 1 / norm(h0a,2);
% Tree A analysis filters
h0a = h0a.* hscale;
h1a = h1a.* hscale;

% Tree B analysis filters
h0b = LoDb.*hscale;
h1b = HiDb.*hscale;


% Allocate array for wavelet coefficients
D = cell(level,1);

% Level 1 filtering. We can omit the highest level
% details if needed
if strcmpi(opt,"ExcludeL1")
    
    A = level1NoHighpass(x,h0o);
    D{1} = [];
    
else
    [A,D] = level1Highpass(x,h0o,h1o);
end

% For levels two to level, we use the Qshift filters
for lev = 2:level    
    [A,yhout] = level2Analysis(A,h0a,h1a,h0b,h1b);
    D{lev} = yhout;
end


%------------------------------------------------------------------------
function y = columnFilter(x,h)
% Filter the columns of x with h. This function does not decimate the
% output.

% This determines the symmetric extension of the matrix
L = length(h);
M = fix(L/2);

x = wextend('ar','sym',x,M);
y = conv2(x,h(:),'valid');


%------------------------------------------------------------------------
function Z = OddEvenFilter(x,ha,hb)
% ha and hb are identical length (even) filters
[r,c] = size(x);
% Even and odd polyphase components of dual-tree filters
haOdd = ha(1:2:end);
haEven = ha(2:2:end);
hbOdd = hb(1:2:end);
hbEven = hb(2:2:end);
r2 = r/2;
Z = zeros(r2,c);
M = length(ha);
% Set up vector for indexing into the matrix
idx = 6:4:r+2*M-2;
matIdx = wextend('ar','sym',(1:r)',M);

% Now perform the filtering
if dot(ha,hb) > 0
    s1 = 1:2:r2;
    s2 = s1 + 1;
else
    s2 = 1:2:r2;
    s1 = s2 + 1;
end
Z(s1,:) = conv2(x(matIdx(idx-1),:),haOdd(:),'valid') + conv2(x(matIdx(idx-3),:),haEven(:),'valid');
Z(s2,:) = conv2(x(matIdx(idx),:),hbOdd(:),'valid') + conv2(x(matIdx(idx-2),:),hbEven(:),'valid');


%-------------------------------------------------------------------------
function A = level1NoHighpass(x,h0o)
% This function is called if the user specified "excludeL1"
sx = size(x);

% Filter the 3rd dimension first
for colidx = 1:sx(2)
    y = reshape(x(:,colidx,:),sx([1 3])).';
    x(:,colidx,:) = columnFilter(y,h0o).';
    
end

% Filter the rows and columns
for sliceidx = 1:sx(3)
    y = columnFilter(x(:,:,sliceidx).',h0o).';
    x(:,:,sliceidx) = columnFilter(y,h0o);
    
end

A = x;


%-------------------------------------------------------------------------
function [A,D] = level1Highpass(x,h0o,h1o)
% This function computes level wavelet coefficients

sx = size(x);
xtmp = zeros(2*sx);
sxtmp = size(xtmp);
sr = size(xtmp)/2;

% Note this has been extended to be twice the original input size
x1a = 1:sx(1);
x2a = 1:sx(2);
x3a = 1:sx(3);
x1b = sr(1)+1:sr(1)+sx(1);
x2b = sr(2)+1:sr(2)+sx(2);
x3b = sr(3)+1:sr(3)+sx(3);

s1a = 1:sr(1);
s2a = 1:sr(2);
s3a = 1:sr(3);
s1b = sr(1)+1:sxtmp(1);
s3b = sr(3)+1:sxtmp(3);
xtmp(s1a,s2a,s3a) = x;

for colidx = 1:sr(2)
    y = reshape(xtmp(s1a,colidx,x3a),sr([1 3])).';
    % Filter 3rd dimension first
    xtmp(s1a,colidx,s3a) = columnFilter(y,h0o).';
    xtmp(s1a,colidx,s3b) = columnFilter(y,h1o).';
end

% Filter the rows and columns
for sliceidx = 1:sxtmp(3)
    y1 = xtmp(x1a,x2a,sliceidx).';
    y2 = [columnFilter(y1,h0o);  columnFilter(y1,h1o)].';
    xtmp(s1a,:,sliceidx) = columnFilter(y2,h0o);
    xtmp(s1b,:,sliceidx) = columnFilter(y2,h1o);
end


% Note in listing the subbands we are filtering along the column dimension
% first, then row, then slice

D{1}= cat(4,cube2complex(xtmp(x1a,x2b,x3a)),...     % LHL
    cube2complex(xtmp(x1b,x2a,x3a)),...             % HLL
    cube2complex(xtmp(x1b,x2b,x3a)),...             % HHL
    cube2complex(xtmp(x1a,x2a,x3b)),...             % LLH
    cube2complex(xtmp(x1a,x2b,x3b)),...             % LHH
    cube2complex(xtmp(x1b,x2a,x3b)),...             % HLH
    cube2complex(xtmp(x1b,x2b,x3b)));               % HHH

A = xtmp(s1a,s2a,s3a);                              % LLL




%-------------------------------------------------------------------
function z = cube2complex(x)
% Form the complex-valued subbands
j2 = 1/2*[1 1j];
A = x(2:2:end,2:2:end,2:2:end);
B = x(2:2:end,2:2:end,1:2:end);
C = x(2:2:end,1:2:end,2:2:end);
D = x(2:2:end,1:2:end,1:2:end);
E = x(1:2:end,2:2:end,2:2:end);
F = x(1:2:end,2:2:end,1:2:end);
G = x(1:2:end,1:2:end,2:2:end);
H = x(1:2:end,1:2:end,1:2:end);


P = (A-G-D-F)*j2(1)+(B-H+C+E)*j2(2);
Q = (A-G+D+F)*j2(1)+(-B+H+C+E)*j2(2);
R = (A+G+D-F)*j2(1)+(B+H-C+E)*j2(2);
S = (A+G-D+F)*j2(1)+(-B-H-C+E)*j2(2);

z = cat(4,P,Q,R,S);

%-------------------------------------------------------------------------
function [A,D] = level2Analysis(x,h0a,h1a,h0b,h1b)
% This the analysis bank for levels >= 2, here we require the four qshift
% filters
% First we want to guarantee that the input LLL image is divisible by
% four in each dimension

LLLsize = size(x);
if any(rem(LLLsize,4))
    x = paddata(x);
    % Now get size of extended x
    LLLsize = size(x);
end

% These will be integers
sr = LLLsize/2;
% Set up index vectors for filtering
s1a = 1:sr(1);
s2a = 1:sr(2);
s3a = 1:sr(3);
s1b = s1a+LLLsize(1)/2;
s2b = s2a+LLLsize(2)/2;
s3b = s3a+LLLsize(3)/2;


%
for colidx = 1:LLLsize(2)
    y = reshape(x(:,colidx,:),LLLsize([1 3])).';
    % Do we need to switch the order of the filters?
    x(:,colidx,s3a) = OddEvenFilter(y,h0b,h0a).';
    x(:,colidx,s3b) = OddEvenFilter(y,h1b,h1a).';
end

for colidx = 1:LLLsize(3)
    y = x(:,:,colidx).';
    % Qshift filtering on the rows
    y2 = [OddEvenFilter(y,h0b,h0a);  OddEvenFilter(y,h1b,h1a)].';
    % Qshift filtering on the columns.
    x(s1a,:,colidx) = OddEvenFilter(y2,h0b,h0a);
    x(s1b,:,colidx) = OddEvenFilter(y2,h1b,h1a);
end

D = cat(4,cube2complex(x(s1a,s2b,s3a)),...      % LHL
    cube2complex(x(s1b,s2a,s3a)),...            % HLL
    cube2complex(x(s1b,s2b,s3a)),...            % HHL
    cube2complex(x(s1a,s2a,s3b)),...            % LLH
    cube2complex(x(s1a,s2b,s3b)),...            % LHH
    cube2complex(x(s1b,s2a,s3b)),...            % HLH
    cube2complex(x(s1b,s2b,s3b)));              % HHH

% This subband returned as a matrix because only the coarsest
% resolution is retained.
A = x(s1a,s2a,s3a);


%-------------------------------------------------------------------------
function x = paddata(x)
% Pad data if necessary
sx = size(x);
if rem(sx(1),4)
    x = cat(1,x(1,:,:),x,x(end,:,:));
end
if rem(sx(2),4)
    x = cat(2,x(:,1,:),x,x(:,end,:));
end
if rem(sx(3),4)
    x = cat(3,x(:,:,3),x,x(:,:,end));
end

%-------------------------------------------------------------------------
function params = parseinputs(origsizedata,varargin)
% Set up defaults for the first-level biorthogonal filter and subsequent
% level orthogonal Hilbert filters
params.Faf = "nearsym5_7";
validFaf = ["nearsym5_7", "nearsym13_19", "antonini","legall"];
validaf = [6,10,14,16,18];
params.af = 10;
qfiltlen = 0;
maxlev = floor(log2(min(origsizedata)));
params.level = maxlev;
if isempty(varargin)
    return;
end

strvar = cellfun(@(x)ischar(x) || (isstring(x) && isscalar(x)),varargin);
if any(strvar)
    stringvars = string(varargin(strvar));
    qfiltlen = startsWith(stringvars,'F','IgnoreCase',true);
end

% See if a level is specified
levelidx = cellfun(@(x) isscalar(x) && ~ischar(x) && ~isstring(x),varargin);


if any(levelidx) && nnz(levelidx)==1 && ~any(qfiltlen)
    params.level = varargin{levelidx};
    validateattributes(params.level,{'numeric'},...
        {'integer','scalar','<=',maxlev,'>=',2},'DUALTREE3','LEVEL');
    varargin(levelidx) = [];
    if isempty(varargin)
        return;
    end
elseif nnz(levelidx) == 2 && nnz(qfiltlen) == 1
    L = find(levelidx,1,'first');
    params.level = varargin{L};
    validateattributes(params.level,{'numeric'},...
        {'integer','scalar','<=',maxlev,'>=',2},'DUALTREE3','LEVEL');
    varargin(L) = [];
    if isempty(varargin)
        return;
    end
end

p = inputParser;
addParameter(p,"LevelOneFilter",params.Faf);
addParameter(p,"FilterLength",params.af);
parse(p,varargin{:});
params.Faf = p.Results.LevelOneFilter;
params.Faf = validatestring(params.Faf,validFaf);
params.af = p.Results.FilterLength;
if ~ismember(p.Results.FilterLength,validaf)
    error(message('Wavelet:dualtree:UnsupportedQ'));
end












