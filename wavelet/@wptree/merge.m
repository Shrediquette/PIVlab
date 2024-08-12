function x = merge(t,node,tnd)
%MERGE Merge (recompose) the data of a node.
%   X = MERGE(T,N,TNDATA) recomposes the data X 
%   associated to the node N of the wavelet packet tree T,
%   using the datas associated to the children of N.
%
%   TNDATA is a cell array (ORDER x 1) or (1 x ORDER)
%   such that TNDATA{k} contains the data associated to
%   the kth child of N.
%
%   The method uses IDWT (respectively IDWT2) for
%   one dimensional (respectively two dimensional) datas.
%
%   This method overloads the DTREE method.
 
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

order = treeord(t);
s = nodesize(t,node);
Lo_R = t.wavInfo.Lo_R;
Hi_R = t.wavInfo.Hi_R;
switch order
  case 2 , x = idwt(tnd{1},tnd{2},Lo_R,Hi_R,max(s));
  case 4 , x = idwt2(tnd{1},tnd{2},tnd{3},tnd{4},Lo_R,Hi_R,s);
end
