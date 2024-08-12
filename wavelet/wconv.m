function y = wconv(type,x,f,shape)
%WCONV  1-D or 2-D Convolution.
%   Y = WCONV(TYPE,X,F) performs the 1-D or 2-D
%   convolution of X and F.
%
%   Y = WCONV(TYPE,X,F) with TYPE = {1,'1','1d' or '1D'}
%   and if X and F are vectors, performs the 1-D 
%   convolution of X and F.
%    
%   Y = WCONV(TYPE,X,F) with TYPE = {2,'2','2d' or '2D'}
%   and if X and F are matrices, performs the 2-D 
%   convolution of X and F.
%
%   Y = WCONV('r',X,F) or Y = WCONV('row',X,F)
%   if X is a matrix and F a vector, performs 
%   the 1-D convolution of the rows of X and F.
%
%   Y = WCONV('c',X,F) or Y = WCONV('col',X,F)
%   if X is a matrix and F a vector, performs 
%   the 1-D convolution of the columns of X and F.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Nov-97.
%   Last Revision: 19-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.


if nargin<4
    shape = 'full';
end

[type, shape] = convertStringsToChars(type, shape);

switch type
    case {1,'1','1d','1D'}
        y = conv2(x(:)',f(:)',shape); 
        if size(x,1)>1
            y = y';
        end
    case {2,'2','2d','2D'}
        y = conv2(x,f,shape); 
    case {'r','row'}
        y = conv2(x,f(:)',shape); 
    case {'c','col'}
        y = conv2(x',f(:)',shape); 
        y = y';
end
