function [currentimage,rawimage] = get_img(selected)
handles=gui.gethand;
filepath = gui.retr('filepath');
framenum = gui.retr ('framenum');
framepart = gui.retr ('framepart');
if gui.retr('video_selection_done') == 0
    [~,~,ext] = fileparts(filepath{selected});
    if strcmp(ext,'.b16')
        currentimage=import.f_readB16(filepath{selected});
        rawimage=currentimage;
    else
        %currentimage=imread(filepath{selected},framenum(selected));
        currentimage=import.imread_wrapper(filepath{selected},framenum(selected),framepart(selected,:));
        if size(currentimage,3)>3
            currentimage=currentimage(:,:,1:3); %Chronos prototype has 4channels (all identical...?)
        end
        rawimage=currentimage;
    end
else
    video_reader_object = gui.retr('video_reader_object');
    video_frame_selection=gui.retr('video_frame_selection');
    currentimage = read(video_reader_object,video_frame_selection(selected));
    rawimage=currentimage;
end

if get(handles.bg_subtract,'Value')>1
    if mod(selected,2)==1 %uneven image nr.
        bg_img = gui.retr('bg_img_A');
    else
        bg_img = gui.retr('bg_img_B');
    end

    if isempty(bg_img) %checkbox is enabled, but no bg is present
        set(handles.bg_subtract,'Value',1);
    else
        if size(currentimage,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
            currentimage = rgb2gray(currentimage)-bg_img;
        else
            currentimage = currentimage-bg_img;
        end
    end
end
%get and save the image size (assuming that every image of a session has the same size)
size_of_the_image=size(currentimage(:,:,1));
expected_image_size=gui.retr('expected_image_size');

if isempty(gui.retr('size_warning_has_been_shown'))
    gui.put('size_warning_has_been_shown',0);
end
if isempty(expected_image_size) %expected_image_size is empty, we have not read an image before
    expected_image_size = size_of_the_image;
    gui.put('expected_image_size',expected_image_size);
else %expected_image_size is not empty, an image has been read before
    if 	(expected_image_size(1) ~= size_of_the_image(1) || expected_image_size(2) ~= size_of_the_image(2)) && gui.retr('size_warning_has_been_shown') == 0
        piv.cancelbutt_Callback
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: All images in a session MUST have the same size!','modal');
        gui.put('size_warning_has_been_shown',1);
        warning off
        recycle('off');
        delete(fullfile(userpath,'cancel_piv'));
        warning on
    end
end
gui.put('size_of_the_image',size_of_the_image);
currentimage(currentimage<0)=0; %bg subtraction may yield negative