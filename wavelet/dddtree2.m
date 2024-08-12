function dt = dddtree2(typetree,X,L,varargin)
%DDDTREE2 Forward real and complex double and double-density 2-D dual-tree
% wavelet transform
%   DT = DDDTREE2(TYPETREE,X,L,FDF,DF) returns the decomposition
%   dual-tree or double density dual-tree structure of the matrix
%   X using the filters FDF and DF.
%
%   TYPETREE gives the type of the required tree. It may be
%   equal to 'dwt', 'realdt', 'cplxdt', 'ddt', 'realdddt' or
%   'cplxdddt'.
%
%   L is an integer which gives the level (number of stages) of
%   the decomposition.
%
%   FDf and Df are cell arrays of vectors.
%     FDf{k}: First stage filters for tree k (k = 1,2)
%     Df{k} : Filters for remaining stages on tree k
%
%   X is a N by M matrix with M and N both even.
%   L, N, and M must be such that:
%     min(M,N) >= 2^(L-1)*length(filters) and 2^L divide min(M,N).
%
%   DT is a structure which contains five fields:
%      type:    type of tree.
%      level:   level of decomposition.
%      filters: structure containing filters for
%               decomposition and reconstruction
%          | FDf: First stage decomposition filters
%          |  Df: Decomposition filters for remaining stages
%          | FRf: First stage reconstruction filters
%          |  Rf: Reconstruction filters for remaining stages
%      cfs: coefficients of wavelet  transform 1 by L cell array
%           depending on TYPETREE (see below).
%      sizes:   sizes of components of cfs.
%
%	The same decomposition structure DT may be obtained using
%   the filters names instead of the filters values:
%       DT = DDDTREE2(TYPETREE,X,L,fname1) or
%       DT = DDDTREE2(TYPETREE,X,L,fname1,fname2) or
%       DT = DDDTREE2(TYPETREE,X,L,{fname1,fname2})
%   The same result is obtained using:
%       DT = DDDTREE2(TYPETREE,X,L,{FDF,DF})
%   The number of and the type of required filters depend
%   on TYPETREE.
%
%   cfs (1 by L cell array) is given by:
%       If TYPETREE is 'dwt' (1 filter): usual dwt2 tree
%           cfs{j}(:,:,d) - wavelet coefficients
%               j = 1,...,L (scale)
%               d = 1,2,3   (orientation)
%           cfs{L+1}(:,:) - lowpass or scaling coefficients
%
%       If TYPETREE is 'realdt' (2 filters): real dual tree
%           cfs{j}(:,:,d,k) - wavelet coefficients
%               j = 1,...,L (scale)
%               d = 1,2,3   (orientations)
%               k = 1,2     (tree number)
%           cfs{L+1}(:,:,k) - lowpass or scaling coefficients
%
%       If TYPETREE is 'cplxdt' (2 filters):  complex dual tree
%           cfs{j}(:,:,d,k,m) - wavelet coefficients
%               j = 1,...,L (scale)
%               d = 1,2,3   (orientations)
%               k = 1,2     (tree number)
%               m = 1 (real part) , m = 2 (imag part)
%           cfs{L+1}(:,:,k,m) - lowpass or scaling coefficients
%
%       If TYPETREE is 'ddt' (1 filter):
%           cfs{j}(:,:,d) - wavelet coefficients
%               j = 1,...,L  (scale)
%               d = 1,...,8  (orientations)
%           cfs{L+1}(:,:) - lowpass or scaling coefficients
%
%       If TYPETREE is 'realdddt' (2 filters):  double-density real dual tree
%           cfs{j}(:,:,d,k) - wavelet coefficients
%               j = 1,...,L  (scale)
%               d = 1,...,8  (orientations)
%               k = 1,2      (tree number)
%           cfs{L+1}(:,:,k) - lowpass or scaling coefficients
%
%       If TYPETREE is 'cplxdddt' (2 filters):  double-density complex dual tree
%           cfs{j}(:,:,d,k,m) - wavelet coefficients
%               j = 1,...,L  (scale)
%               d = 1,...,8  (orientations)
%               k = 1,2      (tree number)
%               m = 1 (real part) , m = 2 (imag part)
%           cfs{L+1}(:,:,k,m) - lowpass or scaling coefficients
%
%   % Example Obtain the real-oriented and complex dual-tree wavelet 
%   %   transforms of the xbox image down to level 3. Use the Farras 
%   %   nearly symmetric orthogonal filters for the first level and 
%   %   Kingsbury Q-shift 6-tap filters for levels two and three.
%   load xbox;
%   wtr = dddtree2('realdt',xbox,3,'dtf1');
%   wtc = dddtree2('cplxdt',xbox,3,'dtf1');
%
% See also IDDDTREE2, DTFILTERS, DDDTREE.

