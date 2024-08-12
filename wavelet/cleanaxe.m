function cleanaxe(axeList)
%CLEANAXE Delete children of axes.
%   CLEANAXE(axeList) deletes all children 
%   (including ones with hidden handles) for each handle
%   in axeList.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 26-Jun-97.
%   Last Revision: 01-May-1998.
%   Copyright 1995-2020 The MathWorks, Inc.

child = allchild(axeList);
child = cat(1,child{:});
delete(child)
