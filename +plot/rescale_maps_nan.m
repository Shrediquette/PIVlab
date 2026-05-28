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
    target_rows=maxy_idx-miny_idx+1;
    target_cols=maxx_idx-minx_idx+1;
    if size(in,3)>1 %why would this actually happen...?
    	in(:,:,2:end)=[];
    end

    if isangle == 1 %angle data is unsteady, needs to interpolated differently
    	X_raw=cos(in/180*pi);
    	Y_raw=sin(in/180*pi);
    	%interpolate
    	X_interp = imresize(X_raw,[target_rows target_cols],'bilinear');
    	Y_interp = imresize(Y_raw,[target_rows target_cols],'bilinear');
    	%reconvert to phase
    	dispvar = angle(complex(X_interp,Y_interp))*180/pi;
    else
    	dispvar = imresize(in,[target_rows target_cols],'bilinear'); %INTERPOLATION
    end
    out(miny_idx:maxy_idx,minx_idx:maxx_idx)=dispvar;
end
%% remove data from masked areas
current_mask_nr=floor(get(handles.fileselector, 'value'));
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