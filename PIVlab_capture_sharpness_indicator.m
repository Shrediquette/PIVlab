function [sharpness,sharpness_map]=PIVlab_capture_sharpness_indicator (input_image,textx,texty)
skip=3;
diff_image=abs(diff(input_image(1:skip:end,1:skip:end))); %process only every 3rd pixel.... still works?
sharpness=std2(single(diff_image));
sharpness=sharpness/mean(input_image(:))*10000;
delete(findobj('tag','sharpness_display_text'));
if ~isempty(textx) && ~isempty(texty)
	text(textx,texty,['Sharpness: ' int2str(sharpness)],'Color',[1 1 0],'tag','sharpness_display_text','Horizontalalignment','right');
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