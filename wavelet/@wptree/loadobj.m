function B = loadobj(A)
%WPTREE/LOADOBJ Called by load.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Sep-2001.
%   Last Revision: 08-Feb-2008.
%   Copyright 1995-2020 The MathWorks, Inc.

if strcmp(class(A),'wptree')
   if ~isobject(A.dtree) , A.dtree = dtree(A.dtree); end
   B = A;
   
else 
   % object definition has changed
   % or the parent class definition has changed?
   try
       
   catch ME
      disp(ME.message)
   end
end
