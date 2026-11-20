function [currentimage, image_size] = draw_pixel_background_overlay(target_axis,displaywhat, selected, handles, currentframe, image_only, update)
%Collects the display settings of the GUI and draws particle image, derived map and mask.
%The drawing itself (plot.draw_background) is shared with the command-line API (pivlab.display).
%image_only (optional, default false): only the particle image and the mask, no derived map and no hint
%(e.g. under the disparity displays of the Stereo-PIV panel).
%update (optional, default false): after zoom / pan, only new data for the images at screen
%resolution (plot.redraw_display_resolution).
%image_size: [height width] of the full resolution frame.
%
%Large images in the PIVlab axes are drawn at screen resolution (import.read_frame_display,
%plot.display_grid): about one image pixel per screen pixel, only the visible part when zoomed in.
%Masks, the derived map and the ROI are computed at full resolution as before and only taken at the
%display pixel centres; all objects stay in full resolution pixel coordinates. Other axes (export,
%...) and images that fit on the screen are drawn at full resolution.
if nargin < 6
	image_only = false;
end
if nargin < 7
	update = false;
end
derivative_alpha=str2double(get(handles.colormapopacity ,'string'))/100;
if isnan(derivative_alpha) || derivative_alpha>1 || derivative_alpha <0 %opacity field in percent (0...100)
	derivative_alpha=0.75;
	set(handles.colormapopacity ,'string','75');
end
grid = [];
raw_read = [];
enhance_limits = [];
enhance_on = get(handles.enhance_images, 'Value')==1;
% data of the last full draw that zoom / pan redraws use again (with the key it was made from):
% the frame as read, the full resolution mask and the full resolution map
cache = struct('raw', [], 'raw_key', [], 'mask', [], 'mask_key', [], 'map_region', []);
if target_axis == gui.retr('pivlab_axis')
	[src, cam, bg] = import.frame_inputs(selected); % the same inputs as import.get_img
	if update
		limits = [get(target_axis,'XLim') get(target_axis,'YLim')];
		previous = getappdata(target_axis, 'display_resolution_state');
		if isfield(previous, 'enhance_limits')
			enhance_limits = previous.enhance_limits;
		end
		if isfield(previous, 'cache')
			cache = previous.cache;
		end
		raw_cached = [];
		if isequal(cache.raw_key, {src, selected})
			raw_cached = cache.raw;
		end
		[currentimage, grid, image_size, raw_read] = import.read_frame_display(src, selected, cam, bg, target_axis, limits, raw_cached);
	else
		xzoomlimit = gui.retr('xzoomlimit');
		yzoomlimit = gui.retr('yzoomlimit');
		limits = [];
		if ~isempty(xzoomlimit) && ~isempty(yzoomlimit)
			limits = [xzoomlimit(:)' yzoomlimit(:)'];
		end
		if enhance_on % contrast limits of the whole frame: the same contrast when zoomed
			[currentimage, grid, image_size, raw_read, whole] = import.read_frame_display(src, selected, cam, bg, target_axis, limits);
			if ~isempty(whole)
				enhance_limits = stretchlim(whole);
			end
		else
			[currentimage, grid, image_size, raw_read] = import.read_frame_display(src, selected, cam, bg, target_axis, limits);
		end
	end
	cache.raw = raw_read;
	cache.raw_key = {src, selected};
end
if isempty(grid)
	if update
		currentimage = [];
		image_size = [];
		return
	end
	[currentimage,~]=import.get_img(selected, raw_read); % the frame is not read again
	image_size = size(currentimage(:,:,1));
else
	import.note_image_size(image_size);
end

derived=gui.retr('derived');
map_available = ~image_only && ~isempty(derived) && size(derived,2)>=(currentframe+1)/2 && displaywhat > 1 && size(derived,1)>=displaywhat-1 && numel(derived{displaywhat-1,(currentframe+1)/2})>0; %derived parameters requested and existant

