function s = wnsubstr(s)
%WNSUBSTR Convert number to TEX indices.
%   S = WNSUBSTR(N)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Feb-1998.
%   Last Revision: 02-Aug-2000.
%   Copyright 1995-2020 The MathWorks, Inc.

if ~ischar(s) , s = sprintf('%.0f',s); end
l = length(s);
p = '_'; p = p(1,ones(1,l));
s = [p;s];
s = s(:)';
