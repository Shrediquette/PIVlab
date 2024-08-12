function [muhat,delta] = postmedcauchy(data,weight,maxiter)
%   This function is for internal use only. It may change in a future
%   release.
%
%   The empirical Bayes method used here is a MATLAB implementation of the
%   R package.
% 
%   Silverman, B. (2012) EbayesThresh: Empirical Bayes Thresholding and
%   Related Methods, http://CRAN.R-project.org/package=EbayesThresh.
%
%   References:
%   Johnstone, I. & Silverman, B. (2005). EbayesThresh: R Programs for 
%   Empirical Bayes Thresholding, Journal of Statistical Software, 12,1,
%   pp. 1-38.

%   Copyright 2016-2020 The MathWorks, Inc.

%   muhat will be a column vector or matrix.
%   The input weight is a scalar or a row vector of weights

%#codegen

coder.gpu.internal.kernelfunImpl(false);
coder.inline('never');

muhat = zeros(size(data), 'like', data);
[M,N] = size(muhat);

magdata = abs(data);
% Make a copy of magdata
magdatatmp = magdata;
% posterior median estimates start to deviate from actual value. From this
% point on, we replace by shrinkage estimates x-2/x 
idx = magdata < 20;
magdata(~idx) = NaN;
lo = zeros(1,N);

% Check if GPU is enabled.
if coder.gpu.internal.isGpuEnabled
    % Make weight a matrix the same size as muhat
    weightUpdated = coder.nullcopy(zeros(size(muhat), 'like', data));
    coder.gpu.kernel;
    for j = 1:M
        weightUpdated(j, :) = weight;
    end
    
    zeromd = zeros(size(magdata),'like',data);
    % GPU specific call of intervalsolve function.
    [muhat,delta] = wavelet.internal.gpu.intervalSolvePostMedCauchy(zeromd,lo,max(magdata),...
    maxiter,magdata,weightUpdated);
    
    for i = 1:numel(muhat)
        if ~idx(i)
            muhat(i) = (magdatatmp(i) - 2/magdatatmp(i));
        end
        
        if muhat(i) < 1e-7
            muhat(i) = 0;
        end
    
        muhat(i) = sign(data(i))*muhat(i);

        if abs(muhat(i)) > abs(data(i))
            muhat(i) = data(i);
        end    
    end
else    
%     Make weight a matrix the same size as muhat
    weight = repmat(weight,M,1);
    [muhat,delta] = intervalsolve(zeros(size(magdata)),lo,max(magdata),...
        maxiter,magdata,weight);
    muhat(~idx) = magdatatmp(~idx)-2./magdatatmp(~idx);

    muhat(muhat < 1e-7) = 0;
    muhat = sign(data).*muhat;

    hugeMuInds = (abs(muhat) > abs(data));
    muhat(hugeMuInds) = data(hugeMuInds);
end
end

function [muhat,delta] = intervalsolve(zeromd,lo,hi,maxiter,magdata,weight)

[m,~] = size(zeromd);

lo = repmat(lo,m,1);
hi = repelem(hi,m,1);

Tol = 1e-9;

numiter = 0;
conTol = Inf;

temp_delta = [];
coder.varsize('temp_delta');
while conTol > Tol
    numiter = numiter+1;
    midpoint = (lo+hi)./2;
    fmidpoint = wavelet.internal.cauchymedzero(midpoint,magdata,weight);
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
muhat = (lo+hi)./2;
end


