function Mnew = newvar(M,var)
%NEWVAR Change variable in a Laurent matrix.
%   MNEW = NEWVAR(M,VAR) returns the Laurent matrix MNEW 
%   which is obtained by doing a change of variable VAR.
%   The valid choices for VAR are:
%       'z^2': M(z) ---> M(z^2)
%       '-z' : M(z) ---> M(-z)
%       '1/z': M(z) ---> M(1/z)
%       'sqz': M(z) ---> M(sqrt(z))

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-Jun-2002.
%   Last Revision 12-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

A = M.Matrix;
[nbr,nbc] = size(A);
for r = 1:nbr
    for c = 1:nbc
        A{r,c} = newvar(A{r,c},var);
    end
end
Mnew = laurmat(A);
