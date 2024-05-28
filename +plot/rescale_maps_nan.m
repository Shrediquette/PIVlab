function out=rescale_maps_nan(in,isangle,desired_frame) %if desiredframe is empty, then  get current frame
%input has same dimensions as x,y,u,v,
%output has size of the piv image
%Rand ist nan statt Mittelwert des derivatives
handles=gui.gui_gethand;
filepath=gui.gui_retr('filepath');
if isempty(desired_frame)
	currentframe=floor(get(handles.fileselector, 'value'));
else
	currentframe=desired_frame;
end
[currentimage,~]=import.import_get_img(2*currentframe-1);
resultslist=gui.gui_retr('resultslist');
x=resultslist{1,currentframe};
y=resultslist{2,currentframe};
out=zeros(size(currentimage));
if size(out,3)>1
	out(:,:,2:end)=[];
end
out(:,:)=nan; %rand wird auf nan gesetzt
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
	dispvar = imresize(in,[height width],'bilinear'); %INTERPOLATION
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
%% remove data from masked areas
current_mask_nr=floor(get(handles.fileselector, 'value'));
masks_in_frame=gui.gui_retr('masks_in_frame');
if isempty(masks_in_frame)
	%masks_in_frame=cell(current_mask_nr,1);
	masks_in_frame=cell(1,current_mask_nr);
end
if numel(masks_in_frame)<current_mask_nr
	mask_positions=cell(0);
else
	mask_positions=masks_in_frame{current_mask_nr};
end
expected_image_size=gui.gui_retr('expected_image_size');
converted_mask=mask.mask_convert_masks_to_binary(expected_image_size,mask_positions);
out(converted_mask==1)=nan;

