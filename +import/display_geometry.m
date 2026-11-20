function geo = display_geometry(cam, raw_size, raw_class)
%DISPLAY_GEOMETRY Where each pixel of the corrected image comes from, for the display at screen resolution.
%   geo = import.display_geometry(cam, raw_size, raw_class)
%   cam        camera settings (import.cam_settings), as used by preproc.cam_undistort_with
%   raw_size   size of the frame as read (gray: [height width])
%   raw_class  class of the frame as read
%
%   geo.identity   true: no lens undistortion, rectification or stereo transform
%   geo.out_size   [height width] of the corrected image (as import.read_frame returns it)
%   geo.out_class  class of the corrected image
%   geo.scale      corrected grey value = scale * source grey value (stereo: uint8 -> uint16)
%   geo.Fx, geo.Fy, geo.Fw  interpolants over the corrected image (row, column):
%                  Fx ./ Fw, Fy ./ Fw = column / row of the source pixel, Fw = weight
%                  (1 inside, 0 where the corrected image has no source, in between at the edge)
%
%   The geometry is not modelled here: it is measured by sending coordinate images (x and y of
%   every pixel) and a constant image through the real correction (preproc.cam_undistort_with), at
%   full resolution, once per camera setting. So the display always has the geometry of the
%   analysis (standard / tilted lens model, OutputView same / valid / full, rectification, stereo).
%   The coordinate maps are kept on every 4th pixel (the maps are smooth), in single precision.
%   The last 4 camera settings are kept (e.g. both cameras of a stereo setup, views of the lens
%   calibration); measuring once takes 1-7 s for a 26 MP frame.
persistent cache_keys cache_geos
if isempty(cache_keys)
	cache_keys = {};
	cache_geos = {};
end
raw_size = raw_size(1:2);
geo.identity = ~cam_changes_geometry(cam);
geo.out_size = raw_size;
geo.out_class = raw_class;
geo.scale = 1;
geo.Fx = [];
geo.Fy = [];
geo.Fw = [];
if geo.identity
	return
end
key = {cam_key(cam), raw_size, raw_class};
for k = 1:numel(cache_keys)
	if isequaln(cache_keys{k}, key) % isequaln: maps may contain NaN
		geo = cache_geos{k};
		% most recently used first
		order = [k, 1:k-1, k+1:numel(cache_keys)];
		cache_keys = cache_keys(order);
		cache_geos = cache_geos(order);
		return
	end
end
H = raw_size(1);
W = raw_size(2);
[X, Y] = meshgrid(single(1:W), single(1:H));
Xo = preproc.cam_undistort_with(X, cam);
clear X
Yo = preproc.cam_undistort_with(Y, cam);
clear Y
% constant probe image of the raw class: size, class and grey value scale of the result, weight
if isinteger(zeros(1, raw_class))
	v = double(intmax(raw_class)) / 2;
	v = round(v);
else
	v = 1;
end
P = preproc.cam_undistort_with(v * ones(H, W, raw_class), cam);
geo.out_size = [size(P, 1) size(P, 2)];
geo.out_class = class(P);
Pd = double(P);
clear P
inner = Pd(Pd > 0);
if isempty(inner)
	geo.scale = 1;
else
	geo.scale = median(inner) / v;
end
Wt = single(Pd / (geo.scale * v));
clear Pd
rows = unique([1:4:geo.out_size(1), geo.out_size(1)]);
cols = unique([1:4:geo.out_size(2), geo.out_size(2)]);
geo.Fx = griddedInterpolant({rows, cols}, single(Xo(rows, cols)), 'linear', 'nearest');
geo.Fy = griddedInterpolant({rows, cols}, single(Yo(rows, cols)), 'linear', 'nearest');
geo.Fw = griddedInterpolant({rows, cols}, single(Wt(rows, cols)), 'linear', 'nearest');
cache_keys = [{key}, cache_keys(1:min(3, end))];
cache_geos = [{geo}, cache_geos(1:min(3, end))];
end

function key = cam_key(cam)
% the camera settings as cache key. A stereo map (two full size arrays) is replaced by its size and
% 65536 samples spread over both arrays (a new disparity correction changes the smooth maps
% everywhere): the cache keeps no old maps alive and the comparison stays cheap.
key = cam;
if isfield(cam, 'stereo_map') && ~isempty(cam.stereo_map)
	m = cam.stereo_map;
	idx = round(linspace(1, numel(m.x), 65536));
	key.stereo_map = {size(m.x), m.x(idx), m.y(idx)};
end
end

function changes = cam_changes_geometry(cam)
% the same decision as preproc.cam_undistort_with / preproc.cam_undistort
if isfield(cam, 'stereo_map') && ~isempty(cam.stereo_map)
	changes = true;
elseif isfield(cam, 'use_calibration') && ~isempty(cam.use_calibration) && cam.use_calibration
	changes = true;
else
	changes = false;
end
end
