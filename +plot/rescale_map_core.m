function out = rescale_map_core(in, x, y, imsize, isangle, interp_method, extrapolate_border, roirect)
%RESCALE_MAP_CORE Interpolate a derived map from the vector grid to the image size (no GUI).
%   out = plot.rescale_map_core(in, x, y, imsize, isangle, interp_method, extrapolate_border, roirect)
%   in                 map on the vector grid (same size as x, y)
%   x, y               vector positions in pixels
%   imsize             [height width] of the image
%   isangle            true for angle data (degrees), interpolated via cos / sin
%   interp_method      'bilinear', 'bicubic' or 'nearest'
%   extrapolate_border true: the border outside the vector grid is extrapolated,
%                      false: it is set to the mean of the map
%   roirect            region of interest [x y w h] or [] (limits the extrapolation)
%   Used by plot.rescale_maps (GUI) and pivlab.display.
if imsize(1) == size(in,1) && imsize(2) == size(in,2)
    out=in;
    %images have already the same size (as in wOFV)
    return
end
out=zeros(imsize(1),imsize(2));
if extrapolate_border
    out(:,:)=NaN; %Rand wird inpainted
else
    out(:,:)=mean(in(:)); %Rand wird auf Mittelwert gesetzt
end
step=x(1,2)-x(1,1);
minx=(min(min(x))-step/2);
maxx=(max(max(x))+step/2);
miny=(min(min(y))-step/2);
maxy=(max(max(y))+step/2);
miny_idx=max(1,floor(miny));
minx_idx=max(1,floor(minx));
maxy_idx=min(size(out,1),floor(maxy-1));
maxx_idx=min(size(out,2),floor(maxx-1));
rows=miny_idx:maxy_idx;
cols=minx_idx:maxx_idx;
if size(in,3)>1
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
    dispvar = plot.grid_to_pixels(in,x(1,:),y(:,1),rows,cols,interp_method);
end
out(miny_idx:maxy_idx,minx_idx:maxx_idx)=dispvar;
if extrapolate_border
    interior_nan=false(size(out));
    interior_nan(miny_idx:maxy_idx,minx_idx:maxx_idx)=isnan(dispvar);
    % Limit fill to the ROI (pixels outside ROI are masked and never shown)
    if ~isempty(roirect) && numel(roirect)>=4
        o_r1=max(1,          roirect(2));
        o_r2=min(size(out,1),roirect(2)+roirect(4));
        o_c1=max(1,          roirect(1));
        o_c2=min(size(out,2),roirect(1)+roirect(3));
    else
        o_r1=1; o_r2=size(out,1); o_c1=1; o_c2=size(out,2);
    end
    sub=out(o_r1:o_r2, o_c1:o_c2);
    % the vector grid inside the ROI box (it can reach beyond the box, e.g. a ROI drawn after the
    % analysis: then there is no border strip on that side)
    r_lo=max(1,miny_idx-o_r1+1); r_hi=min(size(sub,1),maxy_idx-o_r1+1);
    c_lo=max(1,minx_idx-o_c1+1); c_hi=min(size(sub,2),maxx_idx-o_c1+1);
    if r_lo<=r_hi && c_lo<=c_hi
        sub=plot.inpaint_border_strips(sub, r_lo, r_hi, c_lo, c_hi);
    end
    out(o_r1:o_r2, o_c1:o_c2)=sub;
    out(interior_nan)=NaN;
end
end
