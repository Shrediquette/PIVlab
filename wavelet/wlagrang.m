function  [P,R] = wlagrang(N)
%WLAGRANG "Lagrange a trous" filters computation.
%   [P,R] = WLAGRANG(N) returns the order N Lagrange filter P.
%   P has (2N-1) roots located in 1. R contains the other roots
%   sorted in complex modulus ascending order.
%   
%   Possible values for N are:
%      N = 1, 2, 3, ...
%   Caution: Instability may occur when N is too large (N > 45).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-Feb-98.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

lon = 2*N-1;
sup = [-N+1:N];
a = zeros(1,N);
for k = 1:N
    nok  = sup(sup ~= k);
    a(k) = prod(0.5-nok)/prod(k-nok);
end
P = zeros(1,lon);
P(1:2:lon) = a;
P = [wrev(P),1,P]; 
if nargout>1
    R = roots(P);
    [s,K] = sort(abs(R+1));
    R = R(K(lon+2:2*lon));
    [s,K] = sort(abs(R));
    R = R(K);
end
