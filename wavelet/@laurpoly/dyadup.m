function Q = dyadup(P)
%DYADUP Dyadic upsampling for a Laurent polynomial.
%   Q = DYADUP(P) returns the Laurent polynomial Q obtained by
%   an "upsampling" on the Laurent polynomial P: Q(z) = P(z^2).
%   if   P(z) = ... C(-1)*z^(-1) + C(0) + C(+1)*z^(+1) + ... 
%   then Q(z) = ... C(-1)*z^(-2) + C(0) + C(+1)*z^(+2) + ... 
%   
%   See also DYADDOWN, MODULATE, NEWVAR, REFLECT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 07-Feb-2003.
%   Last Revision 13-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

Q = newvar(P,'z^2');
