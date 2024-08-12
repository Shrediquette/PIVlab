function nottn = noleaves(t,varargin)
%NOLEAVES Determine nonterminal nodes.
%   N = NOLEAVES(T) returns the indices of nonterminal 
%   nodes of the tree T (i.e., nodes, which are not leaves).
%   N is a column vector.
%
%   N = NOLEAVES(T,'dp') returns a matrix N, which
%   contains the depths and positions of nonterminal nodes.
%   N(i,1) is the depth of i-th nonterminal node and
%   N(i,2) is the position of i-th nonterminal node.
%
%   See also LEAVES.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Oct-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

nottn = wtreemgr('noleaves',t,varargin{:}); 
