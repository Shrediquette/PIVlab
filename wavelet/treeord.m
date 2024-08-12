function order = treeord(t)
%TREEORD Tree order.
%   ORD = treeord(T) returns the order ORD of the tree T.
%
%   See also WTREEMGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

order = wtreemgr('order',t);
