function [sx,sy] = mngcoor(x,y,axe,in4) %#ok<INUSL>
%MNGCOOR Manage display of coordinates values.
%   [sx,sy] = mngcoor(x,y) or
%   [sx,sy] = mngcoor(x,y,axe) or 
%   [sx,sy] = mngcoor(x,y,axe,opt)
%   (x,y)   = point coordinates in the axes axe (not used).
%   opt = 'real' or 'int'   
%   (sx,sy) = strings which give (x,y) position

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 02-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if (nargin<4) || isempty(in4)
   mode = 'r';
else
   mode = lower(in4(1));
end
switch mode
  case 'r'
    sx = ['X = ' , wstrcoor(x,5,6)];
    sy = ['Y = ' , wstrcoor(y,5,6)];
    
  case 'i'
    sx = sprintf('X = %0.f',round(x));
    sy = sprintf('Y = %0.f',round(y));

  otherwise
    sx = [];
    sy = [];
end
