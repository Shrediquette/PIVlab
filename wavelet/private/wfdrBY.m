function adj_p = wfdrBY(pvals)
% Control the type I error rate for multiple tests when the tests are
% dependent.
% Benjamini, Y. & Yekutieli, D. (2001) The control of the false discovery
% rate in multiple testing under dependency, The Annals of
% Statistics,29,4,1165-1188.

%   Copyright 2015-2020 The MathWorks, Inc.

pvals = pvals(:);
N = length(pvals);
idx = length(pvals):-1:1;
idx = idx(:);
[~,orderedP] = sort(pvals, 'descend');
[~,orderedIdx] = sort(orderedP);
q = sum(1./(1:N));
adj_p = min(1,cummin(q*(N./idx).*pvals(orderedP)));
adj_p = adj_p(orderedIdx);






