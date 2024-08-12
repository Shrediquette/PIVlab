function dt = dddtree(typetree,x,L,varargin)
%DDDTREE Forward real and complex double and Double-Density 
%        Dual-Tree 1-D DWT
%   DT = DDDTREE(TYPETREE,X,L,FDF,DF) returns the decomposition 
%   dual-tree or double density dual-tree structure of the vector 
%   X using the filters FDF and DF.
%
%   TYPETREE gives the type of the required tree. It may be
%   equal to 'dwt', 'cplxdt', 'ddt' or 'cplxdddt'.
%
%   L is an integer which gives the level (number of stages) of 
%   the decomposition.
%
%   FDf and Df are cell arrays of vectors.
%     FDf{k}: First stage filters for tree k (k = 1,2)
%     Df{k} : Filters for remaining stages on tree k
%
%   X is a vector of even length N.
%   L and N must be such that:
%     N >= 2^(L-1)*length(filters)) and 2^L divide N.
%
%   DT is a structure which contains four fields:
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
%
%	The same decomposition structure DT may be obtained using
%   the filters names instead of the filters values:
%       DT = DDDTREE(TYPETREE,X,L,fname1) or 
%       DT = DDDTREE(TYPETREE,X,L,fname1,fname2) or 
%       DT = DDDTREE(TYPETREE,X,L,{fname1,fname2})
%   The same result is obtained using:
%       DT = DDDTREE(TYPETREE,X,L,{FDF,DF}) 
%   The number of and the type of required filters depend 
%   on TYPETREE.
%    
%   cfs (1 by L cell array) is given by:
%       If TYPETREE is 'dwt' - usual dwt tree (1 filter):
%           cfs{j} - wavelet coefficients
%               j = 1,...,L  (scale)
%           cfs{L+1} - lowpass or scaling coefficients
% 
%       If TYPETREE is 'cplxdt' - complex dual tree (2 filters):
%           cfs{j}(:,:,m) - wavelet coefficients
%               j = 1,...,L  (scale)
%               m = 1 (real part) , m = 2 (imag part)
%           cfs{L+1}(:,:,m) - lowpass or scaling coefficients
% 
%       If TYPETREE is 'ddt' - real double density dual tree  (1 filter):
%           cfs{j}(:,:,k) - wavelet coefficients
%               j = 1,...,L   (scale)
%               k = 1,2       (tree number)
%           cfs{L+1}(:,:) - lowpass or scaling coefficients
% 
%       If TYPETREE is 'cplxdddt' - complex double density dual tree  (2 filters):
%           cfs{j}(:,:,k,m) - wavelet coefficients
%               j = 1,...,L   (scale)
%               k = 1,2       (tree number)
%               m = 1 (real part) , m = 2 (imag part)
%           cfs{L+1}(:,:,m) - lowpass or scaling coefficients
%
%   See also IDDDTREE, DTFILTERS, DDDTREE2.

%   M. Misiti, Y. Misiti, G. Oppenheim, L.M. Poggi 21-Dec-2012.
%   Last Revision: 04-Jul-2013.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check inputs
narginchk(4,5)
validateattributes(x,{'numeric'},{'real','finite','vector'},'DDDTREE','X');
validateattributes(L,{'numeric'},...
    {'integer','scalar','positive','nonempty'},'DDDTREE','L');
len = length(x);
SL = len/2^L;
if isodd(len)
    error(message('Wavelet:FunctionArgVal:Invalid_LengthVal','X'));    
elseif (SL ~= fix(SL))
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
            Df = varargin{1};  FDf = Df;
        elseif ischar(varargin{1})
            FilterName = varargin{1};
            Df = dtfilters(varargin{1},'d');
            if iscell(Df) , FDf = Df{1}; Df = Df{2}; else FDf = Df; end      
        elseif iscell(varargin{1})
            lenArg = length(varargin{1});
            if isnumeric(varargin{1}{1})
                if isequal(lenArg,1)
                    Df = varargin{1}{1}; FDf = Df;
                else
                    FDf = varargin{1}{1}; Df = varargin{1}{2};
                end
            elseif ischar(varargin{1}{1})
                if isequal(lenArg,1)
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
            FDf = varargin{1};  
            Df = varargin{2};
        elseif ischar(varargin{1})
            FilterName{1} = varargin{1};
            FilterName{2} = varargin{2};
            FDf = dtfilters(varargin{1},'d');
            Df  = dtfilters(varargin{2},'d');
        end
end

if iscell(Df)
    lenDf = max([length(FDf{1}),length(Df{1})]);
else
    lenDf = max([length(FDf),length(Df)]);
end
OkSize = ~(len < 2^(L-1)*lenDf);
if ~OkSize
    error(message('Wavelet:FunctionArgVal:Invalid_SizVal','X'));
end

% Check of the compatibility between the filters and the type of tree
[valCHECK,~] = Check_TREE(typetree,FilterName); 
if isequal(valCHECK,1)
    warning(message('Wavelet:FunctionInput:Warn_Filter_AND_Tree'));
else
    if isequal(valCHECK,2)
        error(message('Wavelet:FunctionInput:Err_Filter_AND_Tree'));
    end
end

