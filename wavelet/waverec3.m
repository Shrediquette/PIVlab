function X = waverec3(wdec,varargin)
%WAVEREC3 Multilevel 3-D wavelet reconstruction.
%   WAVEREC3 performs a multilevel 3-D wavelet reconstruction
%   starting from a multilevel 3-D wavelet decomposition.
%
%   X = WAVEREC3(WDEC) reconstructs the 3-D array X based
%   on the multilevel wavelet decomposition structure WDEC.
%
%   In addition, you can use WAVEREC3 to simply extract coefficients 
%   from a 3-D wavelet decomposition (see below).
%
%   WDEC is a structure with the following fields:
%     sizeINI: contains the size of the 3-D array X.
%     level:   contains the level of the decomposition.
%     mode:    contains the name of the wavelet transform extension mode.
%     filters: is a structure with 4 fields LoD, HiD, LoR, HiR which
%              contain the filters used for DWT.
%     dec:     is an N x 1 cell array containing the coefficients of the
%              decomposition. N is equal to 7*WDEC.level+1. dec{1} contains
%              the lowpass component (approximation) at the level of the
%              decomposition. The approximation is equivalent to the
%              filtering operations 'LLL'. dec{k+2},...,dec{k+8} with k =
%              0,7,14,...,7*(WDEC.level-1) contain the 3-D wavelet
%              coefficients. The coefficients start with the coarsest level
%              when k=0. For example, if WDEC.level=3, dec{2},...,dec{8}
%              contain the wavelet coefficients for level 3 (k=0),
%              dec{9},...,dec{15} contain the wavelet coefficients for
%              level 2 (k=7), and dec{16},...,dec{22} contain the wavelet
%              coefficients for level 1 (k=7*(WDEC.level-1)). At each
%              level, the wavelet coefficients in dec{k+2},...,dec{k+8} are
%              in the following order:
%              'HLL','LHL','HHL','LLH','HLH','LHH','HHH'. The strings give
%              the order in which the separable filtering operations are
%              applied from left to right. For example, suppose the order
%              is 'LHH'. First, WAVEDEC3 applies the lowpass (scaling)
%              filter with downsampling to the rows of X. Next, WAVEDEC3
%              applies the highpass (wavelet) filter with downsampling to
%              the columns of X and then to the 3rd dimension of X.
%     sizes:   contains the successive sizes of the decomposition
%              components.
%
%   C = WAVEREC3(WDEC,TYPE,N) reconstructs the multilevel
%   components at level N of a 3-D wavelet decomposition. N must be
%   a positive integer less or equal to the level of the decomposition.
%   The valid values for TYPE are:
%       - A group of 3 chars 'xyz', one per direction, with 'x','y' and 'z' 
%         in the set {'a','d','l','h'} or in the corresponding upper case  
%         set {'A','D','L','H'}), where 'A' (or 'L') stands for low pass 
%         filter and 'D' (or 'H') stands for high pass filter.
%       - The char 'd' (or 'h' or 'D' or 'H') gives directly the sum of 
%         all the components different from the low pass one.
%       - The char 'a' (or 'l' or 'A' or 'L') gives the low pass 
%         component (the approximation at level N).
%
%   For extraction purpose, the valid values for TYPE are the same as
%   above prefixed by 'c' or 'C'.
%
%   X = WAVEREC3(WDEC,'a',0) or X = WAVEREC3(WDEC,'ca',0) is equivalent
%   to X = WAVEREC3(WDEC).
%
%	C = WAVEREC3(WDEC,TYPE) is equivalent to C = WAVEREC3(WDEC,TYPE,N)
%   with N equal to the level of the decomposition.
%
%   % Example:
%       M = magic(8);
%       X = repmat(M,[1 1 8]);
%       wd = wavedec3(X,2,'db2','mode','per');
%       XR = waverec3(wd);
%       err1 = max(abs(X(:)-XR(:)))
%       A = waverec3(wd,'aaa');
%       CA = waverec3(wd,'ca');
%       D = waverec3(wd,'d');
%       err2 = max(abs(X(:)-A(:)-D(:)))
%       A1 = waverec3(wd,'aaa',1);
%       D1 = waverec3(wd,'d',1);
%       err3 = max(abs(X(:)-A1(:)-D1(:)))
%       DDD = waverec3(wd,'ddd',2);
%       disp(DDD(:,:,1))
%
%   See also idwt3, wavedec3, waveinfo.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Dec-2008.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbIn = length(varargin);

