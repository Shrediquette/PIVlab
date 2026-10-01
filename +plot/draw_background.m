function [currentimage, minscale_adjusted, maxscale_adjusted] = draw_background(target_axis, currentimage, map, o)
%DRAW_BACKGROUND Draw the particle image, the colour-coded derived map and the mask (no GUI needed).
%   [img, cmin, cmax] = plot.draw_background(target_axis, currentimage, map, o)
%
%   currentimage  particle image (gray or RGB, converted to gray)
%   map           derived map interpolated to the image size (plot.rescale_map_core), or []
%   o             display options:
%     alpha                opacity of the map, 0...1
%     displ_image          1 = particle image, 2 = black, 3 = white
%     enhance              true: imadjust the particle image
%     colormap_name        'Parula','HSV','Jet','HSB','Hot',...,'Plasma'
%     colormap_steps       number of colours
%     is_lic               true: the map is a LIC image (always gray)
%     autoscale            true: colour limits from the data (rounded to 2 digits)
%     map_min, map_max     colour limits when autoscale is false
%     mask                 logical mask image (true = masked) or []
%     mask_preview         true: masked areas are transparent in the map and drawn red
%     render_mask          true: draw the red mask overlay
%     masktransp           mask transparency in percent
%     roirect              region of interest [x y w h] or [] (map is only drawn inside)
%     colorbar_position    'None','SouthOutside','NorthOutside','EastOutside','WestOutside'
%     colorbar_label       label of the colour bar
%     colorbar_format      1 = %0.3g, 2 = %0.3e, 3 = %0.3f
%
%   img is the last image drawn (the scaled map if a map is shown), cmin / cmax the colour
%   limits that were used. Used by plot.draw_pixel_background_overlay (GUI) and pivlab.display.
minscale_adjusted = [];
maxscale_adjusted = [];
derivative_alpha = o.alpha;

%% draw background particle image in gray
if size(currentimage,3)>1 % color image
    if size(currentimage,3)>3
        currentimage=currentimage(:,:,1:3); %Chronos prototype has 4channels (all identical...?)
    end
    currentimage=rgb2gray(currentimage); %convert to gray, always.
end
if o.displ_image==1
    if o.enhance
        currentimage=imadjust(currentimage);
    end
    image(cat(3, currentimage, currentimage, currentimage), 'parent',target_axis, 'cdatamapping', 'scaled');
elseif o.displ_image==2 %black
    image(cat(3, currentimage*0, currentimage*0, currentimage*0), 'parent',target_axis, 'cdatamapping', 'scaled');
elseif o.displ_image==3 %white
    image(cat(3, (currentimage+1)*inf, (currentimage+1)*inf, (currentimage+1)*inf), 'parent',target_axis, 'cdatamapping', 'scaled');
end
colormap(target_axis,'gray');
axis(target_axis,'image');
if isfield(o,'after_image') && ~isempty(o.after_image)
    o.after_image(target_axis); % e.g. a hint text of the GUI, drawn on top of the particle image
end

%% mask as binary image
if o.mask_preview && ~isempty(o.mask)
    converted_mask=o.mask;
else
    converted_mask=zeros(size(currentimage(:,:,1)));
end
render_mask = o.mask_preview && o.render_mask;