%   M. Misiti, Y. Misiti, G. Oppenheim, L.M. Poggi 09-Nov-2012.
%   Last Revision: 11-November-2017.
%   Copyright 1995-2020 The MathWorks, Inc.


% Check inputs
narginchk(4,5)
validateattributes(X,{'numeric'},{'finite','real','ndims',2},'DDDTREE2','X');
validateattributes(L,{'numeric'},...
    {'integer','scalar','positive','nonempty'},'DDDTREE2','L');
sizes = size(X);
SL = sizes(1:2)/2^L;
if any(isodd(sizes(1:2)))
    error(message('Wavelet:FunctionArgVal:Invalid_SizVal','X'));
elseif any(SL ~= fix(SL))
    % Both row and column dimensions have to be divisible by 2^L
    error(message('Wavelet:FunctionArgVal:DualTreeL',L));
end
% Convert string arguments to char arrays. Only possible string arguments
% are the typetree and the filter name.
[varargin{:}] = convertStringsToChars(varargin{:});
if isStringScalar(typetree)
    typetree = convertStringsToChars(typetree);
end
FilterName = '';
nbIN = length(varargin);
switch nbIN
    case 1
        if isnumeric(varargin{1})
            Df = varargin{1}; FDf = Df;
        elseif ischar(varargin{1})
            FilterName = varargin{1};
            Df = dtfilters(varargin{1},'d');
            if iscell(Df)
                FDf = Df{1};
                Df = Df{2};
            else
                FDf = Df;
            end
        elseif iscell(varargin{1})
            len = length(varargin{1});
            if isnumeric(varargin{1}{1})
                if isequal(len,1)
                    Df = varargin{1}{1}; FDf = Df;
                else
                    FDf = varargin{1}{1}; Df = varargin{1}{2};
                end
            elseif ischar(varargin{1}{1})
                if isequal(len,1)
                    FilterName = varargin{1}{1};
                    Df = dtfilters(varargin{1}{1},'d');
                    FDf = Df;
                else
                    FilterName{1} = varargin{1}{1};
                    FilterName{2} = varargin{1}{2};
                    FDf = dtfilters(varargin{1}{1},'d');
                    Df = dtfilters(varargin{1}{2},'d');
                end
            else
                FDf = varargin{1}{1};
                Df  = varargin{1}{2};
            end
        end
        
    case 2
        if isnumeric(varargin{1}) || iscell(varargin{1})
            FDf = varargin{1};  Df = varargin{2};
        elseif ischar(varargin{1})
            FilterName{1} = varargin{1};
            FilterName{2} = varargin{2};
            FDf = dtfilters(varargin{1},'d');
            Df = dtfilters(varargin{2},'d');
        end
end
if iscell(Df)
    lenDf = max([length(FDf{1}),length(Df{1})]);
else
    lenDf = max([length(FDf),length(Df)]);
end
OkSize = ~(min(sizes) < 2^(L-1)*lenDf);
if ~OkSize
    error(message('Wavelet:FunctionArgVal:Invalid_SizVal','X'));
end

% Check of the compatibility between the filters and the type of tree
valCHECK = Check_TREE(typetree,FilterName);
if isequal(valCHECK,1)
    warning(message('Wavelet:FunctionInput:Warn_Filter_AND_Tree'));
else
    if isequal(valCHECK,2)
        error(message('Wavelet:FunctionInput:Err_Filter_AND_Tree'));
    end
end

