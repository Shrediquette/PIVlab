function x = wprec(wpt)
%WPREC Wavelet packet reconstruction 1-D.
%   X = WPREC(T) returns the reconstructed vector
%   corresponding to a wavelet packet tree T.
%
%   See also WPDEC, WPDEC2, WPJOIN, WPREC2, WPSPLT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

[~,x] = nodejoin(wpt);
