function [currentimage, rawimage] = read_frame(src, selected, cam, bg)
%READ_FRAME Read one frame of a PIVlab frame list (no GUI needed).
%   [currentimage, rawimage] = import.read_frame(src, selected, cam, bg)
%
%   src       struct with fields
%               filepath, framenum, framepart  (see import.build_file_list)
%               video_reader_object, video_frame_selection  (only for videos, else empty)
%   selected  frame index (odd = A frame, even = B frame)
%   cam       camera undistortion struct (see import.cam_settings), or [] for none
%   bg        background subtraction struct with fields A and B (background images),
%             or [] for no background subtraction
%
%   currentimage  image after undistortion and background subtraction (negative values clipped)
%   rawimage      image after undistortion, before background subtraction
%
%   Stereo-PIV (cam.stereo_map set): the background images are raw camera images, so the
%   background is subtracted BEFORE the stereo transform (reflections are fixed to the camera,
%   and the background stays valid when the disparity correction changes).
%
%   Used by import.get_img (GUI), the parallel PIV loops and the pivlab.* API.

if isempty(cam)
    cam = import.cam_settings();
end
if isfield(src,'video_reader_object') && ~isempty(src.video_reader_object)
    currentimage = read(src.video_reader_object,src.video_frame_selection(selected));
else
    filepath = src.filepath;
    [~,~,ext] = fileparts(filepath{selected});
    if strcmp(ext,'.b16')
        currentimage=import.f_readB16(filepath{selected});
    else
        currentimage=import.imread_wrapper(filepath{selected},src.framenum(selected),src.framepart(selected,:));
        if size(currentimage,3)>3
            currentimage=currentimage(:,:,1:3); %Chronos prototype has 4channels (all identical...?)
        end
    end
end
bg_img = [];
if ~isempty(bg)
    if mod(selected,2)==1 %uneven image nr.
        bg_img = bg.A;
    else
        bg_img = bg.B;
    end
end
if isfield(cam,'stereo_map') && ~isempty(cam.stereo_map)
    % stereo-PIV: background subtraction on the raw camera image, then the stereo transform
    raw = currentimage;
    if ~isempty(bg_img)
        if size(currentimage,3)>1
            currentimage = rgb2gray(currentimage);
        end
        currentimage = currentimage-bg_img;
        currentimage(currentimage<0)=0;
    end
    currentimage = undistort(currentimage, cam);
    if nargout > 1
        if isempty(bg_img)
            rawimage = currentimage;
        else
            rawimage = undistort(raw, cam);
        end
    end
else
    currentimage = undistort(currentimage, cam);
    rawimage=currentimage;
    if ~isempty(bg_img)
        if size(currentimage,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
            currentimage = rgb2gray(currentimage)-bg_img;
        else
            currentimage = currentimage-bg_img;
        end
    end
end
currentimage(currentimage<0)=0; %bg subtraction may yield negative
end

function img = undistort(img, cam)
img = preproc.cam_undistort_with(img, cam);
end
