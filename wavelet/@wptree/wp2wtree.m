function [wpt,n2m] = wp2wtree(wpt)
%WP2WTREE Extract wavelet tree from wavelet packet tree.
%   T = WP2WTREE(T) computes the modified tree T
%   corresponding to the wavelet decomposition tree.
%
%   See also WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 23-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

depth = treedpth(wpt);
if depth==0
    n2m = [];
    return
end
order = treeord(wpt);
nottn = noleaves(wpt,'dp');
K     = 0<nottn(:,2) & nottn(:,2)<order;
n2m   = depo2ind(order,nottn(K,:));
wpt   = nodejoin(wpt,n2m);
