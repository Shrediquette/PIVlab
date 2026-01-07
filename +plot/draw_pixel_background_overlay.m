function currentimage = draw_pixel_background_overlay(target_axis,displaywhat, selected, handles, currentframe)
derivative_alpha=str2double(get(handles.colormapopacity ,'string'))/100;
if isnan(derivative_alpha) || derivative_alpha>100 || derivative_alpha <0
	derivative_alpha=75;
	set(handles.colormapopacity ,'string','75');
end

%% draw background particle image in gray
image_display_type=get(handles.displ_image,'Value'); %1 = piv image, 2= black, 3 = white
[currentimage,~]=import.get_img(selected);
if size(currentimage,3)>1 % color image
    if size(currentimage,3)>3
        currentimage=currentimage(:,:,1:3); %Chronos prototype has 4channels (all identical...?)
    end
	currentimage=rgb2gray(currentimage); %convert to gray, always.
end


if image_display_type==1
	if get(handles.enhance_images, 'Value')
		currentimage=imadjust(currentimage);
	end
	image(cat(3, currentimage, currentimage, currentimage), 'parent',target_axis, 'cdatamapping', 'scaled');
elseif image_display_type==2 %black
	image(cat(3, currentimage*0, currentimage*0, currentimage*0), 'parent',target_axis, 'cdatamapping', 'scaled');
elseif image_display_type==3 %white
	image(cat(3, (currentimage+1)*inf, (currentimage+1)*inf, (currentimage+1)*inf), 'parent',target_axis, 'cdatamapping', 'scaled');
end
%disp(['Size of the image currently being display via sliderdisp: ' num2str(size(currentimage))])

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
            try
                load(fullfile('+plot','hsbmap.mat'),'hsb');
                MAP = colormap(hsb);
            catch
                disp(['hsbmap.mat not found in ' fullfile('+plot','hsbmap.mat')])
                MAP=colormap("parula");
            end
        elseif selected_index== 1 %parula
            try
                load(fullfile('+plot','parula.mat'),'parula')
                MAP = colormap (parula);
            catch
                disp(['parula.mat not found in ' fullfile('+plot','parula.mat')])
                MAP=colormap("parula");
            end
        elseif selected_index== 16 %plasma
            try
                load(fullfile('+plot','plasma.mat'),'plasma')
                MAP = colormap (plasma);
            catch
                disp(['plasma.mat not found in ' fullfile('+plot','plasma.mat')])
                MAP=colormap("parula");
            end
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
	alphamap=derivative_alpha.*alpha_pixel_map.*alpha_ROI_map;
	alphamap(alphamap>1)=1;
	alphamap(alphamap<0)=0;
	%temporary workaround for bug in R2025 causing slow performance when not using alphadatamapping=scaled
	alphamap(1,1)=0;
	alphamap(end,end)=1;
	image(currentimage, 'parent',target_axis, 'cdatamapping', 'direct','AlphaData',alphamap,'AlphaDataMapping','scaled');
	hold off;

	%% colorbar
	if get(handles.colorbarpos,'value')~=1
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

        %do not modify ticklocations, only the label
%{
Tick=coloobj.Ticks;
ticklabels = minscale_adjusted + Tick/max(Tick) * (maxscale_adjusted-minscale_adjusted)
ticklabels_string=num2str(ticklabels(:),'%0.3f');
coloobj.TickLabels =ticklabels_string;
%}
        %pause(2);
        %bar_width=coloobj.Position(3);
        %coloobj.Position(3)=bar_width*0.95;
        %coloobj.Position(1)=coloobj.Position(1) + bar_width*0.05*0.5;
		tickamount=min([colormap_steps 8])+1; % depends on the amount of colormap steps
		coloobj.Ticks=linspace(0,colormap_steps,tickamount);
		ticklabels=linspace(minscale_adjusted,maxscale_adjusted,tickamount);
		if get(handles.colorbarnumberformat,'Value') == 1 % colorbar number format
			ticklabels_string=num2str(ticklabels(:),'%0.3g');
		elseif get(handles.colorbarnumberformat,'Value') == 2
			ticklabels_string=num2str(ticklabels(:),'%0.3e');
			elseif get(handles.colorbarnumberformat,'Value') == 3
				ticklabels_string=num2str(ticklabels(:),'%0.3f');
		end
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
	alphamapmask=converted_mask(1:skip_mask_pixels:end,1:skip_mask_pixels:end)*(1-(str2double(get(handles.masktransp,'String'))/100));
	alphamapmask(alphamapmask>1)=1;
	alphamapmask(alphamapmask<0)=0;
	%temporary workaround for bug in R2025 causing slow performance when not using alphadatamapping=scaled
	alphamapmask(1,1)=0;
	alphamapmask(end,end)=1;
	image(x,y,cat(3, converted_mask(1:skip_mask_pixels:end,1:skip_mask_pixels:end)*0.7, converted_mask(1:skip_mask_pixels:end,1:skip_mask_pixels:end)*0.1, converted_mask(1:skip_mask_pixels:end,1:skip_mask_pixels:end)*0.1), 'parent',target_axis, 'cdatamapping', 'direct','AlphaData',alphamapmask,'AlphaDataMapping','scaled');
	hold off
end