switch typetree
    case 'dwt'
    % Discrete 1-D Wavelet Transform
        % Decomposition
        cfs = cell(1,L+1);
        for j = 1:L
            [x,cfs{j}] = decFB(x,Df);
        end
        cfs{L+1} = x;

    case 'cplxdt'
    % Dual-tree Complex Discrete 1-D Wavelet Transform
        % normalization
        x = x/sqrt(2);
        cfs = cell(1,L+1);
        
        % Tree 1 and 2
        for k= 1:2  
            y = x;
            for j = 1:L
                if j==1 , decF = FDf{k}; else decF = Df{k}; end
                [y,cfs{j}(:,:,k)] = decFB(y,decF);
            end
            cfs{L+1}(:,:,k) = y;
        end        

    case 'ddt'
    % Double-Density Discrete 1-D Wavelet Transform
        cfs = cell(1,L+1);
        for j = 1:L
            [x,cfs{j}(:,:,1),cfs{j}(:,:,2)] = decFB3(x,Df);
        end
        cfs{L+1} = x;
        
    case 'cplxdddt'
    % Double-Density Dual-Tree 1-D Wavelet Transform (complex)
        % normalization
        x = x/sqrt(2);
        cfs = cell(1,L+1);
         
        % Tree 1 and 2
        for k = 1:2 
            y = x;
            for j = 1:L
                if j==1 , decF = FDf{k}; else decF = Df{k}; end
                [y,cfs{j}(:,:,1,k),cfs{j}(:,:,2,k)] = decFB3(y,decF);
            end
            cfs{L+1}(:,:,k) = y;
        end
        
    otherwise
        error(message('Wavelet:FunctionInput:Invalid_TypeTree'));
        
end
dt.type = typetree;
dt.level = L;
F.FDf = FDf; F.Df  = Df;
if ~iscell(FDf)
    F.FRf = flipud(FDf);
else
    for k = 1:length(FDf) , FDf{k} = flipud(FDf{k}); end
    F.FRf = FDf;
end
if ~iscell(Df)
    F.Rf = flipud(Df);
else
    for k = 1:length(Df) , Df{k} = flipud(Df{k}); end
    F.Rf = Df;
end
dt.filters = F;
dt.cfs = cfs;

%-------------------------------------------------------------------------
function [Lo,Hi] = decFB(x,Df)
% Decomposition filter bank
% INPUT:
%    x - N-point vector, where
%            1) N is even
%            2) N >= length(Df)
%    Df - analysis filters
%    Df(:, 1) - lowpass filter (even length)
%    Df(:, 2) - highpass filter (even length)
% OUTPUT:
%    Lo - Low frequency output
%    Hi - High frequency output

N = length(x);
D = length(Df)/2;
x = wshift('1d',x,D);

% lowpass filter
Lo = dyaddown(conv(x,Df(:,1)),1);
Lo(1:D) = Lo(N/2+(1:D)) + Lo(1:D);
Lo = Lo(1:N/2);

% highpass filter
Hi = dyaddown(conv(x,Df(:,2)),1);
Hi(1:D) = Hi(N/2+(1:D)) + Hi(1:D);
Hi = Hi(1:N/2);
%-------------------------------------------------------------------------
function [Lo,H1,H2] = decFB3(x,Df)
% Decomposition Filter Bank (three filters)
%
% INPUT:
%     x - N-point vector (N even and N >= length(Df))
%    Df - analysis filters (even lengths)
%       Df(:,1)   - lowpass filter
%       Df(:,2:3) - two highpass filters
%
% OUTPUT:
%     Lo - low frequency output
%     H1, H2 - first and second high frequency output

N = length(x);
D = length(Df)/2;
x = wshift('1d',x,D);

% lowpass filter
Lo = dyaddown(conv(x,Df(:,1)),1);
Lo(1:D) = Lo(N/2+(1:D)) + Lo(1:D);
Lo = Lo(1:N/2);

% first highpass filter
H1 = dyaddown(conv(x,Df(:,2)),1);
H1(1:D) = H1(N/2+(1:D)) + H1(1:D);
H1 = H1(1:N/2);

% second highpass filter
H2 = dyaddown(conv(x,Df(:,3)),1);
H2(1:D) = H2(N/2+(1:D)) + H2(1:D);
H2 = H2(1:N/2);
%-------------------------------------------------------------------------
function [valCHECK,NbChan] = Check_TREE(typeTree,filterName)

typeTree_Cell = {'dwt','cplxdt','ddt','cplxdddt'};
filter_Cell = {'dtf1','dtf2','dtf3','dtf4','dtf5','dddtf1','self1','self2', ...
    'filters1','filters2','farras','FSfarras', ...
    'qshift6','qshift10','qshift14','qshift16','qshift18', ...
    'doubledualfilt','FSdoubledualfilt','AntonB'};
NbChannels = [2;2;2;2;2;3;3;3;3;3;2;2;2;2;2;2;2;3;3;2;2];

Flag_Tree = [ ...
    2 2 2 2 2 2 2 2 1 1 0 0 0 0 0 0 0 1 1 1 0;
    0 0 0 0 0 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 0 0 2 2 2 2 2 2 2 0 0 2 2;
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

