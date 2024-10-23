function currentimage = draw_pixel_background_overlay(target_axis,displaywhat, selected, handles, currentframe)
derivative_alpha=str2double(get(handles.colormapopacity ,'string'))/100;
if isnan(derivative_alpha) || derivative_alpha>100 || derivative_alpha <0
	derivative_alpha=75;
	set(handles.colormapopacity ,'string','75');
end

%% draw background particle image in gray
[currentimage,~]=import.get_img(selected);
if size(currentimage,3)>1 % color image
	currentimage=rgb2gray(currentimage); %convert to gray, always.
end
if get(handles.enhance_images, 'Value')
	currentimage=imadjust(currentimage);
end

image(cat(3, currentimage, currentimage, currentimage), 'parent',target_axis, 'cdatamapping', 'scaled');
colormap('gray');
axis image

derived=gui.retr('derived');

if size(derived,2)>=(currentframe+1)/2 && displaywhat > 1 && numel(derived{displaywhat-1,(currentframe+1)/2})>0 %derived parameters requested and existant
else
	if get(handles.derivchoice,'Value')>1
		text(15,15,'This parameter needs to be calculated for this frame first. Go to Plot -> Spatial: Derive Parameters and click "Apply to all frames".','color','r','fontsize',9, 'BackgroundColor', 'k', 'tag', 'derivhint')
	end
end

%% load masks, convert to binary image

render_mask=1; % should the mask be rendered in the image display?
if get(handles.mask_edit_mode,'Value')==2 %Mask mode is "Preview"
	masks_in_frame=gui.retr('masks_in_frame');
	if isempty(masks_in_frame)
		%masks_in_frame=cell(floor((currentframe+1)/2),1);
		masks_in_frame=cell(1,floor((currentframe+1)/2));
	end
	if numel(masks_in_frame)<floor((currentframe+1)/2)
		mask_positions=cell(0);
		render_mask=0;
	else
		mask_positions=masks_in_frame{floor((currentframe+1)/2)};
		if isempty (mask_positions)
			render_mask=0;
		end
	end
	converted_mask=mask.convert_masks_to_binary(size(currentimage(:,:,1)),mask_positions);
else
	converted_mask=zeros(size(currentimage(:,:,1)));
	render_mask=0;
end

