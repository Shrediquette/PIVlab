function P = plus(A,B)
%PLUS Laurent polynomial addition.
%   P = PLUS(A,B) returns a Laurent polynomial which is
%   the sum of the two Laurent polynomials A and B.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Mar-2001.
%   Last Revision: 13-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if      isnumeric(A) && length(A)==1 , A = laurpoly(A,0);
elseif  isnumeric(B) && length(B)==1 , B = laurpoly(B,0);
end

dA = A.maxDEG;
dB = B.maxDEG;
dP = max([dA,dB]);
cA = A.coefs; lA = length(cA);
cB = B.coefs; lB = length(cB);
nbCoefs = dP - min([dA-lA+1,dB-lB+1])+1;
cP = zeros(1,nbCoefs);
idxBeg = 1+dP-dA; idxEnd = idxBeg +lA-1;
cP(idxBeg:idxEnd) = cA;
idxBeg = 1+dP-dB; idxEnd = idxBeg +lB-1;
cP(idxBeg:idxEnd) = cP(idxBeg:idxEnd)+cB;
[cP,dP] = reduce(cP,dP);
P = laurpoly(cP,dP);