switch typetree
    case 'dwt'
        % Discrete 2-D wavelet transform
        cfs = cell(1,L+1);
        for j = 1:L
            [X,Hi,S] = decFB(X,FDf,Df);
            sizes = [sizes ; S]; %#ok<*AGROW>
            for m=1:3
                cfs{j}(:,:,m) = Hi{m};
            end
        end
        cfs{L+1} = X;
        
    case 'realdt'
        % 2-D Dual-Tree Discrete Wavelet Transform
        % [FDf,Df] = deal(varargin{:});
        
        % Normalization and Initialization
        X = X/sqrt(2);
        cfs = cell(1,L+1);
        
        % Tree Decomposition
        for k = 1:2   % k is the index of Tree
            y = X;
            for j = 1:L
                if j==1
                    decFILT = FDf{k};
                else
                    decFILT = Df{k};
                end
                [y,Hi,S] = decFB(y,decFILT);
                if k==1 
                    sizes = [sizes ; S]; %#ok<*AGROW>
                end 
                for d=1:3 
                    cfs{j}(:,:,d,k) = Hi{d}; % direction
                end 
            end
            if k==1 
                sizes = [sizes ; size(y)]; 
            end
            cfs{L+1}(:,:,k) = y;
        end
        
        % sum and difference
        for j = 1:L
            for d = 1:3
                A = cfs{j}(:,:,d,1);
                B = cfs{j}(:,:,d,2);
                cfs{j}(:,:,d,1) = (A+B)/sqrt(2);
                cfs{j}(:,:,d,2) = (A-B)/sqrt(2);
            end
        end
        
    case 'cplxdt'
        % Normalization and Initialization
        X = X/2;
        % Allocate cell array for wavelet and scaling coefficients
        cfs = cell(1,L+1);
        
        for k = 1:2
            for n = 1:2
                Lo = X;
                for j = 1:L
                    if j==1
                        % First level requires different filters
                        decF1 = FDf{k}; decF2 = FDf{n};
                    else
                        decF1 = Df{k};  decF2 = Df{n};
                    end
                    [Lo,Hi,S] = dec2D(Lo,decF1,decF2);
                    if k==1 && n==1 
                        sizes = [sizes ; S]; %#ok<*AGROW>
                    end 
                    for d = 1:3 
                        cfs{j}(:,:,d,n,k) = Hi{d};
                    end
                end
                cfs{L+1}(:,:,n,k) = Lo;
            end
            if k==1 
                sizes = [sizes ; size(Lo)]; 
            end
        end
        for j = 1:L
            for d = 1:3
                % The following are order by filtering operations
                % We will re-order based to create the complex wavelets
                % But we want to extract these first.
                A = cfs{j}(:,:,d,1,1);
                B = cfs{j}(:,:,d,2,2);
                C = cfs{j}(:,:,d,2,1);
                D = cfs{j}(:,:,d,1,2);
                % tree 1 real
                % \Re{(\psi_h(x)+j\psi_g(x))(\psi_h(y)-j\psi_g(y)}
                % Real parts use the same filters for row-column filtering
                cfs{j}(:,:,d,1,1) = (A+B)/sqrt(2);
                % tree 2 real
                % \Re{(\psi_h(x)+j\psi_g(x))(\psi_h(y)+j\psi_g(y))}
                cfs{j}(:,:,d,2,1) = (A-B)/sqrt(2);
                
                % tree 1 imaginary \Im{(\psi_h(x)+j\psi_g(x))(\psi_h(y)-j\psi_g(y)}
                % Imaginary parts use different filter for row-column
                % filtering
                cfs{j}(:,:,d,1,2) = (C-D)/sqrt(2);
                % tree 2 imaginary \Im{(\psi_h(x)+j\psi_g(x))(\psi_h(y)+j\psi_g(y)}
                cfs{j}(:,:,d,2,2) = (C+D)/sqrt(2);
            end
        end
        
    case 'ddt'
        % Forward Double-Density Discrete 2-D Wavelet Transform
        % Normalization and Initialization
        cfs = cell(1,L+1);
        
        % Tree Decomposition
        for j = 1:L
            [X,Hi,S] = decFB3(X,FDf,Df);
            sizes = [sizes ; S];
            for d=1:8 
                cfs{j}(:,:,d) = Hi{d}; 
            end
        end
        cfs{L+1} = X;
        sizes = [sizes ; size(X)];
        
    case 'realdddt'
        % Normalization and Initialization
        X = X/sqrt(2);
        cfs = cell(1,L+1);
        
        % Tree Decomposition
        for k = 1:2   % k is the index of Tree
            Lo = X;
            for j = 1:L
                if j==1
                    decFILT = FDf{k};
                else
                    decFILT = Df{k};
                end
                [Lo,Hi,S] = decFB3(Lo,decFILT);
                if k==1 
                    sizes = [sizes ; S]; %#ok<*AGROW>
                end 
                for d=1:8 
                    cfs{j}(:,:,d,k) = Hi{d};
                end
            end
            if k==1 
                sizes = [sizes ; size(Lo)];
            end
            cfs{L+1}(:,:,k) = Lo;
        end
        
        % sum and difference
        for j = 1:L
            for d = 1:8
                A = cfs{j}(:,:,d,1);
                B = cfs{j}(:,:,d,2);
                cfs{j}(:,:,d,1) = (A+B)/sqrt(2);
                cfs{j}(:,:,d,2) = (A-B)/sqrt(2);
            end
        end
        
    case 'cplxdddt'
        % Normalization and Initialization
        X = X/2;
        cfs = cell(1,L+1);
        
        % Tree Decomposition
        for k = 1:2
            for n = 1:2
                Lo = X;
                for j = 1:L
                    if j==1 
                        decF1 = FDf{k}; decF2 = FDf{n};
                    else
                        decF1 = Df{k};  decF2 = Df{n};
                    end
                    [Lo,Hi,S] = decFB3(Lo,decF1,decF2);
                    if k==1 && n==1 
                        sizes = [sizes ; S]; %#ok<*AGROW>
                    end 
                    for d=1:8
                        cfs{j}(:,:,d,n,k) = Hi{d};
                    end
                end
                if k==1 && n==1 
                    sizes = [sizes ; size(Lo)];
                end
                cfs{L+1}(:,:,n,k) = Lo;
            end
        end
        
        for j = 1:L
            for n = 1:2
                for d = 1:8
                    A = cfs{j}(:,:,d,n,1);
                    B = cfs{j}(:,:,d,n,2);
                    cfs{j}(:,:,d,n,1) = (A+B)/sqrt(2);
                    cfs{j}(:,:,d,n,2) = (A-B)/sqrt(2);
                end
            end
        end
        
    otherwise
        error(message('Wavelet:FunctionInput:Invalid_TypeTree'));
        
end
dt.type  = typetree;
dt.level = L;
F.FDf = FDf; F.Df  = Df;
if ~iscell(FDf)
    F.FRf = flipud(FDf);
else
    for k = 1:length(FDf) 
        FDf{k} = flipud(FDf{k});
    end
    F.FRf = FDf;
end
if ~iscell(Df)
    F.Rf = flipud(Df);
else
    for k = 1:length(Df) 
        Df{k} = flipud(Df{k}); 
    end
    F.Rf = Df;
end
dt.filters = F;
dt.cfs = cfs;
dt.sizes = sizes;


%-------------------------------------------------------------------------
function [Lo,Hi,S] = decFB(X,Df1,Df2)
% 2-D Decomposition filter bank
% INPUT:
%   X - N by M matrix
%       1) M,N are both even
%       2) M >= 2*length(Df1)
%       3) N >= 2*length(Df2)
%   Df1 - analysis filters for columns
%   Df2 - analysis filters for rows
% OUTPUT:
%    Lo - lowpass subband
%    Hi{1} - 'LH' subband
%    Hi{2} - 'HL' subband
%    Hi{3} - 'HH' subband

