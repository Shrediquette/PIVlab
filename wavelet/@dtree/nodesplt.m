function [t,child,tndata] = nodesplt(t,node)
%NODESPLT Split (decompose) node.
%   T = NODESPLT(T,N) returns the modified tree T
%   corresponding to the decomposition of the node N.
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   This method overloads the NTREE method and 
%   calls the right overloaded method SPLIT.
%
%   See also SPLIT, NODEJOIN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 22-Dec-2006.
%   Copyright 1995-2020 The MathWorks, Inc.

[n_rank,node] = findactn(t,node,'a_tn');
if isempty(n_rank)
    child  = [];
    tndata = [];
    return
end
order  = treeord(t);
t_tree = get(t,'ntree');
node   = depo2ind(order,node);
x      = read(t,'data',node);
t_tree = nodesplt(t_tree,node);
t      = set(t,'ntree',t_tree);
child  = node*order+(1:order)';
tndata = split(t,node,x);
sizes  = zeros(order,ndims(x));
data   = [];
for k =1:order
    sizes(k,:) = size(tndata{k});
end
idxBeg = 1;
for k =1:order
    idxEnd = idxBeg + prod(sizes(k,:))-1;
    data(idxBeg:idxEnd) = tndata{k}(:)';
    idxBeg = idxEnd+1;
end
t     = fmdtree('tn_write',t,n_rank,sizes,data);
aninf = defaninf(t,child,tndata);
t     = fmdtree('an_write',t,[child sizes aninf],'add');
