function [sharpness,sharpness_map]=PIVlab_capture_sharpness_indicator (input_image,textx,texty)
skip=3;
input_image=single(input_image);
diff_image=abs(diff(input_image(1:skip:end,1:skip:end))); %process only every 3rd pixel.... still works?
half_width=round(size(diff_image,2)/2);
half_height=round(size(diff_image,1)/2);


sharpness1=std2(diff_image(1:half_height,1:half_width)); %top left
sharpness2=std2(diff_image(1:half_height,half_width:end)); %top right
sharpness3=std2(diff_image(half_height:end,1:half_width)); %bottom left
sharpness4=std2(diff_image(half_height:end,half_width:end));%bottom right
sharpness=(sharpness1+sharpness2+sharpness3+sharpness4)/4;

mean_brightess = mean(input_image(:));
sharpness=sharpness/mean_brightess*10000;

delete(findobj('tag','sharpness_display_text'));
if ~isempty(textx) && ~isempty(texty)
	hgui=getappdata(0,'hgui');
	PIVlab_axis = findobj(hgui,'Type','Axes');
	text(10,10,['Sharpness: ' int2str(sharpness1)],'Color',[1 1 0] ,'tag','sharpness_display_text','Verticalalignment','top','Horizontalalignment','left','Parent',PIVlab_axis,'FontSize',32,'fontweight','bold');
	text(round(size(input_image,2)/2)-10,10,['Sharpness: ' int2str(sharpness2)],'Color',[1 1 0] ,'tag','sharpness_display_text','Verticalalignment','top','Horizontalalignment','right','Parent',PIVlab_axis,'FontSize',32,'fontweight','bold');

	%text(textx,texty,{['Sharpness: ' int2str(sharpness)] ['Mean brightness: ' int2str(mean_brightess)]},'Color',[1 1 0] ,'tag','sharpness_display_text','Verticalalignment','bottom','Horizontalalignment','right','Parent',PIVlab_axis,'FontSize',32,'fontweight','bold');
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