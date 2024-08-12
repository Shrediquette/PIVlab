function [t,x] = wdtjoin(t,node)
%WDTJOIN Recompose wavelet packet.
%   WDTJOIN updates the wavelet packet tree after 
%   the recomposition of a node.
%
%   T = WDTJOIN(T,N) returns the modified tree T
%   corresponding to a recomposition of the node N.
%
%   T = WDTJOIN(T) is equivalent to T = WDTJOIN(T,0).
%
%   [T,X] = WDTJOIN(T,N) also returns the coefficients
%   of the node.
%
%   [T,X] = WDTJOIN(T) is equivalent to [T,X] = WDTJOIN(T,0).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-Mar-2003.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
nargoutchk(1,2);
narginchk(1,2);
if nargin == 1, node = 0; end

% Recomposition of the node.
[t,x] = nodejoin(t,node);
if ~ismatrix(x) && node==0
    x(x<0) = 0;
    x = uint8(x);    
end