if ~isempty(derived) && size(derived,2)>=(currentframe+1)/2 && displaywhat > 1  && numel(derived{displaywhat-1,(currentframe+1)/2})>0 %derived parameters requested and existant
	currentimage=derived{displaywhat-1,(currentframe+1)/2};
	if displaywhat ==11 % 11 ist vector direction
		is_it_vector_direction=1;
	else
		is_it_vector_direction=0;
	end

	%set colormap
	if displaywhat ~=10 %10 is LIC
		avail_maps=get(handles.colormap_choice,'string');
		selected_index=get(handles.colormap_choice,'value');
		if selected_index == 4 %HochschuleBremen map
			load(fullfile('+plot','hsbmap.mat'),'hsb');
			MAP = colormap(hsb);
		elseif selected_index== 1 %parula
			load(fullfile('+plot','parula.mat'),'parula')
			MAP = colormap (parula);
			elseif selected_index== 16 %plasma
			load(fullfile('+plot','plasma.mat'),'plasma')
			MAP = colormap (plasma);
		else
			MAP = colormap(avail_maps{selected_index});
		end
		%adjust colormap steps
		cmap = MAP;
		colormap_steps_list=get(handles.colormap_steps,'String');
		colormap_steps_value=get(handles.colormap_steps,'Value');
		colormap_steps=str2double(colormap_steps_list{colormap_steps_value});
		cmap_new=interp1(1:size(cmap,1),cmap,linspace(1,size(cmap,1),colormap_steps));
		%colormap(cmap_new);
		MAP = colormap(cmap_new);
	else %LIC can only be gray
		MAP = colormap('gray');
	end

	currentimage = plot.rescale_maps(currentimage,is_it_vector_direction);

	if get(handles.autoscaler,'value')==1
		minscale=min(currentimage(:));
		maxscale=max(currentimage(:));
		n=2;

		logflr = floor(log10(abs(minscale)));
		pof10 = 10.^(n-1-logflr);
		minscale_adjusted = floor(minscale.*pof10)./pof10;
		if ~isfinite(minscale_adjusted)
			minscale_adjusted=minscale;
		end

		logflr = floor(log10(abs(maxscale)));
		pof10 = 10.^(n-1-logflr);
		maxscale_adjusted = ceil(maxscale.*pof10)./pof10;
		if ~isfinite(maxscale_adjusted)
			maxscale_adjusted=maxscale;
		end

		set (handles.mapscale_min, 'string', num2str(minscale_adjusted))
		set (handles.mapscale_max, 'string', num2str(maxscale_adjusted))
	else
		minscale=str2double(get(handles.mapscale_min, 'string'));
		maxscale=str2double(get(handles.mapscale_max, 'string'));
		minscale_adjusted=minscale;
		maxscale_adjusted=maxscale;
	end

	colormap_steps_list=get(handles.colormap_steps,'String');
	colormap_steps_value=get(handles.colormap_steps,'Value');
	colormap_steps=str2double(colormap_steps_list{colormap_steps_value});

	%%convert grayscale map to RGB map to display it in color and as overlay

	%% Normalize the Imagerange to the desired range:

	currentimage(currentimage<minscale_adjusted)=minscale_adjusted;
	currentimage(currentimage>maxscale_adjusted)=maxscale_adjusted;
	currentimage=(currentimage-minscale_adjusted) / (maxscale_adjusted - minscale_adjusted) ;
	currentimage = uint8(floor(currentimage * colormap_steps));
	%currentimage_RGB = ind2rgb(currentimage, MAP);
	if get(handles.mask_edit_mode,'Value')==2 %Mask mode is "Preview"
		alpha_pixel_map=1-converted_mask; %regions that are mask get zero opaqueness.
	else
		alpha_pixel_map=ones(size(currentimage,1),size(currentimage,2),'logical');
	end
	roirect=gui.retr('roirect');
	alpha_ROI_map=zeros(size(currentimage,1),size(currentimage,2),'logical');
	if ~isempty(roirect) && size(roirect,2)>1
		alpha_ROI_map (roirect(2):(roirect(2)+roirect(4)) , roirect(1):(roirect(1)+roirect(3)))=1;
	else
		alpha_ROI_map(:)=1;
	end
	hold on;
	image(currentimage, 'parent',target_axis, 'cdatamapping', 'direct','AlphaData',derivative_alpha.*alpha_pixel_map.*alpha_ROI_map);
	hold off;

	%% colorbar
	if get(handles.colorbarpos,'value')~=1
		name=get(handles.derivchoice,'string');
		if strcmp(name,'N/A') %user hasn't visited the derived panel before
			if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
				set(handles.derivchoice,'String',{'Vectors [px/frame]';'Vorticity [1/frame]';'Magnitude [px/frame]';'u component [px/frame]';'v component [px/frame]';'Divergence [1/frame]';'Vortex locator [1]';'Simple shear rate [1/frame]';'Simple strain rate [1/frame]';'Line integral convolution (LIC) [1]' ; 'Vector direction [degrees]'; 'Correlation coefficient [-]'});
				set(handles.text35,'String','u [px/frame]:')
				set(handles.text36,'String','v [px/frame]:')
			else
				set(handles.derivchoice,'String',{'Vectors [m/s]';'Vorticity [1/s]';'Magnitude [m/s]';'u component [m/s]';'v component [m/s]';'Divergence [1/s]';'Vortex locator [1]';'Simple shear rate [1/s]';'Simple strain rate [1/s]';'Line integral convolution (LIC) [1]'; 'Vector direction [degrees]'; 'Correlation coefficient [-]'});
				set(handles.text35,'String','u [m/s]:')
				set(handles.text36,'String','v [m/s]:')
			end
			name=get(handles.derivchoice,'String');
		end

		posichoice = get(handles.colorbarpos,'String');

		parentfigure_of_target_axis=ancestor(target_axis,'figure');
		coloobj=colorbar(posichoice{get(handles.colorbarpos,'Value')},'Fontsize',12,'HitTest','off','parent',parentfigure_of_target_axis);

		axis (target_axis,'image');
		strcmp(posichoice{get(handles.colorbarpos,'Value')},'EastOutside');
		strcmp(posichoice{get(handles.colorbarpos,'Value')},'WestOutside');

		if strcmp(posichoice{get(handles.colorbarpos,'Value')},'EastOutside')==1 | strcmp(posichoice{get(handles.colorbarpos,'Value')},'WestOutside')==1
			ylabel(coloobj,name{gui.retr('displaywhat')},'fontsize',12,'fontweight','bold'); %9
		end
		if strcmp(posichoice{get(handles.colorbarpos,'Value')},'NorthOutside')==1 | strcmp(posichoice{get(handles.colorbarpos,'Value')},'SouthOutside')==1
			xlabel(coloobj,name{gui.retr('displaywhat')},'fontsize',12,'fontweight','bold'); %11
		end

		tickamount=min([colormap_steps 8])+1; % depends on the amount of colormap steps
		coloobj.Ticks=linspace(0,colormap_steps,tickamount);
		ticklabels=linspace(minscale_adjusted,maxscale_adjusted,tickamount);
		ticklabels_string=num2str(ticklabels(:),'%0.3e');
		coloobj.TickLabels =ticklabels_string;
	end
end
%% plot masks in preview mode (not in edit mode)
if 	render_mask==1 && get(handles.mask_edit_mode,'Value')==2 %mask preview mode
	mask_dimensions=size(converted_mask);
	x=[1 mask_dimensions(2)];
	y=[1,mask_dimensions(1)];
	skip_mask_pixels = round(0.0000020*mask_dimensions(1)*mask_dimensions(2) - 7); %reduce the amount of pixels displayed for the mask to save render time.
	if skip_mask_pixels>5
		skip_mask_pixels=5;
	end
	if skip_mask_pixels<1
		skip_mask_pixels=1;
	end
	hold on;
	image(x,y,cat(3, converted_mask(1:skip_mask_pixels:end,1:skip_mask_pixels:end)*0.7, converted_mask(1:skip_mask_pixels:end,1:skip_mask_pixels:end)*0.1, converted_mask(1:skip_mask_pixels:end,1:skip_mask_pixels:end)*0.1), 'parent',target_axis, 'cdatamapping', 'direct','AlphaData',converted_mask(1:skip_mask_pixels:end,1:skip_mask_pixels:end)*(1-(str2num(get(handles.masktransp,'String'))/100)));
	hold off
end

