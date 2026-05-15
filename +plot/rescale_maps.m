function out=rescale_maps(in,isangle)
%input has same dimensions as x,y,u,v,
%output has size of the piv image
handles=gui.gethand;
filepath=gui.retr('filepath');
currentframe=floor(get(handles.fileselector, 'value'));
[currentimage,~]=import.get_img(2*currentframe-1);
if size(currentimage,1) == size(in,1) && size(currentimage,2) == size(in,2)
    out=in;
    %images have already the same size (as in wOFV)
else
    resultslist=gui.retr('resultslist');
    x=resultslist{1,currentframe};
    y=resultslist{2,currentframe};
    out=zeros(size(currentimage));
    if size(out,3)>1
    	out(:,:,2:end)=[];
    end
    extrapolate_border=get(handles.extrapolate_border,'value');
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
    	colormap_interpolation_list=get(handles.colormap_interpolation,'String');
    	colormap_interpolation_value = get(handles.colormap_interpolation,'Value');
    	dispvar = imresize(in,[target_rows target_cols],colormap_interpolation_list{colormap_interpolation_value}); %INTERPOLATION
    end
    out(miny_idx:maxy_idx,minx_idx:maxx_idx)=dispvar;
    if extrapolate_border
        interior_nan=false(size(out));
        interior_nan(miny_idx:maxy_idx,minx_idx:maxx_idx)=isnan(dispvar);
        % Limit fill to the ROI (pixels outside ROI are masked and never shown)
        roirect=gui.retr('roirect');
        if ~isempty(roirect) && numel(roirect)>=4
            o_r1=max(1,          roirect(2));
            o_r2=min(size(out,1),roirect(2)+roirect(4));
            o_c1=max(1,          roirect(1));
            o_c2=min(size(out,2),roirect(1)+roirect(3));
        else
            o_r1=1; o_r2=size(out,1); o_c1=1; o_c2=size(out,2);
        end
        sub=out(o_r1:o_r2, o_c1:o_c2);
        sub=plot.inpaint_border_strips(sub, ...
            miny_idx-o_r1+1, maxy_idx-o_r1+1, ...
            minx_idx-o_c1+1, maxx_idx-o_c1+1);
        out(o_r1:o_r2, o_c1:o_c2)=sub;
        out(interior_nan)=NaN;
    end
end

