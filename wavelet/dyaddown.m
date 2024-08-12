function y = dyaddown(x,IN2,IN3)
%DYADDOWN Dyadic downsampling.
%   Y = DYADDOWN(X,EVENODD) where X is a vector, and returns
%   a version of X that has been downsampled by 2.
%   Whether Y contains the even- or odd-indexed samples
%   of X depends on the value of positive integer EVENODD:
%   If EVENODD is even, then Y(k) = X(2k).
%   If EVENODD is odd,  then Y(k) = X(2k-1).
%
%   Y = DYADDOWN(X) is equivalent to Y = DYADDOWN(X,0)
%
%   Y = DYADDOWN(X,EVENODD,'type') or 
%   Y = DYADDOWN(X,'type',EVENODD) where X is a matrix,
%   return a version of X obtained by suppressing columns
%   (or rows or both) if 'type' = 'c' (or 'r' or 'm'
%   respectively), according to the parameter EVENODD, which
%   is as above.
%
%   Y = DYADDOWN(X) is equivalent to
%   Y = DYADDOWN(X,0,'c').
%   Y = DYADDOWN(X,'type') is equivalent to
%   Y = DYADDOWN(X,0,'type').
%   Y = DYADDOWN(X,EVENODD) is equivalent to
%   Y = DYADDOWN(X,EVENODD,'c').
%
%             |1 2 3 4|                                |2 4|
%   When  X = |2 4 6 8|  we obtain:  DYADDOWN(X,'c') = |4 8|
%             |3 6 9 0|                                |6 0|
%
%                       |1 2 3 4|                        |1 3|
%   DYADDOWN(X,'r',1) = |3 6 9 0|  , DYADDOWN(X,'m',1) = |3 9|
%
%   See also DYADUP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 13-Sep-2007.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if nargin > 1
    IN2 = convertStringsToChars(IN2);
end

if nargin > 2
    IN3 = convertStringsToChars(IN3);
end

def_evenodd = 0;
nbin  = nargin-1;
[r,c] = size(x);

if min(r,c)<=1
    dim = 1;
    switch nbin
      case 1 , if ischar(IN2) , dim = 2; end
      case 2 , if ischar(IN2) || ischar(IN3) , dim = 2; end
    end
else
    dim = 2;
end

if dim==1
    switch nbin
        case 0 , p = def_evenodd;
        case 1 , p = IN2;
        otherwise
            error(message('Wavelet:FunctionInput:TooMany_ArgNum'));
    end
    y = x(2-rem(p,2):2:end);
else
    switch nbin
        case 0
            o = 'c'; p = def_evenodd;

        case 1 
            if ischar(IN2)
                p = def_evenodd; o = lower(IN2(1));
            else
                p = IN2; o = 'c';
            end

        otherwise
            if ischar(IN2)
                p = IN3; o = lower(IN2(1));
            else
                p = IN2; o = lower(IN3(1));
            end
    end
    first = 2-rem(p,2);
    switch o
        case 'c'  , y = x(:,first:2:c);
        case 'r'  , y = x(first:2:r,:);
        case 'm'  , y = x(first:2:r,first:2:c);
        otherwise
            error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
    end
end
