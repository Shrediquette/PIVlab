function tab = tabofasc(nodes,order,level)
%TABOFASC Table of ascendants of nodes.
%   TAB = TABOFASC(NODES,ORDER,LEVEL)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-96.
%   Last Revision: 16-Jul-1998.
%   Copyright 1995-2020 The MathWorks, Inc.

tab = zeros(length(nodes),level+1);
tab(:,1) = nodes;
for j = 1:level
    tab(:,j+1) = floor((tab(:,j)-1)/order);
end

%----------------------------------------%
% If index(n) = j , then 
% index(parent(n)) = floor((j-1)/order)
%
% example: order = 2
%
%       7        7  3  1  0 -1
%      17       17  8  3  1  0
% tn = 18  ==>  18  8  3  1  0
%       4        4  1  0 -1 -1
%       2        2  0 -1 -1 -1
%------------------------------------------%