if nargin < 3 ,Df2 = Df1; end

% filter along columns
[Lc,Hc] = local_DEC_FB(X,Df1,1);

% filter along rows
[Lo,Hi{1}] = local_DEC_FB(Lc,Df2,2);
[Hi{2},Hi{3}] = local_DEC_FB(Hc,Df2,2);
S = [size(Hi{1});size(Hi{2});size(Hi{3})];
%-------------------------------------------------------------------------
function [Lo,Hi] = local_DEC_FB(X,Df,d)
% 2D Analysis Filter Bank (along one dimension only)
% INPUT:
%    X - NxM matrix,where min(N,M) > 2*length(filter)
%       (N,M are even)
%    Df - analysis filter for the columns
%    Df(:,1) - lowpass filter
%    Df(:,2) - highpass filter
%    d - dimension of filtering (d = 1 or 2)
% OUTPUT:
%     Lo,Hi - lowpass,highpass subbands

lpf = Df(:,1);     % lowpass filter
hpf = Df(:,2);     % highpass filter

if d == 2 , X = X'; end
N = size(X,1);
lf = size(Df,1)/2;
n = 0:N-1;
n = mod(n+lf,N);
X = X(n+1,:);

Lo = dyaddown(conv2(X,lpf),'r',1);
Lo(1:lf,:) = Lo(1:lf,:) + Lo((1:lf)+N/2,:);
Lo = Lo(1:N/2,:);

