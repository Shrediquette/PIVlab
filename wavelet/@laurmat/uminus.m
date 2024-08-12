function M = uminus(A)
%UMINUS Unary minus for Laurent matrix.
%   -A negates the elements of A.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 30-Mar-2001.
%   Last Revision 12-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

MA = A.Matrix;
[rA,cA] = size(MA);
for i=1:rA
    for j=1:cA
        MA{i,j} = -MA{i,j};
    end
end
M = laurmat(MA);
