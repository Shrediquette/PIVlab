function stdc = wnoisest(c,varargin)
%WNOISEST Estimate noise of 1-D wavelet coefficients.
%   STDC = WNOISEST(C,L,S) returns estimates of the detail
%   coefficients' standard deviation for levels contained
%   in the input vector S.
%   [C,L] is the input wavelet decomposition structure
%   (see WAVEDEC for more information).
%
%   If C is a one dimensional cell array, STDC = WNOISEST(C)
%   returns a vector such that STDC(k) is an estimate of the
%   standard deviation of c{k}.
%
%   If C is a numeric array, STDC = WNOISEST(C)
%   returns a vector such that STDC(k) is an estimate of the
%   standard deviation of c(k,:).
%  
%   The estimator used is Median Absolute Deviation / 0.6745,
%   well suited for zero mean Gaussian white noise in the 
%   de-noising 1-D model (see THSELECT for more information).
%
%   See also THSELECT, WAVEDEC, WDEN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
narginchk(1,3)

if isempty(varargin)
    if iscell(c)
        nblev = length(c);
    elseif isnumeric(c)
        if size(c,1)>1
            c = num2cell(c,2);
        else
            c = num2cell(c(:)',2);
        end
        nblev = size(c,1);
    else
        error(message('Wavelet:FunctionArgVal:Invalid_ArgFirst'));
    end
else
    c = detcoef(c,varargin{:},'cells');
    nblev = length(c);
end
stdc = zeros(1,nblev);
for k = 1:nblev
    stdc(k) = median(abs(c{k}))/0.6745;
end
