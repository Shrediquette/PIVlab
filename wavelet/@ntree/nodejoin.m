function [t,rec] = nodejoin(t,nodes)
%NODEJOIN Recompose node(s).
%   T = NODEJOIN(T,N) returns the modified tree T
%   corresponding to a recomposition of the nodes N.
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   T = NODEJOIN(T) is equivalent to T = NODEJOIN(T,0).
%
%   See also NODESPLT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 23-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin == 1, nodes = 0; end
%--------------------------------
order = t.order;
nodes = depo2ind(order,nodes);
rec = [];

% Elimination of terminal nodes and irrelevant nodes.
%----------------------------------------------------
nbNodes = length(nodes);
if nbNodes>1
    tn = t.tn;
    nodes = nodes(~ismember(nodes,tn));
    nodes = nodes(isnode(t,nodes));
    if isempty(nodes) , return; end
else
    r = oknode(t,nodes,'ntn');
    if r==false , return; end
    tn = t.tn;
end
depth = t.depth;

% Find new terminal nodes and new depth.
%---------------------------------------
tab = zeros(length(tn),depth+1);
tab(:,1) = tn;
for j = 1:depth
    tab(:,j+1) = floor((tab(:,j)-1)/order);
end
for k = 1:length(nodes)
    node_k = nodes(k);
    [row,col] = find(tab==node_k);
    tab(row(1),1) = node_k;
    tab(row(2:end),1) = NaN;
    if nargout==2
        rec = [rec ; recnodes(tab,row,col,node_k)];
    end
end
tn = tab(~isnan(tab(:,1)),1);
switch order
  case 1    , depth = max(tn);
  otherwise , depth = floor(log((order-1)*max(tn)+1)/log(order));
end
t = set(t,'depth',depth,'tn',tn);

% rec = wrev(unique(rec));
if nargout==2 && ~isempty(rec)
    rec = sort(rec);
    d = diff(rec);
    J = 1 + find(d>0);
    K = [J(end:-1:1) ; 1];
    rec = rec(K);
end

%--------------------------------------------
function rec = recnodes(tab,row,col,node)
%RECNODES Find nodes to be reconstructed.
%
beg_col = 2;
icol    = find(col>beg_col);
end_col = max(col(icol))-1;
rec     = tab(row(icol),beg_col:end_col);
rec     = rec(:);
rec     = [node;rec(rec>node)];
%--------------------------------------------
