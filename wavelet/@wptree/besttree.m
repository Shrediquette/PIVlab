function [wpt,ento,n2m] = besttree(wpt)
%BESTTREE Best wavelet packet tree.
%   BESTTREE computes the optimal sub-tree of an initial tree
%   with respect to an entropy type criterion.
%   The resulting tree may be much smaller than the initial one.
%
%   T = BESTTREE(T) computes the modified tree T
%   corresponding to the best entropy value.
%
%   [T,E] = BESTTREE(T) returns the best tree T
%   and in addition, the best entropy value E.
%   The optimal entropy of the node whose index is j-1
%   is E(j).
%
%   [T,E,N] = BESTTREE(T) returns the best tree T,
%   entropy value E and in addition, the vector N
%   containing the indices of the merged nodes.
% 
%   See also BESTLEVT, WENTROPY, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 23-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

order = treeord(wpt);
tn = leaves(wpt);
an     = read(wpt,'an');
tn_ind = gidxsint(an,tn);
ent    = read(wpt,'ent');
ento   = NaN*ones(size(ent));
rec    = 2*ones(size(an));
rec(tn_ind)  = ones(size(tn));
ento(tn_ind) = ent(tn_ind);

J = wrev(find(rec==2));
for k=1:length(J)
    ind_n   = J(k);
    node    = an(ind_n);
    child   = node*order+[1:order]';
    i_child = gidxsint(an,child);
    echild  = sum(ento(i_child));
    if echild < ent(ind_n)
       ento(ind_n) = echild;
       rec(ind_n) = 2;
    else
       ento(ind_n)  = ent(ind_n);
       rec(ind_n)   = rec(i_child(1))+2;
       rec(i_child) = -rec(i_child);
    end
end
wpt = write(wpt,'ento',ento);
n2m = wrev(an(rec>2));
wpt = nodejoin(wpt,n2m);
ento = read(wpt,'ento');
