function nottn = noleaves(t,flagdp) %#ok<INUSD>
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

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-May-2003.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 1
    flagdp = convertStringsToChars(flagdp);
end

if nargin==1 , flagdp = false; else , flagdp = true; end 
nottn = descendants(t,0,'not_tn',flagdp);