% Initialization.
cfs   = wdec.dec;
sizes = wdec.sizes;
level = wdec.level;
cfsFLAG = false;
nbREC_UP = level;

if nbIn>0
    errorFLAG = false;
    type = varargin{1};
    nbChar = length(type);
    if nbChar==2 || nbChar==4
        if isequal(upper(type(1)),'C')
            type(1) = []; nbChar = nbChar-1; cfsFLAG = true;
        else
            errorFLAG = true;
        end
    end
    switch nbChar
        case {1,3}
            num = ones(1,3);
            switch type
                case {'a','l','A','L','1'} , num = Inf;
                case {'d','h','D','H','0'} , num = -num;
                otherwise
                    if nbChar==3
                        for k = 1:3
                            switch type(k)
                                case {'a','l','A','L','1'}
                                case {'d','h','D','H','0'} , num(k) = 2;
                                otherwise , errorFLAG = true;
                            end
                        end
                    else
                        errorFLAG = true;
                    end
            end                        
        otherwise , errorFLAG = true;
    end
    if isequal(num,[1 1 1]) , num = Inf; end
    
    if errorFLAG
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
    end
    
    if nbIn>1
        levREC = varargin{2};
        OKval = isnumeric(levREC) && isequal(levREC,fix(levREC)) && ...
            levREC<=level && (levREC>0 || ...
            (levREC==0 && (isequal(num,[1 1 1]) || isinf(num))) );
        if ~OKval
                error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
        end
    else
        levREC = level;
    end
    if isinf(num)
        First_toDEL = 2+7*(level-levREC);
        for k = First_toDEL:(7*level+1) , cfs{k}(:) = 0; end
        if cfsFLAG
            if isequal(level,levREC) , X = cfs{1}; return; end
            nbREC_UP = level-levREC;
        end
        
    elseif isequal(num,[-1,-1,-1])
        cfs{1}(:) = 0;
        for k = 1:(level-levREC)
            for j = 1:7 , cfs{7*(k-1)+j+1}(:) = 0; end
        end
        if cfsFLAG , X = cfs; end
        
    else
        num(num==2) = 0;
        Idx_toKeep = 7*(level-levREC) + subbandIdx(num);
        if cfsFLAG
            if (~isequal(num,[1,1,1]) || isequal(level,levREC))
                X = cfs{Idx_toKeep};
                return
            elseif isequal(num,[1,1,1])
                nbREC_UP = level-levREC;
            end
        end
        for k = 1:(7*level+1)
            if k~=Idx_toKeep , cfs{k}(:) = 0; end
        end
        
    end
end

idxBeg = 1;
for k=1:nbREC_UP
    idxEnd = idxBeg+7;
    wdec.dec = reshape(cfs(idxBeg:idxEnd),2,2,2);
    X = idwt3(wdec,sizes(k+1,:));
    cfs{idxEnd} = X;
    idxBeg = idxEnd;
end

%-------------------------------------------------------------------------
function idxtokeep = subbandIdx(num)
idx = bin2dec(dec2bin(num)');
switch idx
    case 0
        idxtokeep = 8;
    case 1 
        idxtokeep = 4;
    case 2
        idxtokeep = 6;
    case 3
        idxtokeep = 2;
    case 4
        idxtokeep = 7;
    case 5 
        idxtokeep = 3;
    case 6
        idxtokeep = 5;
    case 7
        idxtokeep = 1;
end
