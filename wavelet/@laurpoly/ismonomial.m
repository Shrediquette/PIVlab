function R = ismonomial(P)
%ISMONOMIAL True for a monomial Laurent polynomial.
%   R = ISMONOMIAL(P) returns 1 if P is a Laurent
%   polynomial which is a monomial and 0 if not.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 30-May-2001.
%   Last Revision 13-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

R = length(P.coefs)<2;
