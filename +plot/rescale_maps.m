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
    out(:,:)=mean(in(:)); %Rand wird auf Mittelwert gesetzt
    step=x(1,2)-x(1,1)+1;
    minx=(min(min(x))-step/2);
    maxx=(max(max(x))+step/2);
    miny=(min(min(y))-step/2);
    maxy=(max(max(y))+step/2);
    width=maxx-minx;
    height=maxy-miny;
    if size(in,3)>1 %why would this actually happen...?
    	in(:,:,2:end)=[];
    end
    if isangle == 1 %angle data is unsteady, needs to interpolated differently
    	X_raw=cos(in/180*pi);
    	Y_raw=sin(in/180*pi);
    	%interpolate
    	X_interp = imresize(X_raw,[height width],'bilinear');
    	Y_interp = imresize(Y_raw,[height width],'bilinear');
    	%reconvert to phase
    	dispvar = angle(complex(X_interp,Y_interp))*180/pi;
    else
    	colormap_interpolation_list=get(handles.colormap_interpolation,'String');
    	colormap_interpolation_value = get(handles.colormap_interpolation,'Value');
    	dispvar = imresize(in,[height width],colormap_interpolation_list{colormap_interpolation_value}); %INTERPOLATION
    end

    if miny<1
    	miny=1;
    end
    if minx<1
    	minx=1;
    end
    try
    	out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1))=dispvar;
    catch
    	disp('temp workaround')
    	A=out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1));
    	out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1))=dispvar(1:size(A,1),1:size(A,2));
    end
end

