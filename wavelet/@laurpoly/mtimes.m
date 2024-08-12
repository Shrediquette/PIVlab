function P = mtimes(A,B)
%MTIMES Laurent polynomial multiplication.
%   P = MTIMES(A,B) returns a Laurent polynomial which is
%   the product of the two Laurent polynomials A and B.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Mar-2001.
%   Last Revision: 13-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if      isnumeric(A) && length(A)==1 , A = laurpoly(A,0);
elseif  isnumeric(B) && length(B)==1 , B = laurpoly(B,0);
end

dA = A.maxDEG;
dB = B.maxDEG;
cA = A.coefs;
cB = B.coefs;
dP = dA+dB;
cP = conv(cA,cB);
[cP,dP] = reduce(cP,dP);
P = laurpoly(cP,dP);
