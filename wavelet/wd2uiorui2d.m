function X = wd2uiorui2d(opt,X)
%WD2UIORUI2D Convert from double double to uint8 .
%   X = WD2UIORUI2D(OPT,X)
%   If X is a N x M x 3 array , X = WD2UIORUI2D('d2uint',X) casts
%   the variable X to uint8.
%   X = WD2UIORUI2D('uint2d',X) casts the variable X to double. 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  28-Dec-2006.
%   Last Revision: 29-Dec-2006.
%   Copyright 1995-2020 The MathWorks, Inc.

switch opt
    case 'd2uint' , if ~ismatrix(X) , X = uint8(X); end
    case 'uint2d' , X = double(X);
end
