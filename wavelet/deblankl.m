function s = deblankl(x)
%DEBLANKL Convert string to lowercase without blanks.
%   S = DEBLANKL(X) is the string X converted to lowercase 
%   without blanks.
%   If X is a cell array, each cell ids converted as above.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

if ~iscell(x)
    if ~isempty(x)
        s = lower(x);
        s = s(s~=' ');
    else
        s = [];
    end
else
    s = x;
    if ~isempty(x)
        for j = 1:length(x)
            tmp = lower(x{j});
            s{j} = tmp(tmp~=' ');
        end
    else
        s = {};
    end
end
