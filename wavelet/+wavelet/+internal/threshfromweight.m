function [thr,delta] = threshfromweight(weight,maxiter)
% This function is for internal use only. It may change in a future
% release.

%   Copyright 2016-2020 The MathWorks, Inc.

%#codegen
coder.gpu.internal.kernelfunImpl(false);
coder.inline('never');

% Check if GPU is enabled.
if coder.gpu.internal.isGpuEnabled
    [thr, delta] = wavelet.internal.gpu.threshfromweight(weight, maxiter);

else

    [m,n] = size(weight);
    zeromd = zeros(m,n);
    lo = zeros(m,1);
    hi = repelem(20,m,1);

    Tol = 1e-9;

    numiter = 0;
    conTol = Inf;
    temp_delta = [];
    coder.varsize('temp_delta');

    while conTol > Tol
        numiter = numiter+1;
        midpoint = (lo+hi)./2;
        fmidpoint = wavelet.internal.cauchythreshzero(midpoint,weight);
        idx = fmidpoint <= zeromd;
        lo(idx) = midpoint(idx);
        hi(~idx) = midpoint(~idx);
       temp_delta = [temp_delta; max(abs(hi-lo))];
        temp_max = temp_delta(numiter);
        conTol = max(temp_max);
        if numiter > maxiter
            break;
        end
    end
    delta = temp_delta;
    thr = (lo+hi)./2;
end
end
 
