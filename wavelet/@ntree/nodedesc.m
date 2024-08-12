function desc = nodedesc(t,nodes,flagdp) %#ok<INUSD>
%NODEDESC Node descendants.
%   D = NODEDESC(T,N) returns the indices of all the
%   descendants of the node N in the tree T.
%   N can be the index node or the depth and position of node. 
%   D is a column vector with D(1) = index of node N. 
%
%   D = NODEDESC(T,N,'deppos') is a matrix that
%   contains the depths and positions of all descendants.
%   D(i,1) is the depth of i-th descendant and
%   D(i,2) is the position of i-th descendant.
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   See also NODEASC, NODEPAR, WTREEMGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-May-2003.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

ok = all(isnode(t,nodes));
if ~ok
    error(message('Wavelet:FunctionArgVal:Invalid_NodVal'));
end
if nargin==2 , flagdp = false; else flagdp = true; end
desc = descendants(t,nodes,'all',flagdp);
