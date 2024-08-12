function M = ppm(H,G)
%PPM Polyphase matrix associated to two Laurent polynomials.
%   M = PPM(H,G) returns the polyphase matrix associated with
%   two Laurent polynomials. This matrix is such that:
%
%              | even(H(z)) even(G(z)) |
%       M(z) = |                       |
%              | odd(H(z))   odd(G(z)) |
%
%   where even(P) and odd(P) are respectively the even part
%   and the odd part of the Laurent polynomial P.
%
%   See also EVEN, ODD.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 30-Mar-2001.
%   Last Revision: 13-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

M = laurmat({even(H),even(G);odd(H),odd(G)});
