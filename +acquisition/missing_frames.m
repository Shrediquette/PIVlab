function [n_missing, first_missing] = missing_frames(frame_times, frame_rate)
%Number of frames that are missing in a triggered recording, from the arrival times of the frames.
%frame_times: arrival time of every received frame (s); frame_rate: trigger rate of the camera (Hz).
%A camera that ignores triggers (e.g. USB connection too slow) or loses frames delivers fewer frames than
%triggers: from there on, every frame arrives one frame period later than expected.
%Frames never arrive early, only late (USB, Windows): the earliest arrival of the next 20 frames is used
%(a quarter of the frames in short recordings).
%The clocks of synchronizer and PC differ slightly (0.3 frame periods in 40 s were measured): only sudden
%steps count, a slow drift does not.
%first_missing: index of the first frame that comes after a missing frame (empty if none is missing).
%Frames missing within the last 20 frames (the window) are not counted.
n_missing = 0;
first_missing = [];
t = frame_times(:);
n = numel(t);
window = min(20,floor(n/4)); %short recordings: a smaller window
if window < 2 || ~isfinite(frame_rate) || frame_rate <= 0
	return
end
period = 1/frame_rate;
lag = t - (0:n-1)'*period; %one period more with every missing frame
earliest = movmin(lag,[0 window-1]);
earliest = earliest(1:n-window+1); %the last values would use fewer frames
steps = round(diff(earliest)/period); %missing frames between frame i and i+1 of the window start
missing_so_far = cumsum(steps);
n_missing = max(0,missing_so_far(end));
if n_missing > 0
	first_missing = find(missing_so_far > 0,1) + 1;
end
