function y = wkeep2(x,siz,varargin)
%WKEEP2  Keep part of a matrix.
%   Y = WKEEP2(X,S) extracts the central part of the matrix X. 
%   S is the size of Y.
%   Y = WKEEP2(X,S,[FIRSTR,FIRSTC]) extracts the submatrix of 
%   matrix X, of size S and starting from X(FIRSTR,FIRSTC).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 07-May-2003.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
nbIn = nargin;
narginchk(2,4);
if (siz ~= fix(siz))
    error(message('Wavelet:FunctionArgVal:Invalid_SizVal', 'Arg2'));
end

y = x;
sx = size(x); sx = sx(1:2);
siz = siz(:)';siz = siz(1:2);
siz(siz>sx) = sx(siz>sx);
ok = isempty(find(siz<0,1));
if ~ok , return; end

if nbIn<3
    OPT = 'c';
else
    if isStringScalar(varargin{1})
        varargin{1} = char(varargin{1});
    end
    OPT = lower(varargin{1});
end
if ischar(OPT(1))
    switch OPT(1)
        case 'c'
            if nbIn<4
                if length(OPT)>1
                    side = OPT(2:end);
                else
                    side = 'l';
                end
            else
                side = varargin{2};
            end
            if length(side)<2 , side(2) = 'l'; end
            
            d = (sx-siz)/2;
            first = zeros(1,2);
            last  = zeros(1,2);
            for k = 1:2
                switch side(k)
                    case {'u','l','0',0}  
                        first(k) = 1+floor(d(k));
                        last(k) = sx(k)-ceil(d(k));
                    case {'d','r','1',1}  
                        first(k) = 1+ceil(d(k));
                        last(k) = sx(k)-floor(d(k));
                end
            end

        case {'l','u'}
            first = [1 1];
            last = siz;
        case {'r','d'}
            first = sx-siz+1;
            last = sx;
    end
else
    first = OPT; last = first+siz-1;
    if ~isequal(first,fix(first)) || any(first<1) || any(last>sx)
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
    end
end
if ndims(y)<3
    y = y(first(1):last(1),first(2):last(2));
else
    z = cell(0,3);
    for j = 1:3
        z{j} = y(first(1):last(1),first(2):last(2),j);
    end
    y = cat(3,z{:});
end
