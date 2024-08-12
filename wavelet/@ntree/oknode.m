function [r,idx] = oknode(t,n,type)
%OKNODE True for existing node.
%   R = OKNODE(T,N) returns 1's for nodes N which
%   exist in the tree T, and 0's for others.
%
%   R = OKNODE(...,TYPE) returns 1's for nodes N of
%   type: TYPE which exist in the tree T, and 0's
%   for others. Valid values for TYPE are:
%       'tn'  - for a terminal node.
%       'ntn' - for a non terminal node.
%       'all' - for a node.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-May-2003.
%   Last Revision: 23-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

idx = []; 
if n==0 
    r = true; return;
elseif (n<0) || isempty(n)
    r = false; return;
end

r = false;
order = t.order;
depth = t.depth;
tn    = t.tn;
switch type
    case 'ntn' 
        tn = floor((tn-1)/order);
        depthBEG = depth - 1;
        depthEND = 0;
    case 'tn'
        depthBEG = depth;
        depthEND = depthBEG;
    otherwise
        depthBEG = depth;
        depthEND = 0;
end
for d = depthBEG:-1:depthEND
    idx = find(n==tn);
    if ~isempty(idx)
        r = true; break
    else
        tn = floor((tn-1)/order);
    end
end
