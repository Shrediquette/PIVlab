function x = wprec2(wpt)
%WPREC2 Wavelet packet reconstruction 2-D.
%   X = WPREC2(T) returns the reconstructed vector
%   corresponding to a wavelet packet tree T.
%
%   NOTE: If T is obtained from an indexed image analysis
%   (respectively a truecolor image analysis) then X is an
%   m-by-n matrix (respectively an m-by-n-by-3 array).
%   For more information on image formats, see the reference
%   pages of IMAGE and IMFINFO functions.
%
%   See also WPDEC, WPDEC2, WPJOIN, WPREC, WPSPLT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 16-Sep-2007.
%   Copyright 1995-2020 The MathWorks, Inc.

[~,x] = nodejoin(wpt);
if ~ismatrix(x)
    x(x<0) = 0;
    x = uint8(x);    
end


