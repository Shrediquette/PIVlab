function incomplete = incomplete_frame(frames, nr)
%True when frame nr of a camera was not transferred completely.
%frames: frames of one camera, height x width x 1 x n (nr is checked, the frames before it are compared).
%A too slow USB connection (e.g. two cameras on one USB hub) delivers frames whose lower part was never
%filled. The frame count and the frame times look normal. The part that was not filled is
%- exactly 0 (new buffer): the image stops abruptly - a row with image content (at least half of the
%  pixels above 0) is followed by rows of zeros down to the bottom, and this cut is at a different row in
%  the frames before (frame 1: after). A dark scene or a dark lower part of the image (black level 0:
%  pixels are 0) is no cut: dark everywhere, fading out over many rows, or ending at the same row in
%  every frame.
%- an older image (reused buffer, e.g. rows 91-1216 of the frame 3 frames earlier): with sensor noise, a
%  row of a real image never equals the same row of another frame, also not in a static scene. Only rows
%  with at least 100 pixels between black and the brightest value count: black (0) and saturated pixels
%  have no noise. Compared with the 4 frames before.
incomplete = false;
n = size(frames,4);
if size(frames,1) < 4
	return
end
%% lower part exactly 0
cut = cut_row(frames(:,:,1,nr));
if ~isempty(cut)
	incomplete = true;
	if nr == 1
		neighbours = 2:min(3,n);
	else
		neighbours = max(1,nr-2):nr-1;
	end
	for k = neighbours
		other_end = content_end(frames(:,:,1,k));
		if ~isempty(other_end) && abs(other_end - cut) <= 2
			incomplete = false; %dark lower part of the scene, the same in the other frames
		end
	end
	if incomplete
		return
	end
end
%% lower part from an older frame
rows = 1:8:size(frames,1); %every 8th row and every 4th column are enough: the old part has hundreds of rows
columns = 1:4:size(frames,2);
sample = frames(rows,columns,1,nr);
has_noise = sum(sample > 0 & sample < max(sample(:)),2) >= 25; %100 pixels of the full row
for k = max(1,nr-4):nr-1
	same = all(sample == frames(rows,columns,1,k),2) & has_noise;
	if nnz(same) >= 3
		incomplete = true;
		return
	end
end

function cut = cut_row(ima)
%last row with image content when it is directly followed by rows of zeros down to the bottom, else empty
cut = [];
[last, nonzero] = content_end(ima);
if ~isempty(last) && last <= size(ima,1)-2 && max(nonzero(max(1,last-2):last)) >= 0.5
	cut = last;
end

function [last, nonzero] = content_end(ima)
%last row with more than 1 % of the pixels above 0 (a few pixels above 0 in the empty part were seen on the rig);
%nonzero: share of the pixels above 0 per row, from every 4th column
nonzero = mean(ima(:,1:4:end) > 0,2);
last = find(nonzero > 0.01,1,'last');
