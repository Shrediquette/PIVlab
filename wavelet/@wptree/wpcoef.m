function x = wpcoef(wpt,node)
%WPCOEF Wavelet packet coefficients.
%   X = WPCOEF(T,N) returns the coefficients associated
%   with the node N of the wavelet packet tree T.
%   If N doesn't exist, X = [];
%
%   X = WPCOEF(T) is equivalent to X = WPCOEF(T,0) 
%
%   See also WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin==1, node = 0; end
[~,x] = nodejoin(wpt,node);
