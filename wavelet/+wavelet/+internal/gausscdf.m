function phix = gausscdf(x,mu,sigma,tail)
% This function returns the value of the Gaussian cumulative probability
% distribution function at the value x. x can be a vector, or scalar. 
% tail = 'upper' provides 1-normcdf(x,mu,sigma)
% tail = 'lower' provides normcdf(x,mu,sigma)
% The Gaussian
% PDF is parameterized by \mu and \sigma.
%
% This function is for internal use only. It may change in a future
% release.

%   Copyright 2016-2020 The MathWorks, Inc.

%#codegen

% Create standard normal RVs
coder.gpu.internal.kernelfunImpl(false);
coder.inline('never');

% Check if GPU is enabled and the size of input > 1. Calling the device
% function of CUDA Math Library using coder.ceval as the generated code for
% CUDA Math Library erfc call is more optimized then erfc MATLAB function 
% call.
if coder.gpu.internal.isGpuEnabled && numel(x) > 1
    phix = coder.nullcopy(zeros(size(x), 'like', x));
    Z = coder.nullcopy(zeros(size(x), 'like', x));
    if strcmpi(tail,'upper')    
        coder.gpu.kernel;
        for iter = 1:numel(x)
            Z(iter) = (x(iter)-mu)./sigma;
            phix(iter) = coder.ceval('-gpudevicefcn','erfc', Z(iter)./sqrt(2));
            phix(iter) = 1/2*phix(iter);
        end
    else
        coder.gpu.kernel;
        for iter = 1:numel(x)
            Z(iter) = (x(iter)-mu)./sigma;
            phix(iter) = coder.ceval('-gpudevicefcn','erfc', -Z(iter)./sqrt(2));
            phix(iter) = 1/2*phix(iter);
        end
    end
else

    Z = (x-mu)./sigma;

    if strcmpi(tail,'upper')
        Z = -Z;
    end

    phix = 1/2*erfc(-Z./sqrt(2));
end
