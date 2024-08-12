function [w,h] = wpropimg(is,wmax,hmax,in4)
%WPROPIMG Give image proportions.
%   [w,h] = wpropimg(is,wmax,hmax,in4)
%
%   is      = image size
%   wmax    = maximum width possible
%   hmax    = maximum height possible
%
%   in4 = 'pixels' or in4 = 'normalized'
%   wpropimg(is,wmax,hmax) is equivalent to 
%   wpropimg(is,wmax,hmax,'normalized')
%
%   w       = image width
%   h       = image height

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 01-Jun-1998.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin==3 , in4 = 'normalized'; end
in4 = lower(in4);
switch in4
  case 'pixels' , td = [1 1];
  otherwise     , td = mextglob('get','Terminal_Prop');
end
a = (td(2)*hmax*is(1))/(td(1)*wmax*is(2));
w = wmax*min(1,a);
h = hmax*min(1,1/a);
