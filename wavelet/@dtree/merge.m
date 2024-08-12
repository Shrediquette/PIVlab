function x = merge(t,node,tnd) %#ok<INUSL>
%MERGE Merge (recompose) the data of a node.
%   X = MERGE(T,N,TNDATA) recomposes the data X 
%   associated with the node N of the data tree T,
%   using the datas associated to the children of N.
%
%   TNDATA is a cell array (ORDER x 1) or (1 x ORDER)
%   such that TNDATA{k} contains the data associated with
%   the kth child of N.
%
%   Caution: 
%   This method has to be overloaded for a
%   concrete class of objects.
%   ----------
%   For the Class DTREE the MERGE method assign
%   the data of the most left child of N to N.
%   ----------

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 04-Jun-1998.
%   Copyright 1995-2020 The MathWorks, Inc.


x = tnd{1};
