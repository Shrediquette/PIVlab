function tnd = split(t,node,x,varargin) %#ok<INUSL>
%SPLIT Split (decompose) the data of a terminal node.
%   TNDATA = SPLIT(T,N,X) decomposes the data X 
%   associated to the terminal node N of the 
%   wavelet packet tree T.
%   TNDATA is a cell array (ORDER x 1) such that
%   TNDATA{k} contains the data associated to
%   the kth child of N.
%   
%   The method uses DWT (respectively DWT2) for
%   one dimensional (respectively two dimensional) datas.
%
%   This method overloads the DTREE method.
 
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

order = treeord(t);
tnd   = cell(order,1);
Lo_D  = t.wavInfo.Lo_D;
Hi_D  = t.wavInfo.Hi_D;
switch order
   case 2 , [tnd{1},tnd{2}] = dwt(x,Lo_D,Hi_D);
   case 4 , [tnd{1},tnd{2},tnd{3},tnd{4}] = dwt2(x,Lo_D,Hi_D);
end
