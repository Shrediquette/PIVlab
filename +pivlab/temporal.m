function out = temporal(res, operation, opts)
%TEMPORAL Temporal statistics of a series of vector fields (mean, standard deviation, ...).
%   m = pivlab.temporal(res, "mean") returns the mean of all vector fields as a new result
%   struct with one frame. It can be displayed, derived and saved like any other result.
%
%   operation  "mean" | "std" | "sum" | "tke"
%              "tke": turbulent kinetic energy, m.u = 0.5*var(u), m.v = 0.5*var(v),
%              pivlab.derive(m,"magnitude") gives the total TKE (sum of both).
%
%   Name=value options
%   Frames     frames to use, e.g. 1:100 (default: all frames). A cell array produces one
%              statistics frame per cell, e.g. phase averages: Frames={1:4:100, 2:4:100}
%
%   Like in PIVlab, vectors that are masked in all frames stay masked, vectors that were
%   interpolated in more than 50 % of the frames are marked as interpolated (typevector 2),
%   and for mean, std and tke vectors with less than 25 % valid measurements are NaN.
%
%   For a quick look, plain MATLAB works as well:
%       mean_u = mean(res.u, 3, 'omitnan');   std_u = std(res.u, 0, 3, 'omitnan');
%
%   Example
%       m = pivlab.temporal(res, "mean");
%       pivlab.display(m, Overlay="magnitude");
%
%   See also pivlab.derive, pivlab.display
arguments
    res (1,1) struct
    operation (1,1) string {mustBeMember(operation,["mean","std","sum","tke"])}
    opts.Frames = []
end
res = take_user_edits(res);   % values changed by hand in res.u / res.v are used
types = struct('mean',1,'sum',0,'std',2,'tke',3);
type = types.(operation);
labels = struct('mean',"MEAN",'sum',"SUM",'std',"STDEV",'tke',"TKE");
n = size(res.px.u,3);
frames = opts.Frames;
if isempty(frames)
    frames = {find(~res.isMean)'};
elseif ~iscell(frames)
    frames = {frames};
end
p = res.px;
if res.smoothed && ~isempty(p.u_smoothed)
    U = p.u_smoothed; V = p.v_smoothed;
else
    U = p.u; V = p.v;
end
k = numel(frames);
sz = size(p.x);
uo = zeros([sz k], 'like', U); vo = uo; tvo = zeros([sz k]);
labs = strings(k,1);
for r = 1:k
    sel = frames{r}(:)';
    if isempty(sel) || any(sel < 1 | sel > n | sel ~= round(sel))
        error('pivlab:temporal:frames','Frames must be between 1 and %d.', n);
    end
    if any(res.isMean(sel))
        error('pivlab:temporal:frames','The selection must not contain frames that are temporal statistics themselves.');
    end
    [a, b, t] = plot.temporal_stats(U(:,:,sel), V(:,:,sel), res.typevector(:,:,sel), type);
    uo(:,:,r) = a; vo(:,:,r) = b; tvo(:,:,r) = t;
    labs(r) = labels.(operation) + " of frames " + frame_string(sel);
    if k > 1
        labs(r) = labs(r) + " #" + r;
    end
end
out = res;
out.px.u = uo; out.px.v = vo;
out.px.u_raw = uo; out.px.v_raw = vo;
out.px.u2 = []; out.px.v2 = [];
out.px.u_smoothed = []; out.px.v_smoothed = [];
out.px.uncertainty = [];
out.typevector = tvo;
out.typevector_raw = tvo;
out.correlation_map = nan([sz k]);
out.smoothed = false;
out.derived = struct();
out.isMean = true(k,1);
out.frameLabels = labs;
out.statistic = operation;
out.sourcePairs = cellfun(@(f) res.pairs(f), frames, 'UniformOutput', false);
out.pairs = cellfun(@(f) res.pairs(f(1)), frames);
out = refresh_units(out);
end

function s = frame_string(sel)
if numel(sel) > 1 && all(diff(sel) == 1)
    s = sel(1) + ":" + sel(end);
elseif numel(sel) > 2 && all(diff(sel) == sel(2)-sel(1))
    s = sel(1) + ":" + (sel(2)-sel(1)) + ":" + sel(end);
else
    s = strjoin(string(sel), ",");
end
end
