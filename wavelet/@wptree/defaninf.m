function info = defaninf(t,nodes,data)
%DEFANINF Define node infos (all nodes).
%   INF = DEFANINF(T,N,D) returns an array of
%   numbers which contains information related
%   to the nodes N.
%
%   N can be a column vector containing the indices of nodes
%   or a matrix, which contains the depths and positions of nodes.
%   In the last case, N(i,1) is the depth of i-th node 
%   and N(i,2) is the position of i-th node.
%
%   D is a cell array containing datas.
%   D{k} is the data related to the node N(k).
%
%   INF(k,:) is the computed information associated
%   to the node N(k).
%
%   This method overloads the DTREE method.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 14-Jul-1999.
%   Copyright 1995-2020 The MathWorks, Inc.

nb   = length(nodes);
info = zeros(nb,2);
[entname,entpar]  = read(t,'entname','entpar');
for k = 1:nb
    info(k,:) = [wentropy(data{k},entname,entpar) , NaN];
end
