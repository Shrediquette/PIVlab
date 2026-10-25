function r = freeze_check(code)
%FREEZE_CHECK How long the PIVlab window is not redrawn during an action (without screenshots).
%   r = freeze_check(code) runs the MATLAB code (char) with the profiler history and finds the
%   calls that redraw the window: drawnow, pause, uiwait, waitfor, getframe. drawnow called by
%   gui.update_progress is "drawnow limitrate" (skips redraws less than 50 ms apart or while the
%   renderer is busy) and counted separately.
%     r.duration          run time [s] (with profiler overhead)
%     r.first_full        time until the first full redraw [s] (busy strip and locked controls visible)
%     r.longest_full_gap  longest time without a full redraw [s]
%     r.longest_any_gap   longest time without any redraw, limitrate included [s]
%     r.full, r.limitrate number of calls
%   Example: r = freeze_check('plot.apply_deriv_all_Callback([],[],[])')
profile clear;
profile('on', '-history', '-timestamp', '-historysize', 2e7);
t_start = posixtime(datetime('now'));
evalc(code);
t_end = posixtime(datetime('now'));
profile off;
p = profile('info');
names = {p.FunctionTable.FunctionName};
redraw = false(1, numel(names));
for k = 1:numel(names)
    redraw(k) = any(strcmp(names{k}, {'drawnow', 'pause', 'uiwait', 'waitfor', 'getframe'}));
end
progress = find(strcmp(names, 'update_progress') | strcmp(names, 'gui.update_progress'));
h = p.FunctionHistory;
t = h(3, :) + 1e-6 * h(4, :);
% walk through the history with a call stack to know who called drawnow
stack = zeros(1, 0);
full_t = [];
limit_t = [];
for i = 1:size(h, 2)
    f = h(2, i);
    if h(1, i) == 0 % entry
        if redraw(f)
            caller = 0;
            if ~isempty(stack)
                caller = stack(end);
            end
            if strcmp(names{f}, 'drawnow') && any(caller == progress)
                limit_t(end+1) = t(i); %#ok<AGROW>
            else
                full_t(end+1) = t(i); %#ok<AGROW>
            end
        end
        stack(end+1) = f; %#ok<AGROW>
    elseif ~isempty(stack)
        stack(end) = [];
    end
end
% start and end: first and last entry of the history (the profiler has its own clock)
if isempty(t)
    t0 = 0;
    t1 = t_end - t_start;
else
    t0 = t(1);
    t1 = t(end);
end
r.duration = t1 - t0;
r.full = numel(full_t);
r.limitrate = numel(limit_t);
if isempty(full_t)
    r.first_full = r.duration;
else
    r.first_full = full_t(1) - t0;
end
r.longest_full_gap = max(diff([t0 full_t t1]));
r.longest_any_gap = max(diff([t0 sort([full_t limit_t]) t1]));
end
