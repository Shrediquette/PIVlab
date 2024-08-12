function asc = nodeasc(t,nodes,varargin)
%NODEASC Node ascendants.
%   A = NODEASC(T,N) returns the indices of all
%   ascendants of the node N in the tree T.
%   N can be the index node or the depth and position of node. 
%   A is a column vector with A(1) = index of node N. 
%
%   A = NODEASC(T,N,'deppos') is a matrix which
%   contains the depths and positions of all ascendants.
%   A(i,1) is the depth of i-th ascendant and
%   A(i,2) is the position of i-th ascendant.
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   See also NODEDESC, NODEPAR, WTREEMGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

ok = all(isnode(t,nodes));
if ~ok
    error(message('Wavelet:FunctionArgVal:Invalid_NodVal'));
end
asc = wtreemgr('nodeasc',t,nodes,varargin{:});
