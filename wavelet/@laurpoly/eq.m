function R = eq(A,B)
%EQ Laurent polynomials equality test.
%   EQ(A,B) returns 1 if the two Laurent polynomials A and B
%   are equal and 0 otherwise.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Mar-2001.
%   Last Revision 13-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if      isnumeric(A) && length(A)==1 , A = laurpoly(A,0);
elseif  isnumeric(B) && length(B)==1 , B = laurpoly(B,0);
end

epsilon = 1E-9;
if ((A.maxDEG-B.maxDEG)==0) && (length(A.coefs)==length(B.coefs))
    R = max(abs(A.coefs-B.coefs))<epsilon;
else
    R = false;    
end
