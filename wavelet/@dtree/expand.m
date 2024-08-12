function t = expand(t)
%EXPAND Expand data tree.
%   NEWT = EXPAND(T) decomposes the initial data
%   associated with the root of the data tree T
%   to obtain terminal nodes datas.
%
%   During the splitting, EXPAND computes the
%   general information associated with each
%   node of T.
%
%   See also DTREE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 22-Dec-2006.
%   Copyright 1995-2020 The MathWorks, Inc.

[order,depth] = get(t,'order','depth');
[tnrank,nodes] = findactn(t);
n2dec = nodes(tnrank==0);
nbTOT = nbnodes(order,depth);
x     = fmdtree('getinit',t);
ndimX = ndims(x);
last_COL_dim = ndimX+1;
aninf = defaninf(t,0,{x});
t     = fmdtree('setinit',t,aninf,'expand');
data  = cell(nbTOT,1);
data{1} = x;
for j=1:length(n2dec)
    node = n2dec(j);
    ind  = node+1;
    x = data{ind};    
    tnval = split(t,node,x);
    child = node*order+(1:order)';
    i_c   = child+1;
    for k =1:order
        data{i_c(k)} = tnval{k};
        t.allNI(i_c(k),2:last_COL_dim) = size(tnval{k});
    end
    data{ind} = {};
    aninf = defaninf(t,child,tnval);
    t.allNI(i_c,last_COL_dim+1:end) = aninf;
end
ind_an  = allnodes(t)+1;
ind_tn  = leaves(t)+1;

sizes   = t.allNI(ind_tn,2:last_COL_dim);
t.allNI = t.allNI(ind_an,:);
lenTOT  = sum(prod(sizes,2));
tmpTMP = zeros(1,lenTOT);
iBEG = 1;
for k=1:length(ind_tn)
    idx = ind_tn(k);
    iEND = iBEG + prod(sizes(k,:),2)-1;
    tmpTMP(iBEG:iEND) = data{idx}(:)';
    iBEG = iEND + 1;
end
t = fmdtree('tn_write',t,sizes,tmpTMP);

%----------------------------------------------
function nb = nbnodes(order,depth)

switch order
  case 0    , nb = 0;
  case 1    , nb= depth;
  otherwise , nb = (order^(depth+1)-1)/(order-1);
end
%----------------------------------------------
