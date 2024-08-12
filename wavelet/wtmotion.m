function callback = wtmotion(~)
%WTMOTION Wavelet Toolbox default WindowButtonMotionFcn.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-Oct-98.
%   Last Revision: 13-May-2014.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.4.4.3.6.3 $  $Date: 2010/07/29 23:15:48 $

callback = @(o,e)changeMOUSE(o,e);

function changeMOUSE(o,e) 
obj = hittest(o);
pointer = 'arrow';
if isappdata(obj,'selectPointer')

   val = getappdata(obj,'selectPointer');
   switch val
     case 'H'
         pointer = 'uddrag';
     case 'V'
         pointer = 'lrdrag';
   end
end

setptr(o,pointer);
