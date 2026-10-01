function currentimage = draw_pixel_background_overlay(target_axis,displaywhat, selected, handles, currentframe)
%Collects the display settings of the GUI and draws particle image, derived map and mask.
%The drawing itself (plot.draw_background) is shared with the command-line API (pivlab.display).
derivative_alpha=str2double(get(handles.colormapopacity ,'string'))/100;
if isnan(derivative_alpha) || derivative_alpha>100 || derivative_alpha <0
	derivative_alpha=75;
	set(handles.colormapopacity ,'string','75');
end
[currentimage,~]=import.get_img(selected);

derived=gui.retr('derived');
map_available = ~isempty(derived) && size(derived,2)>=(currentframe+1)/2 && displaywhat > 1 && numel(derived{displaywhat-1,(currentframe+1)/2})>0; %derived parameters requested and existant

%% options from the GUI controls
o.alpha = derivative_alpha;
o.displ_image = get(handles.displ_image,'Value'); %1 = piv image, 2= black, 3 = white
o.enhance = get(handles.enhance_images, 'Value')==1;
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
if ~map_available && get(handles.derivchoice,'Value')>1
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
	o.mask=mask.convert_masks_to_binary(size(currentimage(:,:,1)),mask_positions);
end

%% derived map, interpolated to the image size
map = [];
if map_available
	if ~strcmpi(o.colorbar_position,'None')
		name=get(handles.derivchoice,'string');
		if strcmp(name,'N/A') %user hasn't visited the derived panel before
			if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
				set(handles.derivchoice,'String',{'Vectors in px/frame';'Vorticity in 1/frame';'Magnitude in px/frame';'u component in px/frame';'v component in px/frame';'Divergence in 1/frame';'Q criterion in 1/frame^2';'Shear rate (magnitude of the rate-of-strain tensor) in 1/frame';'Simple strain rate in 1/frame';'Line integral convolution (LIC)' ; 'Vector direction in degrees'; 'Correlation coefficient'});
				set(handles.text35,'String','u in px/frame:')
				set(handles.text36,'String','v in px/frame:')
			else %calibrated
				displacement_only=gui.retr('displacement_only');
				if ~isempty(displacement_only) && displacement_only == 1
					set(handles.derivchoice,'String',{'Vectors in m/frame';'Vorticity in 1/frame';'Magnitude in m/frame';'u component in m/frame';'v component in m/frame';'Divergence in 1/frame';'Q criterion in 1/frame^2';'Shear rate (magnitude of the rate-of-strain tensor) in 1/frame';'Simple strain rate in 1/frame';'Line integral convolution (LIC)'; 'Vector direction in degrees'; 'Correlation coefficient'});
					set(handles.text35,'String','u in m/frame:')
					set(handles.text36,'String','v in m/frame:')
				else
					set(handles.derivchoice,'String',{'Vectors in m/s';'Vorticity in 1/s';'Magnitude in m/s';'u component in m/s';'v component in m/s';'Divergence in 1/s';'Q criterion in 1/s^2';'Shear rate (magnitude of the rate-of-strain tensor) in 1/s';'Simple strain rate in 1/s';'Line integral convolution (LIC)'; 'Vector direction in degrees'; 'Correlation coefficient'});
					set(handles.text35,'String','u in m/s:')
					set(handles.text36,'String','v in m/s:')
				end
			end
			name=get(handles.derivchoice,'String');
		end
		o.colorbar_label = name{gui.retr('displaywhat')};
	end
	map = plot.rescale_maps(derived{displaywhat-1,(currentframe+1)/2},displaywhat==11); % 11 is vector direction
end

[currentimage, minscale_adjusted, maxscale_adjusted] = plot.draw_background(target_axis, currentimage, map, o);
if map_available && o.autoscale
	set (handles.mapscale_min, 'string', num2str(minscale_adjusted))
	set (handles.mapscale_max, 'string', num2str(maxscale_adjusted))
end