if ~isempty(map)
    currentimage = map;
    %set colormap
    target_fig = ancestor(target_axis,'figure');
    if ~o.is_lic
        MAP = colormap(target_fig, plot.colormap_by_name(o.colormap_name));
        %adjust colormap steps
        cmap = MAP;
        cmap_new=interp1(1:size(cmap,1),cmap,linspace(1,size(cmap,1),o.colormap_steps));
        MAP = colormap(target_fig,cmap_new); %#ok<NASGU>
    else %LIC can only be gray
        MAP = colormap(target_fig,'gray'); %#ok<NASGU>
    end

    if o.autoscale
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
    else
        minscale_adjusted=o.map_min;
        maxscale_adjusted=o.map_max;
    end
    colormap_steps=o.colormap_steps;

    %% Normalize the Imagerange to the desired range:
    currentimage(currentimage<minscale_adjusted)=minscale_adjusted;
    currentimage(currentimage>maxscale_adjusted)=maxscale_adjusted;
    currentimage=(currentimage-minscale_adjusted) / (maxscale_adjusted - minscale_adjusted) ;
    currentimage = uint8(floor(currentimage * colormap_steps));
    if o.mask_preview
        alpha_pixel_map=1-converted_mask; %regions that are mask get zero opaqueness.
    else
        alpha_pixel_map=ones(size(currentimage,1),size(currentimage,2),'logical');
    end
    roirect=o.roirect;
    alpha_ROI_map=zeros(size(currentimage,1),size(currentimage,2),'logical');
    if ~isempty(roirect) && size(roirect,2)>1
        alpha_ROI_map (roirect(2):(roirect(2)+roirect(4)) , roirect(1):(roirect(1)+roirect(3)))=1;
    else
        alpha_ROI_map(:)=1;
    end
    hold(target_axis,'on');
    alphamap=derivative_alpha.*alpha_pixel_map.*alpha_ROI_map;
    alphamap(alphamap>1)=1;
    alphamap(alphamap<0)=0;
    %temporary workaround for bug in R2025 causing slow performance when not using alphadatamapping=scaled
    alphamap(1,1)=0;
    alphamap(end,end)=1;
    image(currentimage, 'parent',target_axis, 'cdatamapping', 'direct','AlphaData',alphamap,'AlphaDataMapping','scaled');
    hold(target_axis,'off');

    %% colorbar
    if ~strcmpi(o.colorbar_position,'None')
        position = o.colorbar_position;
        parentfigure_of_target_axis=ancestor(target_axis,'figure');
        coloobj=colorbar(position,'Fontsize',12,'HitTest','off','parent',parentfigure_of_target_axis);
        axis (target_axis,'image');
        if strcmp(position,'EastOutside') || strcmp(position,'WestOutside')
            ylabel(coloobj,o.colorbar_label,'fontsize',12,'fontweight','bold');
        end
        if strcmp(position,'NorthOutside') || strcmp(position,'SouthOutside')
            xlabel(coloobj,o.colorbar_label,'fontsize',12,'fontweight','bold');
        end
        tickamount=min([colormap_steps 8])+1; % depends on the amount of colormap steps
        coloobj.Ticks=linspace(0,colormap_steps,tickamount);
        ticklabels=linspace(minscale_adjusted,maxscale_adjusted,tickamount);
        if o.colorbar_format == 2
            ticklabels_string=num2str(ticklabels(:),'%0.3e');
        elseif o.colorbar_format == 3
            ticklabels_string=num2str(ticklabels(:),'%0.3f');
        else
            ticklabels_string=num2str(ticklabels(:),'%0.3g');
        end
        coloobj.TickLabels =ticklabels_string;
    end
end
%% plot masks in preview mode (not in edit mode)
if render_mask
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
    hold(target_axis,'on');
    alphamapmask=converted_mask(1:skip_mask_pixels:end,1:skip_mask_pixels:end)*(1-(o.masktransp/100));
    alphamapmask(alphamapmask>1)=1;
    alphamapmask(alphamapmask<0)=0;
    %temporary workaround for bug in R2025 causing slow performance when not using alphadatamapping=scaled
    alphamapmask(1,1)=0;
    alphamapmask(end,end)=1;
    image(x,y,cat(3, converted_mask(1:skip_mask_pixels:end,1:skip_mask_pixels:end)*0.7, converted_mask(1:skip_mask_pixels:end,1:skip_mask_pixels:end)*0.1, converted_mask(1:skip_mask_pixels:end,1:skip_mask_pixels:end)*0.1), 'parent',target_axis, 'cdatamapping', 'direct','AlphaData',alphamapmask,'AlphaDataMapping','scaled');
    hold(target_axis,'off');
end
end
