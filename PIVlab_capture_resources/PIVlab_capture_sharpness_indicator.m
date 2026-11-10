function [sharpness,sharpness_map]=PIVlab_capture_sharpness_indicator (input_image,showinfo,x_offset)
%x_offset (optional, stereo acquisition): the image starts at x = x_offset+1 in the PIVlab axis (camera 2 right of
%camera 1). With x_offset, the old texts are not deleted here (the caller deletes them once for both cameras).
%With showinfo, a focus measure of the left, centre and right third is shown too (from 3 x 3 regions): the particle
%image diameter (PIVlab_capture_particle_diameter) for particle images, the edge width (PIVlab_capture_edge_width)
%for a board, '-' for other content. It does not depend on the image content, so the thirds can be compared
%(Scheimpflug adjustment: left = right). Shown is the median of the last 5 updates of each third, as a number and
%a sharpness bar with a mark at the best value so far (display_style below switches to the older tilt line).
if nargin < 3
	x_offset = [];
end
textx=size(input_image,2)/20*19;
texty=size(input_image,1)/20*19;
fontsize = 32;
stereo = ~isempty(x_offset);
if stereo
	textx = textx + x_offset;
	fontsize = 16; %two images share the display
else
	x_offset = 0;
end
skip=3;
diff_image=abs(diff(input_image(1:skip:end,1:skip:end))); %process only every 3rd pixel.... still works?
sharpness=std2(single(diff_image));
mean_brightess = mean(input_image(:));
sharpness=sharpness/mean_brightess*10000;

if ~stereo
	delete(findobj('tag','sharpness_display_text'));
end
if showinfo
	PIVlab_axis = gui.retr('pivlab_axis');
	focus = focus_per_column(input_image);
	[column_values, best_values] = smoothed_diameter(PIVlab_axis, x_offset, size(input_image), focus.mode, focus.values);
	display_style = 'bars'; %'bars': sharpness bars with a mark at the best value; 'tilt_line': the values at heights set by their size, joined by a line
	switch display_style
		case 'bars'
			draw_sharpness_bars(PIVlab_axis, column_values, best_values, focus.col_edges, x_offset, size(input_image), focus.mode, fontsize);
			texty = size(input_image,1)/20; %top right: the bars fill the lower part of the image
			info_alignment = 'top';
		case 'tilt_line'
			[label_x, label_y] = tilt_positions(column_values, focus.col_edges, x_offset, size(input_image));
			draw_tilt_lines(PIVlab_axis, label_x, label_y, ~isnan(column_values), x_offset, size(input_image));
			for c = 1:3
				x = label_x(c);
				y = label_y(c);
				text(x,y,format_diameter(column_values(c),focus.mode),'Color',[1 1 0],'tag','sharpness_display_text','Verticalalignment','middle','Horizontalalignment','center','Parent',PIVlab_axis,'FontSize',fontsize,'fontweight','bold','BackgroundColor',[0 0 0 0.4],'HitTest','off');
			end
			info_alignment = 'bottom';
	end
	switch focus.mode
		case 'particles'
			focus_text = 'Particle diameter in px';
		case 'board'
			focus_text = 'Board edge width in px';
		otherwise
			focus_text = 'No particles / board found';
	end
	if strcmp(display_style, 'bars')
		info = {['Sharpness: ' int2str(sharpness)] ['Mean brightness: ' int2str(mean_brightess)] focus_text}; %focus line next to the bars
	else
		info = {focus_text ['Sharpness: ' int2str(sharpness)] ['Mean brightness: ' int2str(mean_brightess)]};
	end
	text(textx,texty,info,'Color',[1 1 0] ,'tag','sharpness_display_text','Verticalalignment',info_alignment,'Horizontalalignment','right','Parent',PIVlab_axis,'FontSize',fontsize,'fontweight','bold','HitTest','off');
end

