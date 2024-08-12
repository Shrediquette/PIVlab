function [t,x] = wpjoin(t,node)
%WPJOIN Recompose wavelet packet.
%   WPJOIN updates the wavelet packet tree after 
%   the recomposition of a node.
%
%   T = WPJOIN(T,N) returns the modified tree T
%   corresponding to a recomposition of the node N.
%
%   T = WPJOIN(T) is equivalent to T = WPJOIN(T,0).
%
%   [T,X] = WPJOIN(T,N) also returns the coefficients
%   of the node.
%
%   [T,X] = WPJOIN(T) is equivalent to [T,X] = WPJOIN(T,0).
%
%   See also WPDEC, WPDEC2, WPSPLT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin == 1, node = 0; end
[t,x] = nodejoin(t,node);
