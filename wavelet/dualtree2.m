function [A,D,Ascale] = dualtree2(x,varargin)
% Kingsbury Q-shift 2-D Dual-tree complex wavelet transform
%   [A,D] = dualtree2(X) returns the 2-D dual-tree complex wavelet
%   transform (DTCWT) of X using Kingsbury Q-shift filters. X is a
%   real-valued H-by-W-by-C-by-N matrix where H is the height or row
%   dimension, W is the width or column dimension, C is the number of
%   channels, and N is the number of images. X must have at least 2 samples
%   in each of the row and column dimensions.
%
%   The DTCWT is obtained by default down to level floor(log2(min([H W])))
%   where H and W refer to the height (row dimension) and width (column
%   dimension) respectively. If any of the row or column dimensions of X
%   are odd, X is extended along that dimension by reflecting around the
%   last row or column.
%
%   By default, DUALTREE2 uses the near-symmetric biorthogonal wavelet
%   filter pair with lengths 5 (scaling filter) and 7 (wavelet filter) for
%   level 1 and the orthogonal Q-shift Hilbert wavelet filter pair of
%   length 10 for levels greater than or equal to 2. A is the matrix of
%   real-valued final-level scaling (lowpass) coefficients. D is a LEV-by-1
%   cell array of complex-valued wavelet coefficients, where LEV is the
%   level of the transform. For each element of D there are six wavelet
%   subbands.
%  
%   [A,D] = dualtree2(X,'Level',LEV) obtains the 2-D dual-tree transform
%   down to level, LEV. LEV is a positive integer less than or equal to
%   floor(log2(min([H W]))) where H and W refer to the height (row
%   dimension) and width (column dimension) respectively.
%
%   [A,D] = dualtree2(...,'LevelOneFilter',FAF) uses the biorthogonal
%   filter specified by the string or character array, FAF, as the 
%   first-level analysis filter. Valid options for FAF are 'nearsym5_7',
%   'nearsym13_19', 'antonini', or 'legall'. If unspecified, FAF defaults
%   to 'nearsym5_7'.
%  
%   [A,D] = dualtree2(...,'FilterLength',FLEN) uses the orthogonal Hilbert
%   Q-shift filter pair with length FLEN for levels two and higher. Valid
%   options for FLEN are 6, 10, 14, 16, and 18. If unspecified, FLEN
%   defaults to 10.
%
%   [A,D,Ascale] = dualtree2(...) returns the scaling (lowpass)
%   coefficients at each level.
%  
%   %Example: Obtain the dual-tree complex wavelet transform of an image
%   % down to 3 levels of resolution.
%   load woman;
%   [A,D] = dualtree2(X,'Level',3);
%
%   %Example: Demonstrate the directional sensitivity of the dual-tree 
%   %   wavelet coefficients at level two for an image of a disk. Note that
%   %   subbands (1,6), (2,5), and (3,4) form complementary pairs in terms
%   %   of their directional sensitivity.
%   ImageWidth = 256;
%   ImageHeight =  256; 
%   Radius = 128;   
%   [X, Y] = meshgrid(1:ImageWidth, 1:ImageHeight);
%   CircleImage = zeros(ImageHeight,ImageWidth);
%   CircleImage((X - ImageWidth/2).^2 + (Y - ImageHeight/2).^2 <= Radius^2) = 1;
%   [A,D] = dualtree2(CircleImage);
%   d2 = abs(D{2});
%   for kk = 1:6
%       subplot(2,3,kk)
%       imagesc(d2(:,:,kk))
%       axis xy
%       title(['Subband Image ' num2str(kk)]);
%   end
%
%   See also idualtree2, dualtree, qorthwavf, qbiorthfilt

%   Kingsbury, N.G. (2001) Complex wavelets for shift invariant analysis 
%   and filtering of signals, Journal of Applied and Computational Harmonic
%   Analysis, vol 10, no. 3, pp. 234-253.

% Copyright 2019-2020 The MathWorks, Inc.
 

%#codegen

% Works only on real-valued input signals
validateattributes(x,{'numeric'},{'real','finite','nonempty'},'dualtree2','X');
[Nr,Nc,Nchan,NIm] = size(x);
coder.internal.errorIf(any([Nr Nc] == 1),'Wavelet:dualtree:iminput');
   