Hi = dyaddown(conv2(X,hpf),'r',1);
Hi(1:lf,:) = Hi(1:lf,:) + Hi((1:lf)+N/2,:);
Hi = Hi(1:N/2,:);

if d == 2 
    Lo = Lo'; 
    Hi = Hi'; 
end
%--------------------------------------------------------------------------
function [Lo,Hi,S] = decFB3(X,Df1,Df2)
% 2-D Decomposition filter bank (3 filters)
% INPUT:
%    X - NxM matrix,where min(N,M) > 2*length(filter)
%           (N,M are even)
%    Df1 - analysis filter for the columns
%    Df2 - analysis filter for the rows
%    Df(:,1) - lowpass filter
%    Df(:,2) - first highpass filter
%    Df(:,3) - second highpass filter
% OUTPUT:
%     Lo - lowpass subband
%     Hi - cell array containing the eight following highpass subbands
%         1) Hi{1} = 'Lo H1' subband
%         2) Hi{2} = 'Lo H2' subband
%         3) Hi{3} = 'H1 Lo' subband
%         4) Hi{4} = 'H1 H1' subband
%         5) Hi{5} = 'H1 H2' subband
%         6) Hi{6} = 'H2 Lo' subband
%         7) Hi{7} = 'H2 H1' subband
%         8) Hi{8} = 'H2 H2' subband

if nargin < 3 ,Df2 = Df1; end

% filter along columns
[Loc,H1loc,H2loc] = local_DEC(X,Df1,1);

% filter along rows
[Lo, Hi{1},Hi{2}] = local_DEC(Loc,Df2,2);
[Hi{3},Hi{4},Hi{5}] = local_DEC(H1loc,Df2,2);
[Hi{6},Hi{7},Hi{8}] = local_DEC(H2loc,Df2,2);
S = repmat(size(Hi{1}),8,1);
%--------------------------------------------------------------------------
function [Lo,H1,H2] = local_DEC(X,Df,d)
% 2-D Analysis Filter Bank(  along one dimension only)
% INPUT:
%    X - NxM matrix,where min(N,M) > 2*length(filter)
%        (N,M are even)
%    Df - analysis filter for the columns
%    Df(:,1) - lowpass filter
%    Df(:,2) - first highpass filter
%    Df(:,3) - second highpass filter
%    d - dimension of filtering (d = 1 or 2)
% OUTPUT:
%     Lo,H1,H2 - one lowpass and two highpass subbands

lpf  = Df(:,1);    % lowpass filter
hpf1 = Df(:,2);    % first highpass filter
hpf2 = Df(:,3);    % second highpass filter

if d == 2 ,X = X'; end

N = size(X,1);
len = size(Df,1)/2;
X = wshift('2d',X,[len 0]);

Lo = dyaddown(conv2(X,lpf),'r',1);
Lo(1:len,:) = Lo(1:len,:) + Lo((1:len)+N/2,:);
Lo = Lo(1:N/2,:);

H1 = dyaddown(conv2(X,hpf1),'r',1);
H1(1:len,:) = H1(1:len,:) + H1((1:len)+N/2,:);
H1 = H1(1:N/2,:);

H2 = dyaddown(conv2(X,hpf2),'r',1);
H2(1:len,:) = H2(1:len,:) + H2((1:len)+N/2,:);
H2 = H2(1:N/2,:);

if d == 2
    Lo = Lo';   
    H1 = H1';  
    H2 = H2';
