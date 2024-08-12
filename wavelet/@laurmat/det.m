function D = det(M)
%DET Laurent matrix determinant.
%   D = det(M) returns the determinant of the Laurent matrix M.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 30-Mar-2001.
%   Last Revision 12-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

D = CellDET(M.Matrix);

%-------------------------------------------------------------------%
function D = CellDET(A)
[R,C] = size(A);
if R>1
    D = 0;
    for k=1:R
        idxROWS = setdiff([1:R],k);
        idxCOLS = [2:C];
        D = D + (-1)^(1+k) * A{k,1} * CellDET(A(idxROWS,idxCOLS));
    end
else
    D = A{1,1};
end
%-------------------------------------------------------------------%
