function [currentimage,rawimage] = get_img(selected)
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
% reading, undistortion and background subtraction are shared with the command-line API
[currentimage,rawimage] = import.read_frame(src, selected, cam, bg);


%get and save the image size (assuming that every image of a session has the same size)
size_of_the_image=size(currentimage(:,:,1));
expected_image_size=gui.retr('expected_image_size');

if isempty(gui.retr('size_warning_has_been_shown'))
    gui.put('size_warning_has_been_shown',0);
end
%--> how does this warning help? I think I can skip it
%%{
if isempty(expected_image_size) %expected_image_size is empty, we have not read an image before
%    expected_image_size = size_of_the_image;
%    gui.put('expected_image_size',expected_image_size);
else %expected_image_size is not empty, an image has been read before
    if 	(expected_image_size(1) ~= size_of_the_image(1) || expected_image_size(2) ~= size_of_the_image(2)) && gui.retr('size_warning_has_been_shown') == 0
        disp('Info: Image size has changed.');
        %piv.cancelbutt_Callback
        %gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: All images in a session MUST have the same size!','modal');
        %gui.put('size_warning_has_been_shown',1);
        %warning off
        %recycle('off');
        %delete(fullfile(userpath,'cancel_piv'));
        %warning on
    end
end
%%}
gui.put('size_of_the_image',size_of_the_image);
currentimage(currentimage<0)=0; %bg subtraction may yield negative