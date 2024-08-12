function t = isequaln(a,b)
%   This function is for internal use only. It may change in a future
%   release.

%   Copyright 2018-2020 The MathWorks, Inc.
t = isequal(class(a), class(b)) && isequaln(get(a), get(b));
end
