function x = recons(t,node,x,sizes,edges) %#ok<INUSL>
%RECONS Reconstruct node coefficients.
%   Y = RECONS(T,N,X,S,E) reconstructs the data X 
%   associated with the node N of the data tree T,
%   using sizes S and the edges values E.
%   S contains the size of datas associated with
%   each ascendant of N.
%   The children of a node F are numbered from left 
%   to right: [0, ... , ORDER-1].
%   The edge value between F and a child C is the
%   child number.
%
%   Caution: 
%   This method has to be overloaded for a
%   concrete class of objects.
%   ----------
%   For the Class DTREE the RECONS method returns
%   the data of the most left child of T if all edges
%   are 0. Otherwise, a matrix of zeros with the same
%   size as the original data is returned.
%   ----------

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Oct-96.
%   Last Revision: 04-Jun-1998.
%   Copyright 1995-2020 The MathWorks, Inc.

nb_up = length(edges);
if any(edges) , x = zeros(sizes(nb_up,:)); end
