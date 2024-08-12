function y = wkeep1(x,len,varargin)
%WKEEP1  Keep part of a vector.
%
%   Y = WKEEP1(X,L,OPT) extracts the vector Y 
%   from the vector X. The length of Y is L.
%   If OPT = 'c' ('l' , 'r', respectively), Y is the central
%   (left, right, respectively) part of X.
%   Y = WKEEP1(X,L,FIRST) returns the vector X(FIRST:FIRST+L-1).
%
%   Y = WKEEP1(X,L) is equivalent to Y = WKEEP1(X,L,'c').

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 07-May-2003.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
nbIn = nargin;
narginchk(2,4);
if (len ~= fix(len))
    error(message('Wavelet:FunctionArgVal:Invalid_LengthVal', 'Arg2'));
end

y = x;
sx = length(x);
ok = (len >= 0) && (len < sx);
if ~ok , return; end

if nbIn<3
    OPT = 'c';
else
    if isStringScalar(varargin{1})
        varargin{1} = char(varargin{1});
    end
    OPT = lower(varargin{1});
end
if ischar(OPT)
    switch OPT
        case 'c'
            if nbIn<4
                side = 0;
            else
                side = varargin{2}; 
                if isStringScalar(side)
                    side = char(side);
                end 
            end
            d = (sx-len)/2;
            switch side
                case {'u','l','0',0}  
                    first = 1+floor(d);
                    last = sx-ceil(d);
                case {'d','r','1',1}  
                    first = 1+ceil(d);
                    last = sx-floor(d);
            end

        case {'l','u'}
            first = 1;
            last = len;
        case {'r','d'}
            first = sx-len+1;
            last = sx;
    end
else
    first = OPT; last = first+len-1;
    if (first ~= fix(first)) || (first<1) || (last>sx)
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
    end
end
y = y(first:last);
