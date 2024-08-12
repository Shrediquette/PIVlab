function xtilde = involution(x)
% This function is for internal use only. It may be changed or removed in 
% a future release.

%   Copyright 2021 The MathWorks, Inc.

%#codegen
Nf = size(x,2);
xtilde = [x(:,1) flip(conj(x(:,2:Nf)),2)];
