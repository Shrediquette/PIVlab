function [f, statistic] = frame_factors(frame)
%FRAME_FACTORS Factors from the pixel data of a frame (image pair number) to the user's units.
%   [f, statistic] = gui.frame_factors(frame)
%   f.u, f.v, f.w: see calibrate.statistic_factors. statistic: '' (normal frame), 'mean', 'sum',
%   'std' or 'tke' for frames made by "temporal statistics".
statistic = '';
ismean = gui.retr('ismean');
filename = gui.retr('filename');
if numel(ismean) >= frame && ismean(frame) == 1 && numel(filename) >= 2*frame-1
    name = filename{2*frame-1};
    if strncmpi(name, 'TKE of frames', 13)
        statistic = 'tke';
    elseif strncmpi(name, 'STDEV of frames', 15)
        statistic = 'std';
    elseif strncmpi(name, 'SUM of frames', 13)
        statistic = 'sum';
    else
        statistic = 'mean';
    end
end
f = calibrate.statistic_factors(gui.retr('calu'), gui.retr('calv'), statistic);
end
