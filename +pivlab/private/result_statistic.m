function statistic = result_statistic(res)
%RESULT_STATISTIC '' for a normal result, else the temporal statistic of pivlab.temporal
%   ('mean', 'sum', 'std' or 'tke'), for calibrate.statistic_factors.
statistic = '';
if isfield(res, 'statistic') && ~isempty(res.statistic)
    statistic = char(res.statistic);
end
end
