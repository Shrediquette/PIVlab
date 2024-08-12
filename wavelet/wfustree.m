function t = wfustree(x,depth,wname,userdata)
%WFUSTREE Creation of a wavelet decomposition TREE.
%   T = WFUSTREE(X,DEPTH,WNAME) returns a wavelet decomposition 
%   tree T (WDECTREE Object) of order 4 corresponding to 
%   a wavelet decomposition of the matrix (image) X, at level 
%   DEPTH with a particular wavelet WNAME.
%   The DWT extension mode used is the current one.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
%-----------------
narginchk(3,4)
if nargin<4 , userdata = {}; end
dimData = 2;
dwtATTR = dwtmode('get');
WT_Settings = struct(...
    'typeWT','dwt','wname',wname,...
    'extMode',dwtATTR.extMode,'shift',dwtATTR.shift2D);

% Tree creation.
%---------------
t = wdectree(x,dimData,depth,WT_Settings,userdata);
