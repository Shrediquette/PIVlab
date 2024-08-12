function R = isequal(A,B)
%ISEQUAL Laurent polynomials equality test.
%
%   ISEQUAL(A,B) returns 1 if the two Laurent polynomials 
%   A and B are equal and 0 otherwise.

% Copyright 2004-2020 The MathWorks, Inc.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 11-Jun-2003.
%   Last Revision 11-Jun-2003.

R = eq(A,B);
