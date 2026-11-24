function out=rescale_maps_nan(in,isangle,desired_frame) %if desiredframe is empty, then  get current frame
%input has same dimensions as x,y,u,v,
%output has size of the piv image
%Rand ist nan statt Mittelwert des derivatives
handles=gui.gethand;
filepath=gui.retr('filepath');
if isempty(desired_frame)
    currentframe=floor(get(handles.fileselector, 'value'));
else
    currentframe=desired_frame;
end
expected_image_size=gui.retr('expected_image_size');
if ~isempty(expected_image_size)
    img_h=expected_image_size(1);
    img_w=expected_image_size(2);
else
    [currentimage,~]=import.get_img(2*currentframe-1);
    img_h=size(currentimage,1);
    img_w=size(currentimage,2);
end
if size(in,1)==img_h && size(in,2)==img_w
    out=in;
    %images have already the same size (as in wOFV)
else
    resultslist=gui.retr('resultslist');
    x=resultslist{1,currentframe};
    y=resultslist{2,currentframe};
    out=nan(img_h,img_w);
    step=x(1,2)-x(1,1);
    minx=(min(min(x))-step/2);
    maxx=(max(max(x))+step/2);
    miny=(min(min(y))-step/2);
    maxy=(max(max(y))+step/2);
    miny_idx=max(1,floor(miny));
    minx_idx=max(1,floor(minx));
    maxy_idx=min(img_h,floor(maxy-1));
    maxx_idx=min(img_w,floor(maxx-1));
    rows=miny_idx:maxy_idx;
    cols=minx_idx:maxx_idx;
    if size(in,3)>1 %why would this actually happen...?
    	in(:,:,2:end)=[];
    end
    %interpolation at the true pixel positions (kernels of imresize, see plot.grid_to_pixels)
    if isangle == 1 %angle data is unsteady, needs to interpolated differently
    	X_raw=cos(in/180*pi);
    	Y_raw=sin(in/180*pi);
    	%interpolate
    	X_interp = plot.grid_to_pixels(X_raw,x(1,:),y(:,1),rows,cols,'bilinear');
    	Y_interp = plot.grid_to_pixels(Y_raw,x(1,:),y(:,1),rows,cols,'bilinear');
    	%reconvert to phase
    	dispvar = angle(complex(X_interp,Y_interp))*180/pi;
    else
    	dispvar = plot.grid_to_pixels(in,x(1,:),y(:,1),rows,cols,'bilinear'); %INTERPOLATION
    end
    out(miny_idx:maxy_idx,minx_idx:maxx_idx)=dispvar;
end
%% remove data from masked areas
current_mask_nr=currentframe; %mask of the frame of this map (not of the displayed frame)
masks_in_frame=gui.retr('masks_in_frame');
if isempty(masks_in_frame)
    %masks_in_frame=cell(current_mask_nr,1);
    masks_in_frame=cell(1,current_mask_nr);
end

if numel(masks_in_frame)<current_mask_nr
    mask_positions=cell(0);
else
    mask_positions=masks_in_frame{current_mask_nr};
end
converted_mask=mask.convert_masks_to_binary([img_h,img_w],mask_positions);
out(converted_mask==1)=nan;