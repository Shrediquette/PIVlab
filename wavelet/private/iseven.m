function tf = iseven(x)
%ISEVEN Test integers for divisibility by two.
%   ISEVEN(X) returns true when X is divisible by two.
%   it returns false otherwise.  X must be integer valued.

%   Copyright 2018-2020 The MathWorks, Inc.
%#codegen

tf = signalwavelet.internal.iseven(x);
