function critvalue = gaussianCriticalValue(p)
% This function is for internal use only. This function returns the
% critical value for the standard normal distribution given a probability p
% p here is a value 0.5 \leq p < 1
% cv = wavelet.internal.gaussianCriticalValue(0.9750);

%   Copyright 2018-2020 The MathWorks, Inc.

%#codegen

validateattributes(p,{'double','single'},{'>=',0.5,'<',1});
critvalue = -sqrt(2)*erfcinv(2*p);
