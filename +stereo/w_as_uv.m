function rl = w_as_uv(resultslist)
%W_AS_UV Copy of the result list with w in the rows of u and v (stereo-PIV).
%   rl = stereo.w_as_uv(resultslist)
% Lets the smoothing functions of PIVlab (plot.temporal_smooth reads the neighbouring frames from the
% rows of u and v) smooth w exactly like u and v. Rows 3, 4, 7 and 8 are replaced by row 16.
rl = resultslist;
if size(rl, 1) < 16
    return
end
for f = 1:size(rl, 2)
    rl{3, f} = rl{16, f};
    rl{4, f} = rl{16, f};
    if size(rl, 1) > 6 && ~isempty(rl{7, f})
        rl{7, f} = rl{16, f};
        rl{8, f} = rl{16, f};
    end
end
end
