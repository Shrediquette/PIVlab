function C = lp2num(P)
%LP2NUM Coefficients of a Laurent polynomial object.
%   C = LP2NUM(P) returns a vector C whose elements are 
%   the coefficients of the Laurent polynomial object P.
%
%   If L is the length of the vector C, P represents 
%   the following Laurent polynomial:
%      P(z) = C(1)*z^d + C(2)*z^(d-1) + ... + C(L)*z^(d-L+1)
%      where d = powers(P,'max')
%
%   See also GET.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Apr-2001.
%   Last Revision 08-Jul-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

C = P.coefs;
