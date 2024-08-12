function allN = allnodes(t,varargin)
%ALLNODES Tree nodes.
%   ALLNODES returns one of two node descriptions:
%   either indices, or depths and positions.
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   N = ALLNODES(T) returns in column vector N
%   the indices of all nodes of the tree T.
%
%   N = ALLNODES(T,'deppos') returns in matrix N
%   the depths and positions of all the nodes.
%   N(i,1) is the depth and N(i,2) is the position
%   of node i.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

allN = wtreemgr('allnodes',t,varargin{:});
