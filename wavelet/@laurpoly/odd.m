function O = odd(P)
%ODD Odd part of a Laurent polynomial.
%   O = ODD(P) returns the odd part O of the Laurent polynomial P.
%   The polynomial O is such that:  
%           O(z^2) = [P(z) - P(-z)] / [2*z^(-1)]
%   
%   See also EVEN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-Mar-2001.
%   Last Revision: 15-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% ODD(P) == EVEN(Z*P)
%--------------------
C = P.coefs;
D = P.maxDEG;
O = laurpoly(C(1+mod(D+1,2):2:end),floor((D+1)/2));
