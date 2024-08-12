function X = idwt3(wt,varargin)
%IDWT3 Single-level inverse discrete 3-D wavelet transform.
%   IDWT3 performs a single-level 3-D wavelet reconstruction
%   starting from a single-level 3-D wavelet decomposition.
%
%   X = IDWT3(WT) computes the single-level reconstructed 3-D array
%   X based on 3-D wavelet decomposition contained in the structure
%   WT which contains the following fields:
%     sizeINI: contains the size of the 3-D array X.
%     mode:    contains the name of the wavelet transform extension mode.
%     filters: is a structure with 4 fields LoD, HiD, LoR, HiR which
%              contain the filters used for DWT.
%     dec:     is a 2x2x2 cell array containing the coefficients 
%              of the decomposition.
%              dec{i,j,k} , i,j,k = 1 or 2 contains the coefficients
%              obtained by low-pass filtering (for i or j or k = 1)
%              or high-pass filtering (for i or j or k = 2).              
%
%   C = IDWT3(WT,TYPE) allows to compute the single-level reconstructed 
%   component based on the 3-D wavelet decomposition. 
%   The valid values for TYPE are:
%       - A group of 3 chars 'xyz', one per direction, with 'x','y' and 'z' 
%         in the set {'a','d','l','h'} or in the corresponding upper case  
%         set {'A','D','L','H'}), where 'A' (or 'L') stands for low pass 
%         filter and 'D' (or 'H') stands for high pass filter.
%       - The char 'd' (or 'h' or 'D' or 'H') gives directly the sum of 
%         all the components different from the low pass one.
%
%   Examples:
%       X  = reshape(1:64,4,4,4);
%       wt = dwt3(X,'db1');
%       XR = idwt3(wt);
%       A  = idwt3(wt,'aaa');
%       D  = idwt3(wt,'d');
%       ADA  = idwt3(wt,'ada');
%
%   See also dwt3, wavedec3, waverec3.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Dec-2008.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

narginchk(1,2)
s   = wt.sizeINI;
dec = wt.dec;
Lo  = wt.filters.LoR;
Hi  = wt.filters.HiR;
dwtEXTM = wt.mode;
perFLAG = isequal(dwtEXTM,'per');

lf = zeros(1,3);
for k = 1:3 , lf(k) = length(Lo{k}); end

k = 1;
while k<=length(varargin)
    if ischar(varargin{k})
        word = varargin{k};
        switch word
            case {'a','l','A','L','1'}
                dec{1,1,2}(:) = 0; 
                dec{1,2,1}(:) = 0; dec{1,2,2}(:) = 0;
                dec{2,1,1}(:) = 0; dec{2,1,2}(:) = 0; 
                dec{2,2,1}(:) = 0; dec{2,2,2}(:) = 0;
                
            case {'d','h','D','H','0'}
                dec{1,1,1}(:) = 0; 
                
            otherwise
                if length(word)==3
                    num = ones(1,3);
                    for k = 1:3
                        
                        switch word(k)
                            case {'a','l','A','L','1'}
                                num(k) = 1;
                            case {'d','h','D','H','0'} 
                                num(k) = 2;
                            otherwise
                                num(k) = -1;
                        end
                    end
                    for n=1:2
                        for j=1:2
                            for k = 1:2
                                if ~isequal([n,j,k],num)
                                    dec{n,j,k}(:) = 0;
                                end
                            end
                        end
                    end
                else
                    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
                end
        end
        k = k+1; 
    else
        s = varargin{k};
        k = k+1;
    end
end

% Reconstruction.
perm = [1,3,2];
V = cell(2,2);
for i = 1:2    
    for j = 1:2
        V{i,j} = wrec1D(dec{i,j,1},Lo{3},perm,perFLAG,s) + ...
                 wrec1D(dec{i,j,2},Hi{3},perm,perFLAG,s);
    end
end
perm = [2,1,3];
W = cell(1,2);
for i = 1:2
    W{i} = wrec1D(V{i,1},Lo{2},perm,perFLAG,s) + ...
        wrec1D(V{i,2},Hi{2},perm,perFLAG,s);
end

% Last reconstruction.
X = wrec1D(W{1},Lo{1},[],perFLAG,s) + wrec1D(W{2},Hi{1},[],perFLAG,s);

%-----------------------------------------------------------------------%
function X = wrec1D(X,F,perm,perFLAG,s)

if ~isempty(perm)
    X = permute(X,perm);
    s = s(perm);
end
if perFLAG
    lf = length(F);
    lx = size(X,2);
    nb = fix(lf/2-1);
    idxAdd = 1:nb;
    if nb>lx
        idxAdd = rem(idxAdd,lx);
        idxAdd(idxAdd==0) = lx;
    end
    X = [X X(:,idxAdd,:)];
end
sX = size(X);
if length(sX)<3 , sX(3) = 1; end
Z = zeros(sX(1),2*sX(2)-1,sX(3));
Z(:,1:2:end,:) = X;
X = convn(Z,F);

sX = size(X,2);
F  = floor((sX-s)/2);
C  = ceil((sX-s)/2);
X  = X(:,1+F(2):end-C(2),:);

if ~isempty(perm) , X = permute(X,perm); end
%-----------------------------------------------------------------------%
