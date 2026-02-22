function [sharpness,sharpness_map]=PIVlab_capture_sharpness_indicator (input_image,showinfo)
textx=size(input_image,2)/20*19;
texty=size(input_image,1)/20*19;
skip=3;
diff_image=abs(diff(input_image(1:skip:end,1:skip:end))); %process only every 3rd pixel.... still works?
sharpness=std2(single(diff_image));
mean_brightess = mean(input_image(:));
sharpness=sharpness/mean_brightess*10000;

delete(findobj('tag','sharpness_display_text'));
if showinfo
	hgui=getappdata(0,'hgui');
	PIVlab_axis = findobj(hgui,'Type','Axes');
	text(textx,texty,{['Sharpness: ' int2str(sharpness)] ['Mean brightness: ' int2str(mean_brightess)]},'Color',[1 1 0] ,'tag','sharpness_display_text','Verticalalignment','bottom','Horizontalalignment','right','Parent',PIVlab_axis,'FontSize',32,'fontweight','bold');
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