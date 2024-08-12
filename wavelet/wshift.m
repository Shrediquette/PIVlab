function y = wshift(type,x,p)
%This undocumented function may be removed in a future release.
%
%WSHIFT Shift Vector or Matrix.
%   Y = WSHIFT(TYPE,X,P) with TYPE = {1,'1','1d' or '1D'}
%   performs a P-circular shift of vector X.
%   The shift P must be an integer, positive for right to left
%   shift and negative for left to right shift.
%
%   Y = WSHIFT(TYPE,X,P) with TYPE = {2,'2','2d' or '2D'}
%   performs a P-circular shift of matrix X.
%   The shifts P must be integers. P(1) is the shift for rows
%   and P(2) is the shift for columns.
%
%   WSHIFT('1D',X) is equivalent to WSHIFT('1D',X,1)
%   WSHIFT('2D',X) is equivalent to WSHIFT('2D',X,[1 1])
%
%   Example 1:
%     x = [1 2 3 4 5];
%     wshift('1D',x,1)  % returns [2 3 4 5 1]
%     wshift('1D',x,-1) % returns [5 1 2 3 4]
%
%   Example 2:
%     x = [1 2 3;5 6 7];
%     wshift('2D',x,[1 1])  % returns [6 7 5;2 3 1]
%     wshift('2D',x,[-1,0]) % returns [5 6 7;1 2 3]

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Dec-97.
%   Last Revision: 13-Sep-2008.
%   Copyright 1995-2020 The MathWorks, Inc.
narginchk(2,3)

if nargin < 3
    switch type
        case {1,'1','1d','1D'}
            p = 1;
        case {2,'2','2d','2D'}
            p = [1 1];
    end
end

y = circshift(x, -p);
