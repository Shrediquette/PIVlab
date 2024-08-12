function M = horzcat(varargin)
%HORZCAT Horizontal concatenation of Laurent polynomials.
%   M = HORZCAT(P1,P2,...) performs the concatenation 
%   operation M = [P1 , P2 , ...]. M is a Laurent matrix.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Jun-2003.
%   Last Revision: 21-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

M = laurmat(varargin(:)');
