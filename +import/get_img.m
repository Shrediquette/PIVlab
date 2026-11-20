function [currentimage,rawimage] = get_img(selected, raw_in)
%raw_in (optional): the frame as import.read_raw_frame returns it, when the caller has read it
%already (plot.draw_pixel_background_overlay)
if nargin < 2
    raw_in = [];
end
[src, cam, bg] = import.frame_inputs(selected);
% reading, undistortion and background subtraction are shared with the command-line API
[currentimage,rawimage] = import.read_frame(src, selected, cam, bg, raw_in);
import.note_image_size(size(currentimage(:,:,1)));
currentimage(currentimage<0)=0; %bg subtraction may yield negative
