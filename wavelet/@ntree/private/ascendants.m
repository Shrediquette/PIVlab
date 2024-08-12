function tab = ascendants(nodes,order,level,flagdp)
%ASCTABLE Construction of ascendants table.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-May-2003.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% Construction of ascendants table.
%----------------------------------
tab = zeros(length(nodes),level+1);
tab(:,1) = sort(nodes);
for j = 1:level
    tab(:,j+1) = floor((tab(:,j)-1)/order);
end
%----------------------------------------%
% Now we may elimate duplicate indices
% And invalid indices (ind<0)
%----------------------------------------%
idx = [ones(1,level+1) ; diff(tab,1,1)];
tab = tab(idx>0);
tab = wunique(tab(:));
tab = tab(tab>=0);
if nargin==4 && flagdp
    [tab(:,1),tab(:,2)] = ind2depo(order,tab);
end 
%-------------------------------------------------------------%
