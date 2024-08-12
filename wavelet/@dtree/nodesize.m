function s = nodesize(t,nodes)
%NODESIZE Size of nodes in a DTREE object.
%   S = NODESIZE(T,N) gives the size of the data
%   associated with the node(s) N.
%
%   CAUTION: N contains indices of node(s).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 23-May-2003.
%   Last Revision: 23-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

ptrINFO = 2:3;
idx = gidxsint(t.allNI(:,1),nodes);
s   = t.allNI(idx,ptrINFO);
