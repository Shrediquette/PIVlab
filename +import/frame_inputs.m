function [src, cam, bg] = frame_inputs(selected)
%FRAME_INPUTS Frame list, camera settings and background images of the PIVlab window for one frame.
%   [src, cam, bg] = import.frame_inputs(selected)
%   The inputs of import.read_frame as the GUI has them. Shared by import.get_img (full resolution)
%   and import.read_frame_display (display resolution), so both read the same frame in the same way.
%   When background subtraction is switched on but there is no background image, it is switched off
%   (as before in import.get_img).
handles=gui.gethand;
src.filepath = gui.retr('filepath');
src.framenum = gui.retr ('framenum');
src.framepart = gui.retr ('framepart');
if gui.retr('video_selection_done') == 0
    src.video_reader_object = [];
else
    src.video_reader_object = gui.retr('video_reader_object');
    src.video_frame_selection = gui.retr('video_frame_selection');
end
cam = import.cam_settings(FromGUI=true);
bg = [];
if get(handles.bg_subtract,'Value')>1
    if mod(selected,2)==1 %uneven image nr.
        bg_img = gui.retr('bg_img_A');
    else
        bg_img = gui.retr('bg_img_B');
    end
    if isempty(bg_img) %checkbox is enabled, but no bg is present
        set(handles.bg_subtract,'Value',1);
    else
        bg = struct('A',gui.retr('bg_img_A'),'B',gui.retr('bg_img_B'));
    end
end
end