%% options from the GUI controls
o.alpha = derivative_alpha;
o.displ_image = get(handles.displ_image,'Value'); %1 = piv image, 2= black, 3 = white
o.enhance = enhance_on;
o.enhance_limits = enhance_limits;
avail_maps=get(handles.colormap_choice,'string');
o.colormap_name = avail_maps{get(handles.colormap_choice,'value')};
colormap_steps_list=get(handles.colormap_steps,'String');
o.colormap_steps = str2double(colormap_steps_list{get(handles.colormap_steps,'Value')});
o.is_lic = displaywhat==10;
o.autoscale = get(handles.autoscaler,'value')==1;
o.map_min = str2double(get(handles.mapscale_min, 'string'));
o.map_max = str2double(get(handles.mapscale_max, 'string'));
o.masktransp = str2double(get(handles.masktransp,'String'));
o.roirect = gui.retr('roirect');
posichoice = get(handles.colorbarpos,'String');
o.colorbar_position = posichoice{get(handles.colorbarpos,'Value')};
o.colorbar_format = get(handles.colorbarnumberformat,'Value');
o.colorbar_label = '';
if ~image_only && ~map_available && get(handles.derivchoice,'Value')>1
	o.after_image = @(ax) text(ax,15,15,'This parameter needs to be calculated for this frame first. Go to Plot -> Spatial: Derive Parameters and click "Apply to all frames".','color','r','fontsize',9, 'BackgroundColor', 'k', 'tag', 'derivhint');
end

%% masks
o.mask_preview = get(handles.mask_edit_mode,'Value')==2; %Mask mode is "Preview"
o.render_mask = false;
o.mask = [];
if o.mask_preview
	masks_in_frame=gui.retr('masks_in_frame');
	if isempty(masks_in_frame)
		masks_in_frame=cell(1,floor((currentframe+1)/2));
	end
	if numel(masks_in_frame)<floor((currentframe+1)/2)
		mask_positions=cell(0);
	else
		mask_positions=masks_in_frame{floor((currentframe+1)/2)};
		o.render_mask = ~isempty(mask_positions);
	end
	mask_key = {image_size, mask_positions};
	if update && isequal(cache.mask_key, mask_key)
		o.mask = cache.mask; % zoom / pan: the same masks
	else
		o.mask=mask.convert_masks_to_binary(image_size,mask_positions); % full resolution
	end
	cache.mask = o.mask;
	cache.mask_key = mask_key;
end

%% derived map, interpolated to the image size
map = [];
if map_available
	if ~strcmpi(o.colorbar_position,'None')
		name=get(handles.derivchoice,'string');
		if ~iscell(name) || numel(name)<displaywhat %user hasn't visited the derived panel before (or a stereo session added the w component)
			plot.update_derivchoice_list(handles)
			name=get(handles.derivchoice,'String');
		end
		o.colorbar_label = name{gui.retr('displaywhat')};
	end
	if isempty(grid)
		map = plot.rescale_maps(derived{displaywhat-1,(currentframe+1)/2},displaywhat==11,image_size); % 11 is vector direction; full resolution
	else
		% only the display pixels; the colour limits of the full resolution map
		map_region = [];
		if update
			map_region = cache.map_region; % zoom / pan: used again when the map is the same
		end
		[map, o.map_min_full, o.map_max_full, map_region] = plot.rescale_maps(derived{displaywhat-1,(currentframe+1)/2},displaywhat==11,image_size,grid,map_region);
		cache.map_region = map_region;
		o.map_at_display = true;
	end
end

[currentimage, minscale_adjusted, maxscale_adjusted] = plot.draw_background(target_axis, currentimage, map, o, grid, update);
if map_available && o.autoscale
	set (handles.mapscale_min, 'string', num2str(minscale_adjusted))
	set (handles.mapscale_max, 'string', num2str(maxscale_adjusted))
end
% what plot.redraw_display_resolution needs to draw the same content for new axes limits
if ~isempty(grid)
	state = struct('selected', selected, 'displaywhat', displaywhat, 'currentframe', currentframe, ...
		'image_only', image_only, 'region', grid.region, 'step', grid.step, 'full_size', grid.full_size, ...
		'enhance_limits', enhance_limits);
	state.cache = cache;
	setappdata(target_axis, 'display_resolution_state', state);
	% every change of the limits (also scroll wheel zoom / drag pan of the axes) draws the view again
	set(target_axis.XAxis, 'LimitsChangedFcn', @plot.limits_changed);
	set(target_axis.YAxis, 'LimitsChangedFcn', @plot.limits_changed);
elseif isappdata(target_axis, 'display_resolution_state')
	rmappdata(target_axis, 'display_resolution_state');
end
end
