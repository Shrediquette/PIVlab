function outliers = outliers(vec)
% Returns logical mask: 1 where |vec - mean(vec)| > 3*std(vec).
% Adapted from Wieneke (2013) disparity_uncertainty package.
outliers = abs(vec - mean(vec)) > 3 * std(vec);
end
