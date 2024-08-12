function varargout = mwptdec(dirDec,data,lev,varargin)
%MWPTDEC Multisignal wavelet packet 1-D decomposition is a function for
%   parsing value-only inputs, flags, and name-value pairs for the vmd
%   function. This function is for internal use only. It may be removed in
%   the future.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Feb-2011
%   Last Revision: 28-Aug-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

%#codegen

narginchk(4,7);
% parse wavelet filters
treeflag = false;

coder.extrinsic('wfilters');

if ischar(varargin{1})
    wname = varargin{1};
    if coder.target('MATLAB')
        [LoD,HiD,LoR,HiR] = wfilters(wname);
    else
        [LoD,HiD,LoR,HiR] = coder.const(@wfilters, wname);
    end
    dwtEXTM = varargin{2}; % extension mode
else
    wname = [];
    LoD = varargin{1};
    HiD = varargin{2};
    LoR = [];
    HiR = [];
    treeflag = varargin{3};
    dwtEXTM = varargin{4}; % extension mode
end
dataSize = size(data);

switch dirDec
    case 'c'
        x = data.';
        dirCAT = 2;
    otherwise
        dirCAT = 1;
        x = data;
end
first = 2; % select even samples
perFLAG = strcmp(dwtEXTM,'per');

% x has the size of <channels x samples>
% Initialization.
sx = ones(lev+1,1);

% Full decomposition
fulltree = coder.nullcopy(cell(1,sum(2.^(1:lev))+1));
fulltree{1}   = x;
coder.varsize('fulltree{:}')

idxLST = 1;
idxNode = 2;
idxLev = 1;
for j = 1:((2^lev)-1)
    [a,d] = dwtLOC(fulltree{idxLST},LoD,HiD,dwtEXTM,first,perFLAG);
    if signalwavelet.internal.isodd(idxLST) && (idxLST~=1)
        % swap approximation and detail signals for sequency-ordering
        fulltree{idxNode} = d;
        fulltree{idxNode+1} = a;
    else
        fulltree{idxNode} = a;
        fulltree{idxNode+1} = d;        
    end
    idxTemp = log2(j);
    if idxTemp == round(idxTemp)
        sx(idxLev) = size(fulltree{idxLST},2);
        idxLev = idxLev+1;
    end   
    idxNode = idxNode + 2;
    idxLST = idxLST + 1;
end
sx(idxLev) = size(fulltree{idxLST},2); % node at the terminal level

if treeflag % full tree
   numNodes = length(fulltree)-1;
else
    numNodes = 2^lev; 
end

Filters = struct('LoD',LoD,'HiD',HiD,'LoR',LoR,'HiR',HiR);

cfs = coder.nullcopy(cell(1,numNodes));
for ii = 1:numNodes
   cfs{ii} = fulltree{end-numNodes+ii};
end

dec = struct('dirDec',dirDec,...
    'level',lev,...
    'wname',wname,...
    'dwtFilters',Filters,...
    'dwtEXTM',dwtEXTM,...
    'dataSize',dataSize,...
    'sx',sx,...
    'cfs',{cfs});

% assign output
varargout{1} = dec;

if nargout == 2
    varargout{2} = cat(dirCAT,dec.cfs{:});
end

end


%------------------------------------------------------------------------
function [a,d] = dwtLOC(x,LoD,HiD,dwtEXTM,first,perFLAG)

% Compute sizes.
lf = length(LoD);
lx = size(x,2);
lc = size(x,1);

% Extend, Decompose &  Extract coefficients.
dCol = lf-1;
if ~perFLAG
    lenEXT = lf-1;
    lenKEPT = lx+lf-1;      
else
    lenEXT = ceil(lf/2);
    lenKEPT = 2*ceil(lx/2);
end     

idxCOL = (first + dCol : 2 : lenKEPT + dCol);
y = wextend('addcol',dwtEXTM,x,lenEXT);
a = conv2(y(1:lc,:),LoD,'full'); 
a = a(:,idxCOL);
d = conv2(y(1:lc,:),HiD,'full');
d = d(:,idxCOL);
end
