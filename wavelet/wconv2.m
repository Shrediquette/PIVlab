function y = wconv2(type,x,f,shape)
%WCONV2 2-D Convolution.
%   Y = WCONV2(TYPE,X,F) performs the 2-D convolution
%   of X and F.
%
%   Y = WCONV2('r',X,F) or Y = WCONV2('row',X,F)
%   if X is a matrix and F a vector, performs 
%   the 1-D convolution of the rows of X and F.
%
%   Y = WCONV2('c',X,F) or Y = WCONV2('col',X,F)
%   if X is a matrix and F a vector, performs 
%   the 1-D convolution of the columns of X and F.
%
%   Y = WCONV2(TYPE,X,F) with TYPE = {2,'2','2d' or '2D'}
%   and if X and F are matrices, performs the 2-D 
%   convolution of X and F.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. 06-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

%#codegen

if nargin<4 , shape = 'full'; end
switch type
    case 'row' , y = conv2(x,f(:)',shape);
    case 'col' , y = conv2(x',f(:)',shape); y = y';
    case '2d'  , y = conv2(x,f,shape);
end
