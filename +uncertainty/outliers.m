function outliers = outliers(vec)
% Returns logical mask: 1 where |vec - mean(vec)| > 3*std(vec).
% Adapted from the MATLAB package by Dr. A. Sciacchitano (TU Delft, July 2016).
outliers = abs(vec - mean(vec)) > 3 * std(vec);
end
