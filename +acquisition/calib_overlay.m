function varargout = calib_overlay(what, varargin)
%CALIB_OVERLAY Drawing of the calibration overlay (live ChArUco detection) on a camera image. Used by the live
%image of the image acquisition (PIVlab_capture_charuco_detector, acquisition.draw_camera_overlap) and by the
%camera views of the 3D preview of the particle image generator (simulate.preview_3d), so that both look the same.
%All objects are in the axes ax, in camera pixels; camera k's image starts at x = x_offset + 1 (stereo: side by
%side). The objects of a camera are kept and updated (tag per camera: no flicker, no new objects per frame).
%
%   acquisition.calib_overlay('markers', ax, camera, x_offset, locs, line_width)
%       outline of each marker; locs: 4x2xN corners (readArucoMarker), [] = none
%   acquisition.calib_overlay('qr_box', ax, camera, x_offset, loc, line_width)
%       corner brackets around the QR code; loc: finder pattern centres (readBarcode: bottom left, top left,
%       top right), [] = none
%   acquisition.calib_overlay('status', ax, camera, x_offset, image_size, lines, font_size, y_fraction)
%       status block (cellstr lines) in the top left corner of the camera image, below the QR status
%   acquisition.calib_overlay('qr_status', ax, qr_params, font_size)
%       line in the top left corner of the axes: board parameters of the QR code (qr_params: patternDims,
%       checkerSize, markerSize, originCheckerColor), [] = "No QR code detected"
%   line = acquisition.calib_overlay('overlap', ax, camera, x_offset, ov)
%       dashed outline (colour of the other camera) of the part of camera's image that the other camera sees
%       too (ov: acquisition.camera_overlap; none when ~ov.ok); line: "Overlap: xx %" for the status block
%   h = acquisition.calib_overlay('camera_label', ax, camera, x, y)
%       label " CAMERA k " in the camera's colour, its bottom left corner at (x, y)
%   map = acquisition.calib_overlay('colormap')
%       grey colour map of the camera images, darkest and brightest values marked (green / red: clipping)
%   style = acquisition.calib_overlay('style', mode)
%       line widths and font sizes of the elements (.markers, .qr_box, .status, .qr_status, .y_fraction):
%       mode 'single' (one camera shown: full detection), 'stereo' (two cameras side by side), 'demo'
%   p = acquisition.calib_overlay('marker_percentage', n_markers, patternDims)
%       markers found in % of the markers of the board (at most 100)
switch what
	case 'markers'
		draw_markers(varargin{:});
	case 'qr_box'
		draw_qr_box(varargin{:});
	case 'status'
		draw_status(varargin{:});
	case 'qr_status'
		draw_qr_status(varargin{:});
	case 'overlap'
		varargout{1} = draw_overlap(varargin{:});
	case 'camera_label'
		varargout{1} = camera_label(varargin{:});
	case 'colormap'
		varargout{1} = live_colormap();
	case 'style'
		varargout{1} = overlay_style(varargin{:});
	case 'marker_percentage'
		varargout{1} = min(100, round(varargin{1} / (varargin{2}(1) * varargin{2}(2) / 2) * 100));
	otherwise
		error('acquisition:calib_overlay:what', 'Unknown overlay element: %s', what);
end
end

function draw_markers(ax, camera, x_offset, locs, line_width)
%Outline of each detected marker (its 4 corners), one yellow line: it lies on the light border around the
%marker, readable without a dark edge (a second, wider line below it looked uneven: both are rasterised
%separately). One patch object per camera with one face per marker (closed outlines: all corners joined the
%same way).
vertices = NaN(1,2);
faces = NaN(1,4);
if ~isempty(locs)
	n = size(locs,3);
	vertices = [reshape(locs(:,1,:),[],1) + x_offset, reshape(locs(:,2,:),[],1)]; % corner c of marker i in row 4*(i-1)+c
	faces = reshape(1:4*n,4,n)';
end
markers = overlay_object(ax,sprintf('charucolabel_markers_cam%d',camera),'patch');
set(markers,'Faces',faces,'Vertices',vertices,'EdgeColor',[1 0.85 0],'LineWidth',line_width);
end

function draw_qr_box(ax, camera, x_offset, loc, line_width)
%Four corner brackets around the QR code, along its edges (follows rotation and perspective); hidden when no
%QR code was read. loc: finder pattern centres from readBarcode (bottom left, top left, top right).
x = NaN;
y = NaN;
if size(loc,1) == 3
	corners = [loc(2,:); loc(3,:); loc(3,:)+loc(1,:)-loc(2,:); loc(1,:)]; % finder centres + the 4th corner
	centre = mean(corners,1);
	% version 1 code: 21 modules, finder centres 7 modules from the centre, edge at 10.5; bracket 1 module outside
	corners = centre + (corners - centre) * (11.5/7);
	x = [];
	y = [];
	for i = 1:4
		previous = corners(mod(i-2,4)+1,:);
		next = corners(mod(i,4)+1,:);
		bracket = [corners(i,:) + 0.25*(previous-corners(i,:)); corners(i,:); corners(i,:) + 0.25*(next-corners(i,:)); NaN NaN];
		x = [x; bracket(:,1)]; %#ok<AGROW>
		y = [y; bracket(:,2)]; %#ok<AGROW>
	end
	x = x + x_offset;
end
box = overlay_object(ax,sprintf('charucolabel_qr_cam%d',camera),'line');
set(box,'XData',x,'YData',y,'Color',[0.3 0.6 1],'LineWidth',line_width);
end

