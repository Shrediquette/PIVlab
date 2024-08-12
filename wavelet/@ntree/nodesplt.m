function t = nodesplt(t,node)
%NODESPLT Split (decompose) node(s).
%   T = NODESPLT(T,N) returns the modified tree T
%   corresponding to the decomposition of the node(s) N.
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   See also NODEJOIN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

[n_rank,node] = findactn(t,node,'a_tn');
nbn = length(n_rank);
if nbn==0 , return; end

order = treeord(t);
tn = leaves(t);
tmp = tn(1:n_rank(1)-1);
for k=1:nbn-1
    i_child = (node(k)*order)+[1:order]';
    tmp     = [tmp ; i_child ; tn(n_rank(k)+1:n_rank(k+1)-1)];
end
tn = [tmp ; (node(nbn)*order)+[1:order]' ; tn(n_rank(nbn)+1:end)];

switch order
  case 1    , depth = max(tn);
  otherwise , depth = floor(log((order-1)*max(tn)+1)/log(order));
end
t = set(t,'depth',depth,'tn',tn);
