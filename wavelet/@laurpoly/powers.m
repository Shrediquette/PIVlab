function POW = powers(P,type)
%POWERS Powers of a Laurent polynomial.
%   POW = POWERS(P) returns the powers of all monomials
%   of the Laurent polynomial P.
%   POW = POWERS(P,'min') and POW = POWERS(P,'max') returns  
%   the lowest, the biggest, power of the monomials of P 
%   respectively.
%
%   See also DEGREE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Jun-2003.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

C = P.coefs;
powMAX = P.maxDEG;
powMIN = powMAX-length(C)+1;
if nargin<2 , type = 'all'; end
switch lower(type)
    case 'all' , POW = powMIN:powMAX;
    case 'min' , POW = powMIN;
    case 'max' , POW = powMAX;
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
end
