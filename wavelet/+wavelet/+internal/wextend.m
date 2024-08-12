function x = wextend(type,mode,x,lf)
%WEXTEND Extend a Vector or a Matrix
%
%   Internal function made for DWT
%   Y = WEXTEND(TYPE,MODE,X,L)
%
%   The valid extension modes (MODE) are:
%     'sym' symmetric extension
%     'per' periodized extension
%
%   The valid extension types (TYPE) are:
%     1 - One Dimensional: "1d", "1D", 1 
%     2 - Two Dimensional (Column + Row): addrow, addcol

%   Copyright 2019-2020 The MathWorks, Inc.

narginchk(4,4);

if isnumeric(type)
    isOneD = isequal(type,1);
else
    isOneD = any(strcmpi(type, ["1", "1d"]));
end

if isOneD % 1 dimensional case
    validateattributes(x,{'numeric'},{'vector','nonempty'},'wextend','X');
    
    sz = size(x);
    isROW = (sz(1) == 1);
    
    x  = reshape(x,1,[]);
    sx = max([sz(1),sz(2)]);
    
    if mode == "sym"
        x = makeSym(sx,lf,x);
    else
        if signalwavelet.internal.isodd(sx)
            x(sx+1) = x(sx);
            sx = sx+1;
        end
        x = makePer(sx,lf,x);
    end
    
    if ~isROW
        x = reshape(x,[],1);
    end
    
else
    % 2 dimensional case (adding rows or cols)
    isAddRow = strcmpi(type,'addrow');
    isAddCol = strcmpi(type,'addcol');
    
    if ~isAddRow && ~isAddCol
        % In case an invalid extension type is supplied
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
    end
    validateattributes(x,{'numeric'},{'2d','nonempty'},'wextend','X');
    
    x = wextend2(mode,x,lf,isAddCol);
end

end

function xout = wextend2(mode,x,lf,isAddCol)
% Extends a 2-D array in one direction.
[rx,cx] = size(x);
if isAddCol
    dim = cx;
else
    dim = rx;
end
if mode == "sym"
    xout = makeSym(dim,lf,x,isAddCol);
else
    % Assuming periodic extension
    if isAddCol
        if signalwavelet.internal.isodd(dim)
            x(:,dim+1) = x(:,dim);
            dim = dim+1;
        end
    else
        if signalwavelet.internal.isodd(dim)
            x(dim+1,:) = x(dim,:);
            dim = dim+1;
        end
    end
    xout = makePer(dim,lf,x,isAddCol);
end
end

function xout = makePer(lx,lf,x,isAddCol)
% Periodic Extension

% Early exit if lx >= lf
if lx >= lf
    if nargin < 4
        xout = [x(lx-lf+1:lx),x(1:lx),x(1:lf)];        
    else
        if isAddCol
            xout = x(:,[lx-lf+1:lx, 1:lx, 1:lf]);
        else
            xout = x([lx-lf+1:lx, 1:lx, 1:lf],:);
        end
    end
    return;
end

nElements = lx+lf+abs(lx-(lx-lf+1)+1);
firstIndex = mod(lx-lf+1,lx);
if firstIndex == 0
    firstIndex = lx;
end
nCopies = floor((nElements - (lx - firstIndex + 1))/lx);
lastIndex = nElements-(lx-firstIndex) - nCopies*lx - 1;
if nargin == 3
    % 1D case
    xout = [x(firstIndex:lx), ...
        repmat(x(1:lx),1,nCopies), ...
        x(1:lastIndex)];
elseif isAddCol
    % 2D case - addCols
    xout = [x(:,firstIndex:lx), ...
        repmat(x(:,1:lx),1,nCopies), ...
        x(:,1:lastIndex)];
else
    % 2D case - addRows
    xout = [x(firstIndex:lx,:); ...
        repmat(x(1:lx,:),nCopies,1); ...
        x(1:lastIndex,:)];
