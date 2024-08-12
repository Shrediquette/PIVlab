function xrec = idualtree3(A,D,varargin)
% 3-D Inverse Kingsbury Q-shift complex dual-tree wavelet transform
%   XREC = IDUALTREE3(A,D) returns the inverse 3-D dual-tree complex
%   wavelet transform of the final-level approximation coefficients, A, and
%   cell array of wavelet coefficients, D. A and D are outputs of
%   DUALTREE3. IDUALTREE3 uses the orthogonal Q-shift filter of length 10
%   and near symmetric biorthogonal filter with lengths 7 (scaling
%   synthesis filter) and 5 (wavelet synthesis filter) in the
%   reconstruction.
% 
%   XREC = IDUALTREE3(...,'FilterLength',FLEN) uses the Q-shift Hilbert
%   synthesis filter pair of length FLEN. Valid options for FLEN are 6, 10,
%   14, 16, or 18. If unspecified, FLEN defaults to 10. The synthesis
%   filter length used in IDUALTREE3 must match the analysis filter length
%   in DUALTREE3.
%
%   XREC = IDUALTREE3(...,'LevelOneFilter',FSF) uses the biorthogonal
%   filter, FSF, as the first-level synthesis filter. FSF is a character
%   array or string. Valid options for FSF are 'nearsym5_7' ("nearsym5_7"),
%   'nearsym13_19', 'antonini', or 'legall'. If unspecified, FSF defaults
%   to 'nearsym5_7'. The first-level synthesis filters must match the 
%   first-level analysis filters used in IDUALTREE3.
%
%   XREC = IDUALTREE3(...,'OriginalDataSize',ORIGSIZE) uses the original
%   data size to adjust the size of XREC if the 'excludeL1' option was used
%   in DUALTREE3. ORIGSIZE is a three-element vector of even integers that
%   must match the size of the original input to DUALTREE3. In some cases,
%   the reconstructed data size may differ from the original input data
%   size if the first-level wavelet coefficients are not available. This
%   argument is ignored if the dual-tree transform did not use the
%   'excludeL1' option.
%
%   % Example
%   %    Obtain the 3-D dual-tree transform of sphere and invert the 
%   %    transform. Check for perfect reconstruction.
%   load sphr;
%   [a,d] = dualtree3(sphr);
%   xrec = idualtree3(a,d);
%   max(abs(sphr(:)-xrec(:)))
%
%   See also DUALTREE3, WAVEDEC3, WAVEREC3, DDDTREE2

%   Copyright 2016-2020 The MathWorks, Inc.

%   Kingsbury, N.G. "Complex wavelets for shift invariant analysis and
%   filtering of signals", Journal of Applied and Computational Harmonic
%   Analysis, Vol. 10, No. 3, May 2001, pp. 234-253.
%
%   Chen, H. & Kingsbury, N.G. "Efficient registration of nonrigid 3-D
%   bodies", IEEE Transactions on Image Processing, Vol. 21, No. 1, Jan
%   2012, pp. 262-272.

% Check number of input and output arguments
narginchk(2,8);
nargoutchk(0,1);

% A should be a 3-D matrix output from dualtree3
validateattributes(A,{'numeric'},{'real','nonempty','finite','ndims',3},...
    'IDUALTREE3','A');
% D should be a cell array of length at least two
validateattributes(D,{'cell'},{'nonempty'},'IDUALTREE3','D');

% Obtain the level of the transform
level = length(D);

if level < 2
    error(message('Wavelet:FunctionInput:TwoElem'));
end

% Parse the optional inputs in varargin
params = parseinputs(varargin{:});
origsize = params.origsize;
% Get the level 1 filters
[~,~,LoR,HiR] = qbiorthfilt(params.Fsf);
% Get the q-shift filter
[~,~,~,~,LoRa,LoRb,HiRa,HiRb] = qorthwavf(params.sf);

% First level filters
g0o = LoR;
g1o = HiR;

% Levels >= 2
g0a = LoRa;
g1a = HiRa;

% Normalize analysis filters
gscale = 1 / norm(g0a,2);
% Tree A synthesis filters
g0a = g0a.* gscale;
g1a = g1a.* gscale;

% Tree B synthesis filters
g0b = LoRb;
g1b = HiRb;
g0b = g0b.*gscale;
g1b = g1b.*gscale;


if level>=2
    while level > 1
        if ~isempty(D{level-1})
            syh = size(D{level-1});
            prev_level_size = syh(1:3);
        else
            syh = size(D{level});
            prev_level_size = syh(1:3).*2;
        end
        A = level2synthesis(A,D{level},g0a,g0b,g1a,g1b,prev_level_size);
        level = level-1;
    end
end

if level == 1 && isempty(D{1})
    A = level1SynthNoHighpass(A,g0o,origsize);
end

if level == 1 && ~isempty(D{1})
    A = level1SynthHighpass(A,D{1},g0o,g1o);
end

xrec = A;

