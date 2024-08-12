function [wpt,ento,n2m] = bestlevt(wpt)
%BESTLEVT Best level wavelet packet tree.
%   BESTLEVT computes the optimal complete sub-tree of an
%   initial tree with respect to an entropy type criterion.
%   The resulting complete tree may be of smaller depth
%   than the initial one.
%
%   T = BESTLEVT(T) computes the modified tree T
%   corresponding to the best level tree decomposition.
%
%   [T,E] = BESTLEVT(T) returns best tree T
%   and in addition, the best entropy value E.
%   The optimal entropy of the node whose index is j-1
%   is E(j).
%
%   See also BESTTREE, WENTROPY, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 23-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

order = treeord(wpt);
tn = leaves(wpt);
[dtn,~]  = ind2depo(order,tn);
dmin       = min(dtn);
nottn      = noleaves(wpt,'dp');
K          = nottn(:,1) == dmin;
if ~isempty(K)
    n2m = depo2ind(order,nottn(K,:));
else
    n2m = [];
end

ento = Inf;
for d=dmin:-1:0
    nodes = depo2ind(order,[d 0])+[0:order^d-1]';
    ent   = sum(read(wpt,'ent',nodes));
    if ent<=ento
       ento = ent;
       if d<dmin , n2m = nodes; end
    end
end

wpt = nodejoin(wpt,n2m);
ento = read(wpt,'ent');
wpt  = write(wpt,'ento',ento);
