function par = nodepar(t,nodes,flagdp) %#ok<INUSD>
%NODEPAR Node parent.
%   F = NODEPAR(T,N) returns the indices of the "parent(s)"
%   of the nodes N in the tree T.
%   N can be a column vector containing the indices of nodes
%   or a matrix which contains the depths and positions of nodes.
%   In the last case, N(i,1) is the depth of i-th node 
%   and N(i,2) is the position of i-th node.
%
%   F = NODEPAR(T,N,'deppos') is a matrix, which
%   contains the depths and positions of returned nodes.
%   F(i,1) is the depth of i-th node and
%   F(i,2) is the position of i-th node.
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   Caution : NODEPAR(T,0) or NODEPAR(T,[0 0]) returns -1.
%         NODEPAR(T,0,'deppos') or  NODEPAR(T,[0 0],'deppos')
%         returns [-1 0].
%
%   See also NODEASC, NODEDESC, WTREEMGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-May-2003.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

ok = all(isnode(t,nodes));
if ~ok
    error(message('Wavelet:FunctionArgVal:Invalid_NodVal'));
end
order = t.order;
nodes = depo2ind(order,nodes);
par   = floor((nodes-1)/order);
if nargin==3 , [par(:,1),par(:,2)] = ind2depo(order,par); end
