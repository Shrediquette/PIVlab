function R = ne(A,B)
%NE Laurent matrices inequality test.
%   NE(A,B) returns 1 if the two Laurent matrices A and B
%   are different and 0 otherwise.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2001.
%   Last Revision 12-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

R = ~eq(A,B);
