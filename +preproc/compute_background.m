function [bg_img_A, bg_img_B, msg] = compute_background(src, sequencer, bg_operation, cam, progressFcn)
%COMPUTE_BACKGROUND Mean or minimum intensity background images of an image series (no GUI needed).
%   [bg_img_A, bg_img_B, msg] = preproc.compute_background(src, sequencer, bg_operation, cam, progressFcn)
%
%   src           frame list struct: filepath, framenum, framepart (see import.build_file_list),
%                 for videos also video_reader_object and video_frame_selection
%   sequencer     0 = time resolved (one background from all images), 1 = pairwise
%                 (separate backgrounds for A and B frames)
%   bg_operation  2 = mean intensity, 3 = minimum intensity
%   cam           camera undistortion settings (import.cam_settings), [] for none
%   progressFcn   optional function handle, called with the progress in percent
%
%   bg_img_A, bg_img_B  background images (same class as the input images). For time resolved
%                       sequencing both are identical.
%   msg                 empty, or an error message if the images have different sizes
%                       (the background is then computed from the images up to that point)
%
%   Used by preproc.generate_BG_img (GUI) and pivlab.preprocess.
if nargin < 4 || isempty(cam)
    cam = import.cam_settings();
end
if nargin < 5
    progressFcn = [];
end
msg = '';
filepath = src.filepath;
framenum = src.framenum;
framepart = src.framepart;
from_video = isfield(src,'video_reader_object') && ~isempty(src.video_reader_object);
if from_video
    video_reader_object = src.video_reader_object;
    video_frame_selection = src.video_frame_selection;
    image1 = read(video_reader_object,video_frame_selection(1));
    image2 = read(video_reader_object,video_frame_selection(2));
    imagesource='from_video';
else
    [~,~,ext] = fileparts(filepath{1});
    if strcmp(ext,'.b16')
        image1=import.f_readB16(filepath{1});
        image2=import.f_readB16(filepath{2});
        imagesource='b16_image';
    else
        image1=import.imread_wrapper(filepath{1},framenum(1),framepart(1,:));
        image2=import.imread_wrapper(filepath{2},framenum(2),framepart(2,:));
        imagesource='normal_pixel_image';
    end
end
classimage=class(image1); %memorize the original image format (double, uint8 etc)

if size(image1,3)>1
    if size(image1,3)>3
        image1=image1(:,:,1:3); %Chronos prototype has 4channels (all identical...?)
        image2=image2(:,:,1:3); %Chronos prototype has 4channels (all identical...?)
    end
    image1=rgb2gray(image1); %rgb2gray conserves the variable class (single, double, uint8, uint16)
    image2=rgb2gray(image2);
    colorimg=1;
else
    colorimg=0;
end
counter=1;
image1=double(image1);
image2=double(image2);

if sequencer==0 %time-resolved
    start_bg=2;
    skip_bg=1;
else
    start_bg=3;
    skip_bg=2;
end
%perform image addition
%if timeresolved: generate only one background image from all images
%if not: generate two background images. One from even frames, one from odd frames
updatecntr=0;
for i=start_bg:skip_bg:size(filepath,1)
    counter=counter+1; %counts the amount of images
    %% update progress bar
    updatecntr=updatecntr+1;
    if updatecntr==5
        if ~isempty(progressFcn)
            progressFcn(round(i/size(filepath,1)*100));
        end
        updatecntr=0;
    end
    %% read image 1 and 2, different functions for different image types
    if strcmp('b16_image',imagesource)
        image_to_add1 = import.f_readB16(filepath{i}); %will be double
        if sequencer==1 %not time-resolved
            image_to_add2 = import.f_readB16(filepath{i+1});
        end
    elseif strcmp('normal_pixel_image',imagesource)
        image_to_add1 = import.imread_wrapper(filepath{i},framenum(i),framepart(i,:));
        if sequencer==1 %not time-resolved
            image_to_add2 = import.imread_wrapper(filepath{i+1},framenum(i+1),framepart(i+1,:)); %will be double or uint8
        end
    elseif strcmp('from_video',imagesource)
        image_to_add1 = read(video_reader_object,video_frame_selection(i));
        if sequencer==1 %not time-resolved
            image_to_add2 = read(video_reader_object,video_frame_selection(i+1));
        end
    end

    %% convert images to a grayscale double
    if colorimg==1
        if size(image_to_add1,3)>3
            image_to_add1=image_to_add1(:,:,1:3); %Chronos prototype has 4channels (all identical...?)
            if sequencer==1
                image_to_add2=image_to_add2(:,:,1:3); %Chronos prototype has 4channels (all identical...?)
            end
        end
        image_to_add1 = rgb2gray(image_to_add1); %will conserve image class
        if sequencer==1 %not time-resolved
            image_to_add2 = rgb2gray(image_to_add2);
        end
    end

    image_to_add1=double(image_to_add1);
    if sequencer==1 %not time-resolved
        image_to_add2=double(image_to_add2);
    end

    %% check if image size matches other images
    img_size_info1=size(image1);
    img_size_info2=size(image_to_add1);
    if img_size_info1(1) ~= img_size_info2(1) || img_size_info1(2) ~= img_size_info2(2)
        msg = 'Error: All images in a session MUST have the same size!';
        break
    end

    %% sum images
    if bg_operation==2
        image1=image1 +image_to_add1;
    end
    if bg_operation==3
        image1 = min(image1, image_to_add1);
    end

    if sequencer==1 %not time-resolved
        img_size_info1=size(image2);
        img_size_info2=size(image_to_add2);
        if img_size_info1(1) ~= img_size_info2(1) || img_size_info1(2) ~= img_size_info2(2)
            msg = 'Error: All images in a session MUST have the same size!';
            break
        end
        if bg_operation==2
            image2=image2+image_to_add2;
        end
        if bg_operation==3
            image2 = min(image2, image_to_add2);
        end
    end
end %of for loop and image summing

%divide the sum by the amount of summed images
if bg_operation==2
    image1_bg=image1/counter;
    if sequencer==1 %not time-resolved
        image2_bg=image2/counter;
    end
end
if bg_operation==3
    image1_bg=image1;
    if sequencer==1 %not time-resolved
        image2_bg=image2;
    end
end

%Convert back to original image class, if not double anyway
if strcmp(classimage,'uint8')==1 %#ok<*STISA>
    image1_bg=uint8(image1_bg);
    if sequencer==1 %not time-resolved
        image2_bg=uint8(image2_bg);
    end
end
if strcmp(classimage,'single')==1
    image1_bg=single(image1_bg);
    if sequencer==1 %not time-resolved
        image2_bg=single(image2_bg);
    end
end
if strcmp(classimage,'uint16')==1
    image1_bg=uint16(image1_bg);
    if sequencer==1 %not time-resolved
        image2_bg=uint16(image2_bg);
    end
end

image1_bg = preproc.cam_undistort_with(image1_bg, cam);
if sequencer==1 %not time-resolved
    image2_bg = preproc.cam_undistort_with(image2_bg, cam);
end
bg_img_A = image1_bg;
if sequencer==1 %not time-resolved
    bg_img_B = image2_bg;
else
    bg_img_B = image1_bg; %timeresolved --> same bg image for a and b
end
end
