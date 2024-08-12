function muhat = postmeancauchy(data,weight)
% This function is for internal use only and may change in a future
% release.
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

%   Copyright 2017-2020 The MathWorks, Inc.

%#codegen

ExpX = exp(-data.^2./2);

temp = bsxfun(@minus,data,((bsxfun(@rdivide,2*(1-ExpX),data))));
z = bsxfun(@times, weight,temp);
temp_data = data.^2;
temp_z = bsxfun(@times,bsxfun(@times,(1-weight),ExpX),temp_data);
temp_Z = bsxfun(@times,weight,(1-ExpX));
temp = temp_z + temp_Z;
z = bsxfun(@rdivide,z,temp);

muhat = z;

% small values of data cause explosions in value of mu so limit to value of
% data
muhat(data==0) = 0;
hugeMuInds = (abs(muhat) > abs(data));
muhat(hugeMuInds) = data(hugeMuInds);
 