%------------------------------------------------------------------------
function yrec = invcolumnfilter(x,ha,hb)
[r,c] = size(x);
yrec = zeros(2*r,c);
filtlen = length(ha);
% The following will just work with even length filters
L = fix(filtlen/2);
matIdx = wextend('ar','sym',(1:r)',L);
% Polyphase components of the filters
hao = ha(1:2:filtlen);
hae = ha(2:2:filtlen);
hbo = hb(1:2:filtlen);
hbe = hb(2:2:filtlen);
s = 1:4:(r*2);
if iseven(L)
    
    t = 4:2:(r+filtlen);
    if dot(ha,hb) > 0
        ta = t; tb = t - 1;
    else
        ta = t - 1; tb = t;
    end
    yrec(s,:)   = conv2(x(matIdx(tb-2),:),hae(:),'valid');
    yrec(s+1,:) = conv2(x(matIdx(ta-2),:),hbe(:),'valid');
    yrec(s+2,:) = conv2(x(matIdx(tb),:),hao(:),'valid');
    yrec(s+3,:) = conv2(x(matIdx(ta),:),hbo(:),'valid');
    
    
else
    
    t = 3:2:(r+filtlen-1);
    if dot(ha,hb) > 0
        ta = t; tb = t - 1;
    else
        ta = t - 1; tb = t;
    end
        
    s = 1:4:(r*2);
    
    yrec(s,:)   = conv2(x(matIdx(tb),:),hao(:),'valid');
    yrec(s+1,:) = conv2(x(matIdx(ta),:),hbo(:),'valid');
    yrec(s+2,:) = conv2(x(matIdx(tb),:),hae(:),'valid');
    yrec(s+3,:) = conv2(x(matIdx(ta),:),hbe(:),'valid');
    
end

%-------------------------------------------------------------------------
function y = complex2cube(z)

sz = size(z);
P = z(:,:,:,1);
Q = z(:,:,:,2);
R = z(:,:,:,3);
S = z(:,:,:,4);

Pr = real(P);
Pi = imag(P);
Qr = real(Q);
Qi = imag(Q);
Rr = real(R);
Ri = imag(R);
Sr = real(S);
Si = imag(S);
% Allocate array for result
y = zeros(2*sz(1:3));

% Combining real parts
y(2:2:end,2:2:end,2:2:end) = (Pr+Qr+Rr+Sr);
y(1:2:end,1:2:end,2:2:end) = (-Pr-Qr+Rr+Sr);
y(2:2:end,1:2:end,1:2:end) = (-Pr+Qr+Rr-Sr);
y(1:2:end,2:2:end,1:2:end) = (-Pr+Qr-Rr+Sr);

% Complex parts
y(2:2:end,2:2:end,1:2:end) = (Pi-Qi+Ri-Si);
y(1:2:end,1:2:end,1:2:end) = (-Pi+Qi+Ri-Si);
y(2:2:end,1:2:end,2:2:end) = (Pi+Qi-Ri-Si);
y(1:2:end,2:2:end,2:2:end) = (Pi+Qi+Ri+Si);
y = y.*1/2;

%-------------------------------------------------------------------------
function yl = level2synthesis(yl,yh,g0a,g0b,g1a,g1b,prev_level_size)
% From this we will only return the scaling coefficients at the next finer
% resolution level
LLLsize = size(yl);
y = zeros(2*LLLsize);
sy = size(y);
s1a = 1:sy(1)/2;
s2a = 1:sy(2)/2;
s3a = 1:sy(3)/2;
s1b = s1a+sy(1)/2;
s2b = s2a+sy(2)/2;
s3b = s3a+sy(3)/2;

% Fill y array for synthesis
y(s1a,s2a,s3a) = yl;
y(s1a,s2b,s3a) = complex2cube(yh(:,:,:,1:4));
y(s1b,s2a,s3a) = complex2cube(yh(:,:,:,5:8));
y(s1b,s2b,s3a) = complex2cube(yh(:,:,:,9:12));
y(s1a,s2a,s3b) = complex2cube(yh(:,:,:,13:16));
y(s1a,s2b,s3b) = complex2cube(yh(:,:,:,17:20));
y(s1b,s2a,s3b) = complex2cube(yh(:,:,:,21:24));
y(s1b,s2b,s3b) = complex2cube(yh(:,:,:,25:28));


for colidx = 1:sy(3)
    ytmp = invcolumnfilter(y(:,s2a,colidx).',g0b,g0a)+invcolumnfilter(y(:,s2b,colidx).',g1b,g1a);
    y(:,:,colidx) = invcolumnfilter(ytmp(:,s1a).',g0b,g0a)+invcolumnfilter(ytmp(:,s1b).',g1b,g1a);
end

for colidx = 1:sy(2)
    ytmp = squeeze(y(:,colidx,:)).';
    y(:,colidx,:) = (invcolumnfilter(ytmp(s3a,:),g0b,g0a)+invcolumnfilter(ytmp(s3b,:),g1b,g1a)).';
end

yl = y;

% Now check if the size of the previous level is exactly twice the size
% of the current level. If it is exactly twice the size, the data was not
% extended at the previous level, if it is not, we have to remove the
% added row, column, and page dimensions.

size_curr_level = size(yh);
size_curr_level = size_curr_level(1:3);

if prev_level_size(1) ~= 2*size_curr_level(1)
    yl = yl(2:end-1,:,:);
end

if  prev_level_size(2) ~= 2*size_curr_level(2)
    yl = yl(:,2:end-1,:);
end

if prev_level_size(3) ~= 2*size_curr_level(3)
    yl = yl(:,:,2:end-1);
end

%------------------------------------------------------------------------
function yl = level1SynthNoHighpass(yl,g0o,origsize)
% We use no highpass filter here
LLLsize = size(yl);
s1 = 1:LLLsize(1);
s2 = 1:LLLsize(2);
s3 = 1:LLLsize(3);

for colidx = 1:LLLsize(3)
    y = columnFilter(yl(s1,s2,colidx).',g0o);
    yl(s1,s2,colidx) = columnFilter(y(:,s1).',g0o);
end

for colidx = 1:LLLsize(2)
   y  = reshape(yl(s1,colidx,s3),LLLsize([1 3])).';
   yl(s1,colidx,s3) = columnFilter(y(s3,:),g0o).';
end 

% If the user specifies "excludeL1" at the input, it is possible that
% the output data size may not be correct. To correct for that, the user
% can provide the original data size as an input.

if ~isempty(origsize)
    
size_curr_level = size(yl);

if origsize(1) ~= size_curr_level(1)
    yl = yl(2:end-1,:,:);
end

if  origsize(2) ~= size_curr_level(2)
    yl = yl(:,2:end-1,:);
end

if origsize(3) ~= size_curr_level(3)
    yl = yl(:,:,2:end-1);
end
end

%------------------------------------------------------------------------
function y = columnFilter(x,h)
% Filter the columns of x with h. This function does not decimate the
% output

% This determines the symmetric extension of the matrix
L = length(h);
M = fix(L/2);

x = wextend('ar','sym',x,M);
y = conv2(x,h(:),'valid');


%-------------------------------------------------------------------------
function yl = level1SynthHighpass(yl,yh,g0o,g1o)

LLLsize = size(yl);
y = zeros(2*LLLsize);
sy = size(y);

s1a = 1:sy(1)/2;
s2a = 1:sy(2)/2;
s3a = 1:sy(3)/2;


x1a = 1:LLLsize(1);
x2a = 1:LLLsize(2);
x3a = 1:LLLsize(3);
x1b = x1a+LLLsize(1);
x2b = x2a+LLLsize(2);
x3b = x3a+LLLsize(3);

% Fill y array for synthesis
y(s1a,s2a,s3a) = yl;
y(x1a,x2b,x3a) = complex2cube(yh(:,:,:,1:4));
y(x1b,x2a,x3a) = complex2cube(yh(:,:,:,5:8));
y(x1b,x2b,x3a) = complex2cube(yh(:,:,:,9:12));
y(x1a,x2a,x3b) = complex2cube(yh(:,:,:,13:16));
y(x1a,x2b,x3b) = complex2cube(yh(:,:,:,17:20));
y(x1b,x2a,x3b) = complex2cube(yh(:,:,:,21:24));
y(x1b,x2b,x3b) = complex2cube(yh(:,:,:,25:28));

for colidx = 1:sy(3)
    ytmp = columnFilter(y(:,x2a,colidx).',g0o)+columnFilter(y(:,x2b,colidx).',g1o);
    y(s1a,s2a,colidx) = columnFilter(ytmp(:,x1a).',g0o)+columnFilter(ytmp(:,x1b).',g1o);
end

for colidx = 1:LLLsize(2)
    ytmp = squeeze(y(s1a,colidx,:)).';
    y(s1a,colidx,s3a) = (columnFilter(ytmp(x3a,:),g0o)+columnFilter(ytmp(x3b,:),g1o)).';
end

yl = y(s1a,s2a,s3a);

%-------------------------------------------------------------------------
function params = parseinputs(varargin)
% Set up defaults for the first-level biorthogonal filter and subsequent
% level orthogonal Hilbert filters

params.Fsf = "nearsym5_7";
validFsf = ["nearsym5_7", "nearsym13_19", "antonini", "legall"];
validsf = [6,10,14,16,18];
params.sf = 10;
params.origsize = [];

if isempty(varargin)
    return;
end

p = inputParser;
p.KeepUnmatched = true;
addParameter(p,"LevelOneFilter",params.Fsf);
validatestring(params.Fsf,validFsf);
addParameter(p,"FilterLength",params.sf);
validateorigsize = @(x)(isempty(x) || ...
    (length(x) == 3 && all(iseven(x))));
addParameter(p,"OriginalDataSize",params.origsize);
parse(p,varargin{:});
params.origsize = p.Results.OriginalDataSize;
params.Fsf = p.Results.LevelOneFilter;
params.Fsf = validatestring(params.Fsf,validFsf);
validsize = validateorigsize(params.origsize);
params.sf = p.Results.FilterLength;
if ~ismember(p.Results.FilterLength,validsf)
    error(message('Wavelet:dualtree:UnsupportedQ'));
end
if ~validsize
    error(message('Wavelet:FunctionInput:InvalidOrig3DDataSize'))
end

    












