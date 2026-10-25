function [sharpness,sharpness_map]=PIVlab_capture_sharpness_indicator (input_image,showinfo,x_offset)
%x_offset (optional, stereo acquisition): the image starts at x = x_offset+1 in the PIVlab axis (camera 2 right of
%camera 1). With x_offset, the old texts are not deleted here (the caller deletes them once for both cameras).
if nargin < 3
	x_offset = [];
end
textx=size(input_image,2)/20*19;
texty=size(input_image,1)/20*19;
fontsize = 32;
if ~isempty(x_offset)
	textx = textx + x_offset;
	fontsize = 16; %two images share the display
end
skip=3;
diff_image=abs(diff(input_image(1:skip:end,1:skip:end))); %process only every 3rd pixel.... still works?
sharpness=std2(single(diff_image));
mean_brightess = mean(input_image(:));
sharpness=sharpness/mean_brightess*10000;

if isempty(x_offset)
	delete(findobj('tag','sharpness_display_text'));
end
if showinfo
	hgui=getappdata(0,'hgui');
	PIVlab_axis = gui.retr('pivlab_axis');
	text(textx,texty,{['Sharpness: ' int2str(sharpness)] ['Mean brightness: ' int2str(mean_brightess)]},'Color',[1 1 0] ,'tag','sharpness_display_text','Verticalalignment','bottom','Horizontalalignment','right','Parent',PIVlab_axis,'FontSize',fontsize,'fontweight','bold');
end

sharpness_map=[];
%{
fun = @(block_struct) std2(block_struct.data) * ones(size(block_struct.data));
blocksize_r=round(size(diff_image,1)/9);
blocksize_c=round(size(diff_image,2)/9);
sharpness_map = blockproc(diff_image,[blocksize_r blocksize_c],fun);
sharpness_map = rescale(sharpness_map);
sharpness_map=imresize(sharpness_map,size(input_image),'nearest');
%}