if ~strcmpi(class(x),'double')
    % cast to single for datatypes that are not double
    xtmp = single(x);
else 
    xtmp = x;
end

coder.internal.prefer_const(varargin);
params = parseinputs(Nr,Nc,varargin{:});

% Get the filters. For the first-level analysis filters we just get LoD and
% HiD. This is a biorthogonal filter
[LoD,HiD] = qbiorthfilt(params.biorth);
[LoDa,LoDb,HiDa,HiDb] = qorthwavf(params.qlen);
% 1st level filters
LoD = cast(LoD,'like',xtmp);
HiD = cast(HiD,'like',xtmp);
% Subsequent level filters. This is a q-shift filter
LoDa = cast(LoDa,'like',xtmp);
LoDb = cast(LoDb,'like',xtmp);
HiDa = cast(HiDa,'like',xtmp);
HiDb = cast(HiDb,'like',xtmp);


% If the image has an odd length row or column dimension, pad the image by
tf = signalwavelet.internal.isodd([Nr Nc]);
% We have to handle the odd case, the following lines are needed for code
% generation because we are changing the size of the array.

coder.varsize('tmpx');
if ~tf(1) && ~tf(2)
    tmpx = xtmp;
elseif tf(1) && ~tf(2)
    tmpx = coder.nullcopy(zeros([Nr+1 Nc Nchan NIm],'like',xtmp));
    tmpx(1:Nr,:,:,:) = xtmp;
      
elseif ~tf(1) && tf(2)
      tmpx = coder.nullcopy(zeros([Nr Nc+1 Nchan NIm],'like',xtmp));
      tmpx(:,1:Nc,:,:) = xtmp;
    
else
    tmpx = coder.nullcopy(zeros([Nr+1 Nc+1 Nchan NIm],'like',xtmp));
    tmpx(1:Nr,1:Nc,:,:) = xtmp;
    
end

if tf(1)
       % Copy next to last row of tmpx into the last row
       tmpx(Nr+1,:,:,:) = tmpx(Nr-1,:,:,:);

end
 
if tf(2)
       % Copy next to last column of tmpx into last column
       tmpx(:,Nc+1,:,:) = tmpx(:,Nc-1,:,:);

      
end

% Initial lowpass and highpass filter outputs for the first scale using the
% biorthogonal wavelet. These are permutation indices in order to perform
% column and row filtering.
permidx = [2 1 3 4];
 
% Obtain initial filtering along columns of x. This uses a biorthogonal
% filter with an odd number of taps. Note as opposed to the Selesnick
% algorithm, we use here the same lowpass and highpass filters in both
% trees.
Lo = wavelet.internal.Batchcolfilter(tmpx,LoD);
Hi = wavelet.internal.Batchcolfilter(tmpx,HiD);
% Permute for row filtering 
Lo = permute(Lo,permidx);
Hi = permute(Hi,permidx);

% LL subband obtained by filtering the rows, then we permute back. The LL
% subband should be declared variable-sized for code generation
coder.varsize('LoLo');
LoLo = wavelet.internal.Batchcolfilter(Lo,LoD);
% Permute back
LoLo = ipermute(LoLo,permidx);

szLoLo = size(LoLo);

dfiltSZ = [szLoLo(1:2)/2 Nchan NIm 6];
if ~coder.target('MATLAB')
    % Allocate heterogenous arrays for code generation. Not needed for pure
    % MATLAB path
    [szD,szA] = wavelet.internal.dtcwt2size(Nr,Nc,Nchan,NIm,params.level);
    % Allocate cell arrays for codegen
    % coder.varsize('tmpD',[ceil(Nr/2) ceil(Nc/2) Nchan NIm 6],[1 1 1 1 0]) ;
    % tmpD = coder.nullcopy(complex(zeros(dfiltSZ,'like',x)));
    % Dfilt = repmat({tmpD},params.level,1);
    Dfilt = assgnq2c(xtmp,szD,params.level);
    Dperm = assgnq2c(xtmp,szD,params.level);
    %Dperm = assgnq2c(x,dfiltSZ,params.level);
    % D = assgnq2c(x,dfiltSZ,params.level);
    D = assgnq2c(xtmp,szD,params.level);
    Ascale = assgnscale(xtmp,szA,params.level);
