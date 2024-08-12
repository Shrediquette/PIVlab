function info = defaninf(t,nodes,datas) %#ok<INUSL,INUSD>
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
%   with the node N(k).
%
%   Caution:
%   This method has to be overloaded for a
%   concrete class of objects.
%   ----------
%   For the Class DTREE the DEFANINF method assign
%   an empty matrix information to each node N(k).
%   ----------
%
%   See also DTREE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 04-Jun-1998.
%   Copyright 1995-2020 The MathWorks, Inc.

nb   = length(nodes);
info = zeros(nb,0);