sharpness_map=[];
%{
fun = @(block_struct) std2(block_struct.data) * ones(size(block_struct.data));
blocksize_r=round(size(diff_image,1)/9);
blocksize_c=round(size(diff_image,2)/9);
sharpness_map = blockproc(diff_image,[blocksize_r blocksize_c],fun);
sharpness_map = rescale(sharpness_map);
sharpness_map=imresize(sharpness_map,size(input_image),'nearest');
%}
end

function focus = focus_per_column(input_image)
%Focus measure of the left / centre / right third. Particle images: particle image diameter (median of the
%particle tiles of the third); a board (black / white edges): edge width (median of the board regions of 3 x 3);
%anything else: NaN (the diameter would only show the size of the image structures). The content found in more
%thirds decides. A third without that content gets NaN.
particles = PIVlab_capture_particle_diameter(input_image, 3, 1);
focus.col_edges = particles.col_edges;
focus.mode = 'none';
focus.values = nan(1, 3);
n_particles = nnz(particles.is_particles);
if n_particles == 3 %clearly particles: the edge test is not needed (it takes longer)
	n_board = 0;
else
	board = PIVlab_capture_edge_width(input_image, 3, 3, 768); %a large part of each region: the board often fills only a part
	board_columns = any(board.is_board, 1);
	n_board = nnz(board_columns);
end
if n_particles >= 1 && n_particles >= n_board
	focus.mode = 'particles';
	focus.values = particles.diameter;
	focus.values(~particles.is_particles) = NaN;
elseif n_board >= 1
	focus.mode = 'board';
	widths = board.width;
	widths(~board.is_board) = NaN;
	focus.values = median(widths, 1, 'omitnan');
end
end

function [smoothed, best] = smoothed_diameter(PIVlab_axis, x_offset, image_size, mode, column_diameter)
%Median of the last n_updates values of each column (one history per camera, stored in the axis). The single
%values jump by 1-3 px (few large out-of-focus particles dominate a region). The median also ignores single
%outliers. The history starts again after a pause (new live image / preview), a new image size or other content.
%best: the smallest median of each column since the history started (from 3 updates on: one value can be an outlier).
n_updates = 5;
max_pause = 3; %s
name = ['particle_diameter_history_' int2str(x_offset)];
history = getappdata(PIVlab_axis, name);
if isempty(history) || ~isequal(history.image_size, image_size) || ~strcmp(history.mode, mode) || toc(history.last_update) > max_pause
	history.values = zeros(0, 3);
	history.image_size = image_size;
	history.mode = mode;
	history.best = nan(1, 3);
end
history.values = [history.values; column_diameter];
if size(history.values, 1) > n_updates
	history.values = history.values(end-n_updates+1:end, :);
end
smoothed = median(history.values, 1, 'omitnan');
if size(history.values, 1) >= 3
	history.best = min(history.best, smoothed); %min ignores NaN
end
history.last_update = tic;
setappdata(PIVlab_axis, name, history);
best = history.best;
end