else
    % MATLAB branch
    Dfilt = cell(params.level,1);
    Dperm = cell(params.level,1);
    D = cell(params.level,1);
    Ascale = cell(params.level,1);
end

% HL subband
HL = quad2Complex(ipermute(wavelet.internal.Batchcolfilter(Hi,LoD),permidx));
HL = reshape(HL,[dfiltSZ(1:4) 2]);
Dfilt{1}(:,:,:,:,[1 6]) = HL;
% LH subband
LH = quad2Complex(ipermute(wavelet.internal.Batchcolfilter(Lo,HiD),permidx));
LH = reshape(LH,[dfiltSZ(1:4) 2]);
Dfilt{1}(:,:,:,:,[3 4]) = LH;
% HH subband
HH = quad2Complex(ipermute(wavelet.internal.Batchcolfilter(Hi,HiD),permidx));
HH = reshape(HH,[dfiltSZ(1:4) 2]);
Dfilt{1}(:,:,:,:,[2 5]) = HH;


if nargout > 2
    Ascale{1} = LoLo;
end

% Obtain DTCWT for levels > 1
for kk = 2:params.level
    % Check size of LoLo in row and column dimensions
    [Nrl,Ncl,~,~] = size(LoLo);
    % If the number of elements in the row or column size of the image 
    % is not divisible by 4, we need to extend.
    % Since we are only allowing even-length row and column dimension inputs.
    % We will achieve mod(L,4) = 0 by just adding two rows for mod(Lo,4) = 2
    if mod(Nrl,4) ~= 0
        % Following should work for grayscale and RGB
        LoLo = [LoLo(1,:,:,:) ; LoLo ; LoLo(Nrl,:,:,:)];
    end
    
    if mod(Ncl,4) ~= 0
        LoLo = [LoLo(:,1,:,:) LoLo LoLo(:,Ncl,:,:)]; %#ok<*AGROW>
    end
    
    % Q-shift filters on rows
    % Filter and permute. Internally we use a polyphase implementation
    % and filters from both trees.
    Lotmp = permute(wavelet.internal.BatchEvenOddFilter(LoLo,LoDb,LoDa),permidx);
    Hitmp = permute(wavelet.internal.BatchEvenOddFilter(LoLo,HiDb,HiDa),permidx);
    
    
    % Obtain lowpass
    % Filter and permute back
    LoLo = ipermute(wavelet.internal.BatchEvenOddFilter(Lotmp,LoDb,LoDa),permidx);
    szLoLo =  size(LoLo);     
    % Obtain wavelet subbands
    % HL
    HL = quad2Complex(ipermute(wavelet.internal.BatchEvenOddFilter(Hitmp,LoDb,LoDa),permidx));
    HL = reshape(HL,[szLoLo(1:2)/2 Nchan NIm 2]);
    Dfilt{kk}(:,:,:,:,[1 6]) = HL;
    % LH 
    LH = quad2Complex(ipermute(wavelet.internal.BatchEvenOddFilter(Lotmp,HiDb,HiDa),permidx));
    LH = reshape(LH,[szLoLo(1:2)/2 Nchan NIm 2]);
    Dfilt{kk}(:,:,:,:,[3 4]) = LH;
    % HH
    HH = quad2Complex(ipermute(wavelet.internal.BatchEvenOddFilter(Hitmp,HiDb,HiDa),permidx));
    HH = reshape(HH,[szLoLo(1:2)/2 Nchan NIm 2]);
    Dfilt{kk}(:,:,:,:,[2 5]) = HH;
       
    
    
    if nargout > 2
        Ascale{kk} = LoLo;
    end
    

end


swapSBNumIM = [1 2 3 5 4];

% Code generation does not support cellfun()
if coder.target('MATLAB')
    Dperm = cellfun(@(x)permute(x,swapSBNumIM),Dfilt,'uni',false);
    
else
    % Code generation branch
    for kk = 1:numel(Dfilt)
        Dperm{kk} = permute(Dfilt{kk},swapSBNumIM);
    end
    
end
% If the number of channels is 1 and the number of images is 1, 
% squeeze out that extra dimension for output
if Nchan == 1 && NIm == 1
    for kk = 1:numel(Dperm)
        Dsize = size(Dperm{kk});
        D{kk} = reshape(Dperm{kk},[Dsize(1) Dsize(2) Dsize(4)]);
    end