end
%-------------------------------------------------------------------------
function [Lo,Hi,S] = dec2D(X,Df1,Df2)
% 2D Decomposition Filter Bank
% INPUT:
%   X - N by M matrix
%       M,N are both even , M >= 2*length(Df1) , N >= 2*length(Df2)
%   Df1 - decomposition filters for columns
%   Df2 - decomposition filters for rows
% OUTPUT:
%    Lo - lowpass subband
%    Hi{1} - 'LH' subband
%    Hi{2} - 'HL' subband
%    Hi{3} - 'HH' subband

if nargin < 3 
    Df2 = Df1;
end

% filter along columns
[Ldir,Hdir] = directional_dec2D(X,Df1,1);

% filter along rows
[Lo,   Hi{1}] = directional_dec2D(Ldir,Df2,2);
[Hi{2},Hi{3}] = directional_dec2D(Hdir,Df2,2);
S = [size(Hi{1});size(Hi{2});size(Hi{3})];
%-------------------------------------------------------------------------
function [Lo,Hi] = directional_dec2D(X,Df,d)
% 2D Decomposition Filter Bank (along one dimension only)
% INPUT:
%    X  - NxM matrix,where min(N,M) > 2*length(filter) - (N,M are even)
%    Df - decomposition filter for the columns
%    Df(:,1) - lowpass filter
%    Df(:,2) - highpass filter
%    d - dimension of filtering (d = 1 or 2)
% OUTPUT:
%     Lo,Hi - lowpass,highpass subbands

lpf = Df(:,1);     % lowpass filter
hpf = Df(:,2);     % highpass filter

if d == 2 
    X = X';
end
N = size(X,1);
lf = size(Df,1)/2;
n = 0:N-1;
n = mod(n+lf,N);
X = X(n+1,:);
% conv2() here uses full default convolution along the columns of X
% Then downsample by two along the column dimension, staring with the first
% element
Lo = dyaddown(conv2(X,lpf),'r',1);
Lo(1:lf,:) = Lo(1:lf,:) + Lo((1:lf)+N/2,:);
Lo = Lo(1:N/2,:);

Hi = dyaddown(conv2(X,hpf),'r',1);
Hi(1:lf,:) = Hi(1:lf,:) + Hi((1:lf)+N/2,:);
Hi = Hi(1:N/2,:);

if d == 2 
    Lo = Lo'; 
    Hi = Hi'; 
end
%-------------------------------------------------------------------------
function [valCHECK,NbChan] = Check_TREE(typeTree,filterName)

typeTree_Cell = {'dwt','realdt','cplxdt','ddt','realdddt','cplxdddt'};
filter_Cell = {'dtf1','dtf2','dtf3','dtf4','dtf5','dddtf1','self1','self2', ...
    'filters1','filters2','farras','FSfarras', ...
    'qshift6','qshift10','qshift14','qshift16','qshift18', ...
    'doubledualfilt','FSdoubledualfilt','AntonB'};
NbChannels = [2;2;2;2;2;3;3;3;3;3;2;2;2;2;2;2;2;3;3;2;2];

Flag_Tree = [ ...
    2 2 2 2 2 2 2 2 1 1 0 1 1 1 1 1 1 1 1 1 0;
    0 0 0 0 0 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2;
    0 0 0 0 0 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 0 0 2 2 2 2 2 2 2 0 0 2 2;
    2 2 2 2 2 0 0 0 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 0 0 0 2 2 2 2 2 2 2 2 2 2 2 2 2];
% Flag = 0 ==> Decomposition and Perfect Reconstruction OK
% Flag = 1 ==> Decomposition OK , Perfect Reconstruction NOT OK
% Flag = 2 ==> Decomposition Invalid

idxRow = strcmp(typeTree,typeTree_Cell);
if ~iscell(filterName)
    idxCol = strcmp(filterName,filter_Cell);
    if all(idxCol==0)
        try wfilters(filterName); idxCol = size(Flag_Tree,2); catch , end
    end
    valCHECK = Flag_Tree(idxRow,idxCol);
else
    idxCol = strcmp(filterName{1},filter_Cell);
    valCHECK = [];
end
NbChan = NbChannels(idxCol);
%-------------------------------------------------------------------------

