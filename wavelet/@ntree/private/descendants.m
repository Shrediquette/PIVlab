function tab = descendants(t,node,type,flagdp)
%DESCENDANTS Construction of descendants table.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-May-2003.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

order = treeord(t);
depth = treedpth(t);
tn = leaves(t);
node = depo2ind(order,node);

% Construction of ascendants table.
%----------------------------------
tab = zeros(length(tn),depth+1);
tab(:,1) = tn;
for j = 1:depth
    tab(:,j+1) = floor((tab(:,j)-1)/order);
end

% Find descendants.
%------------------
[row,col] = find(tab==node);
switch type
   case 'all'    , first = 1; 
   case 'not_tn' , first = 2; row = row(col>2);
end
last = max(col)-1;
tab  = tab(row,first:last);
tab  = tab(:);
tab  = tab(tab>node);
tab  = [node ; wunique(tab)];
if nargin==4 && flagdp
    [tab(:,1),tab(:,2)] = ind2depo(order,tab);
end
