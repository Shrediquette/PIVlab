function tf = isodd(x)
%ISODD Test integers for divisibility by two.
%   ISODD(X) returns true when X is not divisible by two.
%   it returns false otherwise.  X must be integer valued

%   Copyright 2018-2020 The MathWorks, Inc.
%#codegen

tf = signalwavelet.internal.isodd(x);
