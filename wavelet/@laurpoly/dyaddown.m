function Q = dyaddown(P)
%DYADDOWN Dyadic downsampling for a Laurent polynomial.
%   Q = DYADDOWN(P) returns the Laurent polynomial Q obtained by
%   a "downsampling" on the Laurent polynomial P.
%   if   P(z) = ... C(-2)*z^(-2) + C(-1)*z^(-1) + C(0) + ...
%               ... C(+1)*z^(+1) + C(+2)*z^(+2) + ... 
%   then Q(z) = ... C(-2)*z^(-1) + C(0) + C(+2)*z^(+1) + ... 
%   
%   See also DYADUP, EVEN, MODULATE, NEWVAR, REFLECT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 07-Feb-2003.
%   Last Revision 15-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% DYADDOWN(P) == EVEN(P)
%-----------------------
Q = newvar(P,'sqz');
