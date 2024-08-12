function y = wkeep(x,varargin)
%WKEEP  Keep part of a vector or a matrix.
%   For a vector:
%   Y = WKEEP(X,L,OPT) extracts the vector Y
%   from the vector X. The length of Y is L.
%   If OPT = 'c', 'l', or 'r', Y is the central, left, or right part, 
%   respectively, of X.
%
%   Y = WKEEP(X,L,FIRST) returns the vector X(FIRST:FIRST+L-1).
%
%   Y = WKEEP(X,L) is equivalent to Y = WKEEP(X,L,'c').
%
%   For a matrix:
%   Y = WKEEP(X,S) extracts the central part of the matrix X.
%   S is the size of Y.
%   Y = WKEEP(X,S,[FIRSTR,FIRSTC]) extracts the submatrix of
%   matrix X, of size S and starting from X(FIRSTR,FIRSTC).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

narginchk(2,4)
y = x;
sizeKept = varargin{1}(:)';
validateattributes(sizeKept,{'numeric'},{'nonempty'}, 'wkeep','L');
nbDIM = length(sizeKept);
if nbDIM<=1
    sx = length(x);
    [first,last,ok] = GetFirstLast(sx,nbDIM,varargin{:});
    if ok 
        y = y(first(1):last(1));
    end
else
    sx = size(x);
    [first,last,ok] = GetFirstLast(sx,nbDIM,varargin{:});
    if ok , y = y(first(1):last(1),first(2):last(2)); end
end


%----------------------------------------------------------------------------%
%Internal Function(s)
%----------------------------------------------------------------------------%
function [first,last,ok] = GetFirstLast(sx,nbDIM,varargin)

begInd = ones(1,nbDIM);
oneDIM = isequal(begInd,1);
s = varargin{1}(:)';
% Length of s must match length of sx
if (numel(s) > 1) && (numel(s) > numel(sx))
    error(message('Wavelet:FunctionInput:WkeepSize',numel(sx),numel(s)));
end
if ~oneDIM
    K  = find(s>sx);
    s(K) = sx(K);
    ok = ~(any(s < 0) || (any(s~=fix(s))));
else
    ok = (s>=0) && (s<sx) && (s == fix(s)); %#ok<BDSCI>
end
if ok==0 , first = begInd; last = s; return; end

nbarg = length(varargin);
if nbarg<2
    o = 'c';
else
    o = lower(varargin{2});
end

err = 0;
if ischar(o(1))
    validext = {'u','c','l','r','d'};
    validatestring(o(1),validext,'wkeep','OPT');
    switch o(1)
        case 'c'
            d = (sx-s)/2;
            if nbarg<3
                if length(o)>1 
                    side = o(2:end); 
                else
                    side = 'l';
                end
            else
                side = varargin{3};
            end
            if oneDIM
                [first,last] = GetFirst1D(side,sx,d);
            else
                if length(side)<2 , side(2) = 0; end
                first = zeros(1,2);
                last  = zeros(1,2);
                for k = 1:2
                    [first(k),last(k)] = GetFirst1D(side(k),sx(k),d(k));
                end
            end
            
        case {'l','u'} 
            first = begInd;
            last = s;
        case {'r','d'} 
            first = sx-s+1; 
            last = sx;
        otherwise
            err = 1;
    end
else
    first = o; last = first+s-1;
    if ~isequal(first,fix(first)) || any(first<1) || any(last>sx)
        err = 1;
    end
end
if err
    errargt(mfilename,'invalid argument','msg');
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
%----------------------------------------------------------------------------%
function [first,last] = GetFirst1D(side,s,d)

switch side
    case {'u','l','0',0} 
        first = 1+floor(d); 
        last = s-ceil(d);
    case {'d','r','1',1} 
        first = 1+ceil(d); 
        last = s-floor(d);
    otherwise
        first = 1+floor(d); 
        last = s-ceil(d);  % Default is left side
end
%----------------------------------------------------------------------------%
