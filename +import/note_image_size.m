function note_image_size(size_of_the_image)
%NOTE_IMAGE_SIZE Store the size of the frame that was read (after undistortion), as gui 'size_of_the_image'.
%   import.note_image_size([height width])
%   Called for every frame the PIVlab window reads: import.get_img (full resolution) and
%   plot.draw_pixel_background_overlay (display resolution, with the full resolution size). The
%   calibration uses this size (calibrate.apply_xy, flipped axes).
expected_image_size=gui.retr('expected_image_size');
if isempty(gui.retr('size_warning_has_been_shown'))
    gui.put('size_warning_has_been_shown',0);
end
if ~isempty(expected_image_size) %an image has been read before
    if 	(expected_image_size(1) ~= size_of_the_image(1) || expected_image_size(2) ~= size_of_the_image(2)) && gui.retr('size_warning_has_been_shown') == 0
        disp('Info: Image size has changed.');
    end
end
gui.put('size_of_the_image',size_of_the_image);
end
