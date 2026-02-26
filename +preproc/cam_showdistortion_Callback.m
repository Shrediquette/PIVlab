function cam_showdistortion_Callback(~,~,~)
cameraParams = gui.retr('cameraParams');
if ~isempty(cameraParams)

	% Bildgröße
	width  = cameraParams.ImageSize(2);
	height = cameraParams.ImageSize(1);

	% Kameraparameter
	cx = cameraParams.PrincipalPoint(1);
	cy = cameraParams.PrincipalPoint(2);
	fx = cameraParams.FocalLength(1);
	fy = cameraParams.FocalLength(2);

	% Radialkoeffizienten
	k1=cameraParams.RadialDistortion(1);
	k2=cameraParams.RadialDistortion(2);
	if numel (cameraParams.RadialDistortion) > 2
		k3 = cameraParams.RadialDistortion(3);
	else
		k3=0;
	end

	[xpix, ypix] = meshgrid(1:width, 1:height);
	x = (xpix - cx) / fx;
	y = (ypix - cy) / fy;
	r2 = x.^2 + y.^2;
	scale = 1 + k1*r2 + k2*r2.^2 + k3*r2.^3;

	% --- Verzerrte Koordinaten ---
	xd = x .* scale;
	yd = y .* scale;

	% --- Abweichung in normalisierten Koordinaten ---
	dx = xd - x;
	dy = yd - y;

	% Zurück in Pixel
	dx_pix = dx * fx;
	dy_pix = dy * fy;

	dist_mag = sqrt(dx_pix.^2 + dy_pix.^2);

	[H,W] = size(dist_mag);

	row_idx = round(H/2);
	col_idx = round(W/2);

	hProfile = dist_mag(row_idx,:);
	vProfile = dist_mag(:,col_idx);

	dist_fig=figure('Name','Distortion offsets in pixels','DockControls','off','WindowStyle','normal','Scrollable','off','MenuBar','figure','Resize','off','ToolBar','none','NumberTitle','off');

	% Layout parameters
	topHeight   = 0.18;
	rightWidth  = 0.18;
	gap = 0.02;

	% ---- Adjust figure aspect ratio for square pixels ----
	axesWidth  = 1 - rightWidth - 2*gap;
	axesHeight = 1 - topHeight  - 2*gap;

	targetRatio = (W/H) * (axesHeight/axesWidth);

	pos = dist_fig.Position;   % [left bottom width height]

	newWidth  = pos(4) * targetRatio;
	dist_fig.Position = [pos(1) pos(2) newWidth pos(4)];
	% --- Image axis (center) ---
	axImg = axes(dist_fig,'Position', ...
		[gap, gap, ...
		1-rightWidth-2*gap, ...
		1-topHeight-2*gap]);

	imagesc(dist_mag,'Parent',axImg);
	set(axImg,'YDir','reverse')
	xlim([1 W])
	ylim([1 H])
	axImg.Position
	hold on
	line([1 W],[row_idx row_idx],'Color','w')
	line([col_idx col_idx],[1 H],'Color','w')
	axImg.Position

	% Disable ticks on image
	axImg.XTick = [];
	axImg.YTick = [];
	box on

	% --- Horizontal profile (top) ---
	axTop = axes('Position', ...
		[gap, ...
		1-topHeight-gap, ...
		1-rightWidth-2*gap, ...
		topHeight-gap]);

	plot(1:W, hProfile, 'LineWidth',2)
	xlim([1 W])
	axTop.XAxisLocation = 'top';
	box on
	grid on

	% --- Vertical profile (right) ---
	axRight = axes('Position', ...
		[1-rightWidth-gap, ...
		gap, ...
		rightWidth-gap, ...
		1-topHeight-2*gap]);
	plot(vProfile, 1:H, 'LineWidth',2)
	set(axRight,'YDir','reverse')
	ylim([1 H])
	axRight.YAxisLocation = 'right';
	box on
	grid on
end