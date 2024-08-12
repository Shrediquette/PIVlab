function muhat = ebayesthresh(x,stdest,thresholdrule,transformtype)
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

% Set maximum interations for intervalsolve() binary search routine.

%#codegen

maxiter = 50;
minstd = 1e-9;
m = size(x,1);

if (ischar(stdest) || isa(stdest,'string')) && strcmpi(stdest,'leveldependent')
    % Check if GPU is enabled.
    if coder.gpu.internal.isGpuEnabled
        % Using coder.const call for erfcinv fucntion call as the input
        % passed to this function is fixed scalar value.
        normfac = coder.const(1/(-sqrt(2)*erfcinv(2*0.75)));
        % Calculation of normfac*median(abs(bsxfun(@minus,x,median(x))))
        % using sort operations and selection of middle element.
        % Calculation of median(x)
        xSort = gpucoder.sort(x, 1);
        medX = coder.nullcopy(zeros(1, size(x, 2), 'like', x));
        if mod(m, 2)
            coder.gpu.kernel;
            for i = 1:size(x, 2)
                medX(i) = xSort((m + 1)/2, i);
            end
        else
            coder.gpu.kernel;
            for i = 1:size(x, 2)
                tempMedX = xSort(m/2, i) + xSort((m/2) + 1, i);
                medX(i) = tempMedX/2;
            end
        end
        
        medSubX = abs(bsxfun(@minus,x,medX));
        % Calcualtion of median for matrix x - median(x)
        medSubX = gpucoder.sort(medSubX, 1);
        if mod(m, 2)
            coder.gpu.kernel;
            for i = 1:size(x, 2)
                medX(i) = medSubX((m + 1)/2, i)*normfac;
            end
        else
            coder.gpu.kernel;
            for i = 1:size(x, 2)
                tempMedX = medSubX(m/2, i) + medSubX((m/2) + 1, i);
                medX(i) = (tempMedX/2)*normfac;
            end
        end
        temp_stdest = repmat(medX,m,1);
    else
        normfac = 1/(-sqrt(2)*erfcinv(2*0.75));
        temp = normfac*median(abs(bsxfun(@minus,x,median(x))));
        temp_stdest = repmat(temp,m,1);
    end
else
    temp_stdest = repmat(stdest,m,1);
end

% Guard against zero standard deviation
temp_stdest(temp_stdest<minstd) = minstd;
% Vectors have unit standard deviation
x = x./temp_stdest;
% weight can be a scalar or row vector
weight = wavelet.internal.weightfromdata(x,30,transformtype);
if strcmpi(thresholdrule,'median')
    muhat = wavelet.internal.postmedcauchy(x,weight,maxiter);
elseif strcmp(thresholdrule,'soft') || strcmp(thresholdrule,'hard')
    % Change weight to a column vector for threshfromweight
    weight = weight(:);
    thr = wavelet.internal.threshfromweight(weight,maxiter);
    thr = thr';
    thr = repmat(thr,size(x,1),1);
    muhat = wthresh(x,lower(thresholdrule(1)),thr);
else
    muhat = wavelet.internal.postmeancauchy(x,weight);
end
muhat = muhat.*temp_stdest;
end
