function P = minus(A,B)
%MINUS Laurent polynomial subtraction.
%   P = MINUS(A,B) returns a Laurent polynomial which is
%   the difference of the two Laurent polynomials A and B.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Mar-2001.
%   Last Revision: 06-May-2008.
%   Copyright 1995-2020 The MathWorks, Inc.

P = plus(A,-B);