end
end

function xout = makeSym(lx,lf,x,isAddCol)
% Symmetric Extension
% Constructed as -> [pre_residue,pre,main,post,post_residue]
% e.g:
% [2,3,3,2,1,1,2,3,3,2,1,1,2,3,3,2]
% Pre_Residue = [2,3]
% Pre = [3,2,1]
% Main = [1,2,3,3,2,1]
% Post = [1,2,3]
% Post_Residue = [3,2]
% A "Full Copy" is a complete symmetric set e.g. [1,2,3 | 3,2,1]
% The case of lx < lf is also accounted for. In this case, "Pre" would also
% have some "Full Copies" that are added into "Main".


% Early exit if lx >= lf
if lx >= lf
    if nargin < 4
        xout = [x(lf:-1:1), x(1:lx), x(lx:-1:lx-lf+1)];
    else
        if isAddCol
            xout = x(:,[lf:-1:1, 1:lx, lx:-1:lx-lf+1]);
        else
            xout = x([lf:-1:1, 1:lx, lx:-1:lx-lf+1],:);
        end
    end
    return;
end

nElements = lx+lf+lf;
mainStartIndex = lf + 1;
nCopiesFromMainToPost = (nElements - mainStartIndex + 1)/lx;
nFullCopiesFromMainToPost = floor(floor(nCopiesFromMainToPost)/2);

nPostElements = nElements - (mainStartIndex + 2*nFullCopiesFromMainToPost*lx) + 1;
if nPostElements <= lx
    post = matlab.internal.ColonDescriptor(1,1,nPostElements);
    postResidue = matlab.internal.ColonDescriptor(0,0,0);
else
    post = matlab.internal.ColonDescriptor(1,1,lx);
    postResidue = matlab.internal.ColonDescriptor(lx,-1,lx - (nPostElements - lx) + 1);
end

nPreElements = mainStartIndex - 1;
nCopiesPre = nPreElements/lx;
nFullCopiesPre = floor(floor(nCopiesPre)/2);
nPreResidue = nPreElements - 2*nFullCopiesPre*lx;
if nPreResidue <= lx
    pre = matlab.internal.ColonDescriptor(nPreResidue,-1,1);
    preResidue = matlab.internal.ColonDescriptor(0,0,0);
else
    pre = matlab.internal.ColonDescriptor(lx,-1,1);
    preResidue = matlab.internal.ColonDescriptor(lx - (nPreResidue - lx - 1),1,lx);
end

if nargin == 3
    % 1D case
    xout = [x(preResidue), ... % PreResidue
        x(pre), ... % Pre
        repmat([x(1:lx),flip(x(1:lx))],1,nFullCopiesPre + nFullCopiesFromMainToPost), ... % Main (Accounts for lx < lf)
        x(post), ... % Post
        x(postResidue)]; % Post Residue
elseif isAddCol
    % 2D case - addCols
    xout = [x(:,preResidue), ... % PreResidue
        x(:,pre), ... % Pre
        repmat([x(:,1:lx),flip(x(:,1:lx),2)],1,nFullCopiesPre + nFullCopiesFromMainToPost), ... % Main (Accounts for lx < lf)
        x(:,post), ... % Post
        x(:,postResidue)]; % Post Residue
else
    % 2D case - addRows
    if nFullCopiesPre + nFullCopiesFromMainToPost ~= 0
        xout = [x(preResidue,:); ... % PreResidue
            x(pre,:); ... % Pre
            repmat([x(1:lx,:);flip(x(1:lx,:))],nFullCopiesPre + nFullCopiesFromMainToPost,1); ... % Main (Accounts for lx < lf)
            x(post,:); ... % Post
            x(postResidue,:)]; % Post Residue
    else
        xout = [x(preResidue,:); ... % PreResidue
            x(pre,:); ... % Pre
            x(post,:); ... % Post
            x(postResidue,:)]; % Post Residue
    end
end
end