function draw_sharpness_bars(PIVlab_axis, values, best, col_edges, x_offset, image_size, mode, fontsize)
%One bar per third, in the lower part of the image: height = smallest value (current or best so far, any third) /
%value of the third, so a full bar is the sharpest image seen. A white mark shows the best value of each third: turn
%back when the bar drops below its mark. Equal bars at their marks: in focus everywhere. A faint frame shows the full
%height, the value is written above it. Same tag as the texts: the capture code deletes the overlay by this tag.
height = image_size(1);
base = 0.95 * height;
full = 0.4 * height; %the image y axis points down: the bars grow upwards from base
reference = min([values best], [], 'omitnan');
for c = 1:3
	centre = x_offset + (col_edges(c) + col_edges(c+1)) / 2;
	half_width = 0.2 * (col_edges(c+1) - col_edges(c));
	bar_x = centre + half_width * [-1 1 1 -1];
	patch(PIVlab_axis, bar_x, base - full * [0 0 1 1], [1 1 0], 'FaceColor', 'none', 'EdgeColor', [1 1 0], 'EdgeAlpha', 0.35, ...
		'LineWidth', 1.5, 'tag', 'sharpness_display_text', 'HitTest', 'off', 'PickableParts', 'none');
	if ~isnan(values(c)) && ~isnan(reference) && reference > 0
		fraction = min(reference / values(c), 1);
		patch(PIVlab_axis, bar_x, base - full * fraction * [0 0 1 1], [1 1 0], 'FaceColor', [1 1 0], 'FaceAlpha', 0.35, ...
			'EdgeColor', 'none', 'tag', 'sharpness_display_text', 'HitTest', 'off', 'PickableParts', 'none');
		if ~isnan(best(c))
			mark = min(reference / best(c), 1);
			line(PIVlab_axis, centre + 1.2 * half_width * [-1 1], base - full * mark * [1 1], 'Color', [1 1 1 0.9], 'LineWidth', 3, ...
				'tag', 'sharpness_display_text', 'HitTest', 'off', 'PickableParts', 'none');
		end
	end
	text(centre, base - full - 0.02 * height, format_diameter(values(c), mode), 'Color', [1 1 0], 'tag', 'sharpness_display_text', ...
		'Verticalalignment', 'bottom', 'Horizontalalignment', 'center', 'Parent', PIVlab_axis, 'FontSize', fontsize, ...
		'fontweight', 'bold', 'BackgroundColor', [0 0 0 0.4], 'HitTest', 'off');
end
end

function [label_x, label_y] = tilt_positions(values, col_edges, x_offset, image_size)
%Label positions: the centre of each third in x. In y, a value larger than the reference (the centre third, or the
%median of the thirds when the centre has no value) moves up: 50 % larger = a quarter of the image height. Relative,
%so the tilt looks the same for small and large diameters. At most 30 % of the image height from the middle (keeps
%the labels clear of the text in the bottom right corner).
height = image_size(1);
middle = height / 2;
label_x = zeros(1, 3);
label_y = zeros(1, 3) + middle;
for c = 1:3
	label_x(c) = x_offset + (col_edges(c) + col_edges(c+1)) / 2;
end
reference = values(2);
if isnan(reference)
	reference = median(values, 'omitnan');
end
if isnan(reference) || reference <= 0
	return
end
for c = 1:3
	if ~isnan(values(c))
		shift = 0.5 * (values(c) - reference) / reference * height;
		shift = max(min(shift, 0.3 * height), -0.3 * height);
		label_y(c) = middle - shift; %the image y axis points down
	end
end
end

function draw_tilt_lines(PIVlab_axis, label_x, label_y, has_value, x_offset, image_size)
%Faint horizontal reference line at the reference value (the middle of the image) and a line through the thirds
%that have a value (Scheimpflug adjustment: tune until the line is straight and horizontal). Same tag as the texts:
%the capture code deletes the overlay by this tag.
if nnz(has_value) < 2
	return
end
y_reference = image_size(1) / 2;
line(PIVlab_axis, x_offset + [1 image_size(2)], [y_reference y_reference], 'Color', [1 1 0 0.35], 'LineStyle', '--', ...
	'LineWidth', 1.5, 'tag', 'sharpness_display_text', 'HitTest', 'off', 'PickableParts', 'none');
line(PIVlab_axis, label_x(has_value), label_y(has_value), 'Color', [1 1 0 0.8], 'LineWidth', 3, ...
	'tag', 'sharpness_display_text', 'HitTest', 'off', 'PickableParts', 'none');
end

function label = format_diameter(d, mode)
%Particle diameter in whole pixels; the board edge width (mostly 1-5 px) keeps one decimal.
if isnan(d)
	label = '-';
elseif strcmp(mode, 'particles')
	label = int2str(d);
else
	label = sprintf('%.1f', d);
end
end