else
    D = Dperm;
end
A = LoLo;

%-------------------------------------------------------------------------
function Z = quad2Complex(y)

Sy = size(y);
Sz = size(y);
Sz(1:2) = Sz(1:2)./2;
Nd = numel(Sy);
Nr = Sy(1);
Nc = Sy(2);

% For creating complex-valued outputs only consider the size of the image
% along the first two dimensions
y = reshape(y,Nr,Nc,[]);
rowidx = 1:2:Nr;
colidx = 1:2:Nc;
P = y(rowidx,colidx,:)+1j*y(rowidx,colidx+1,:);
Q = y(rowidx+1,colidx+1,:)-1j*y(rowidx+1,colidx,:);
P = P./sqrt(2);
Q = Q./sqrt(2);
P = reshape(P,Sz);
Q = reshape(Q,Sz);
Z = cat(Nd+1,P-Q,P+Q);

%--------------------------------------------------------------------------
function params = parseinputs(Nr,Nc,varargin)
% Set default level
defaultLevel = fix(log2(min([Nr Nc])));
validLevel = @(x)validateattributes(x,{'numeric'},{'positive','integer',...
    '>=',1,'<=',defaultLevel});
validBiorth = {'nearsym5_7','nearsym13_19','antonini','legall'};
defaultBiorth = 'nearsym5_7';
% Default Q-shift filter length 
defaultQlen = 10;
validQ = @(x)ismember(x,[6 10 14 16 18]);


if coder.target('MATLAB')
    p = inputParser;
    addParameter(p,'Level',defaultLevel);
    addParameter(p,'LevelOneFilter',defaultBiorth);
    addParameter(p,'FilterLength',defaultQlen);
    p.parse(varargin{:});
    params.level = p.Results.Level;
    params.biorth = p.Results.LevelOneFilter;
    params.qlen = p.Results.FilterLength;  
    
else
    parms = struct('Level',uint32(0),...
        'LevelOneFilter',uint32(0),...
        'FilterLength',uint32(0));
    popts = struct('CaseSensitivity',false, ...
        'PartialMatching',true);
    
    pstruct = coder.internal.parseParameterInputs(parms,popts,varargin{:});
    params.level = ...
        coder.internal.getParameterValue(pstruct.Level,defaultLevel,varargin{:});
    params.biorth = ...
        coder.internal.getParameterValue(pstruct.LevelOneFilter,defaultBiorth,varargin{:});
    params.qlen = ...
        coder.internal.getParameterValue(pstruct.FilterLength,defaultQlen,varargin{:});
    
    
    
end

% Validate inputs
validLevel(params.level);
coder.internal.errorIf(~validQ(params.qlen),'Wavelet:dualtree:UnsupportedQ');
params.biorth = validatestring(params.biorth,validBiorth,'dualtree2',...
    'LevelOneFilter');


function c = assgnq2c(x,szD,level)
% x is a numeric array of any size or type.
% level is a positive integer.
% This local function is only needed for MATLAB code generation

c = cell(level,1);

% Define some arbitrary size that depends on the dimensions of x. It might
% depend on other data. Each element, whether constant or not, is an upper
% bound on the actual run-time size of each element of the cell array.

coder.varsize('tmp');
% Assign each element of the cell array. Note in the report that the
% elements have variable size.
for k = 1:level
    tmp = complex(zeros(szD(k,1),szD(k,2),szD(k,3),szD(k,5),szD(k,4),'like',x));
    c{k} = tmp;
    
end

function c = assgnscale(x,szA,level)
% x is a numeric array of any size or type.
% level is a positive integer.
% This function is only needed for MATLAB code generation

c = cell(level,1);

% Define some arbitrary size that depends on the dimensions of x. It might
% depend on other data. Each element, whether constant or not, is an upper
% bound on the actual run-time size of each element of the cell array.

coder.varsize('tmp');
    
% Assign each element of the cell array. Note in the report that the
% elements have variable size.
for k = 1:level
    tmp = complex(zeros(szA(k,1),szA(k,2),szA(k,3),szA(k,4),'like',x));
    c{k} = tmp;
end