function draw_status(ax, camera, x_offset, image_size, lines, font_size, y_fraction)
%Status block (marker percentage, position, pose) in the top left corner of the camera image, below the QR status
status = overlay_object(ax,sprintf('charucolabel_status_cam%d',camera),'text');
y = y_fraction*image_size(1);
qr_status = findobj(ax,'tag','charucolabel_qrstatus');
if ~isempty(qr_status) && strcmp(ax.YDir,'reverse')
	% directly below the QR status line (its height on screen depends on the display size)
	extent = qr_status(1).Extent; % normalized axes units: [left bottom width height], bottom of the axes = YLim(2)
	y_limits = ax.YLim;
	y = y_limits(2) - extent(2)*diff(y_limits) + 0.005*diff(y_limits);
end
set(status,'Position',[x_offset+0.01*image_size(2), y, 0],'String',lines,'FontSize',font_size);
end

function draw_qr_status(ax, qr_params, font_size)
%Persistent info in the top left corner: were the board parameters read from a QR code?
if ~isempty(qr_params)
	statustxt=['QR code: ' num2str(qr_params.patternDims(1)) ' x ' num2str(qr_params.patternDims(2)) ' | checker ' num2str(qr_params.checkerSize) ' mm | marker ' num2str(qr_params.markerSize) ' mm | origin ' char(qr_params.originCheckerColor)];
	bgcolor='b';
else
	statustxt='No QR code detected: using manual board parameters';
	bgcolor=[0.85 0.4 0];
end
status = findobj(ax,'tag','charucolabel_qrstatus'); %kept and updated
if isempty(status)
	status = text(ax,0.01,0.99,'','Units','normalized','tag','charucolabel_qrstatus','Color','w','FontWeight','bold','HorizontalAlignment','left','VerticalAlignment','top','Interpreter','none','HitTest','off');
end
set(status,'String',statustxt,'BackgroundColor',bgcolor,'FontSize',font_size);
end

function status_line = draw_overlap(ax, camera, x_offset, ov)
%the frame of the other camera in this camera's image, dashed, in the other camera's colour (camera 1 blue,
%camera 2 orange): one patch per camera with one face per piece of the region
vertices = NaN(1,2);
faces = NaN(1,3);
status_line = 'Overlap: -'; % "-" without a common board, so that the status block keeps its height
if ov.ok
	status_line = sprintf('Overlap: %d %%', round(ov.fraction(camera)*100));
	pieces = regions(ov.region{camera});
	outlines = cell(numel(pieces), 1);
	for r = 1:numel(pieces)
		[x, y] = boundary(pieces(r));
		% boundary repeats the first vertex at the end; patch closes the outline itself, and the zero length edge
		% would draw a spike at that corner
		outlines{r} = [x(1:end-1) + x_offset, y(1:end-1)];
	end
	if ~isempty(outlines)
		counts = cellfun(@(o) size(o,1), outlines);
		vertices = vertcat(outlines{:});
		faces = NaN(numel(outlines), max(counts));
		first = cumsum([0; counts(1:end-1)]);
		for r = 1:numel(outlines)
			faces(r, 1:counts(r)) = first(r) + (1:counts(r));
		end
	end
end
color = stereo.camera_colors(3 - camera);
frame = overlay_object(ax,sprintf('charucolabel_overlap_cam%d',camera),'patch');
set(frame,'Faces',faces,'Vertices',vertices,'EdgeColor',color,'LineWidth',2,'LineStyle','--');
end

function style = overlay_style(mode)
%line widths and font sizes of the live image: with two cameras side by side thinner (they share the display)
switch mode
	case 'stereo'
		style = struct('markers', 1.5, 'qr_box', 6, 'status', 12, 'qr_status', 14, 'y_fraction', 0.06);
	case 'demo'
		style = struct('markers', 4, 'qr_box', 18, 'status', 24, 'qr_status', 24, 'y_fraction', 0.09);
	otherwise % 'single'
		style = struct('markers', 2, 'qr_box', 9, 'status', 14, 'qr_status', 14, 'y_fraction', 0.06);
end
end

function label = camera_label(ax, camera, x, y)
[cam_color, text_color] = stereo.camera_colors(camera);
label = text(ax, x, y, [' CAMERA ' int2str(camera) ' '], 'VerticalAlignment', 'bottom', ...
	'HorizontalAlignment', 'left', 'FontWeight', 'bold', 'FontSize', 12, 'BackgroundColor', cam_color, ...
	'Color', text_color, 'Margin', 2, 'Tag', 'capture_camera_label', 'HitTest', 'off', 'PickableParts', 'none');
end

function map = live_colormap()
map = gray(256);
map(1:3, :) = [0 0.2 0; 0 0.2 0; 0 0.2 0];
map(end-2:end, :) = [1 0.7 0.7; 1 0.7 0.7; 1 0.7 0.7];
end

function h = overlay_object(ax, tag, kind)
%patch, line or text of the overlay: the existing one (updated by the caller) or a new one
h = findobj(ax,'tag',tag);
if numel(h) > 1
	delete(h(2:end));
	h = h(1);
end
if isempty(h)
	if strcmp(kind,'patch')
		h = patch(ax,'Faces',NaN(1,4),'Vertices',NaN(1,2),'FaceColor','none','LineJoin','round','tag',tag,'HitTest','off','PickableParts','none');
	elseif strcmp(kind,'line')
		h = line(ax,NaN,NaN,'LineJoin','round','tag',tag,'HitTest','off','PickableParts','none');
	else
		h = text(ax,0,0,'','tag',tag,'Color','w','BackgroundColor',[0 0 0 0.6],'FontWeight','bold', ...
			'HorizontalAlignment','left','VerticalAlignment','top','Interpreter','none','HitTest','off','PickableParts','none');
	end
end
end
