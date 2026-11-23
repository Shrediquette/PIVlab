function img = read_raw_frame(src, selected, cam)
%READ_RAW_FRAME Read one frame of a PIVlab frame list as stored (before undistortion and background).
%   img = import.read_raw_frame(src, selected)
%   img = import.read_raw_frame(src, selected, cam)
%   src, selected and cam as in import.read_frame. Two cameras combined (cam.fov set): img is
%   {frame of camera 1 (src), frame of camera 2 (cam.fov.src)}.
%   Used by import.read_frame and import.read_frame_display.
if nargin > 2 && fov.is_combined(cam)
    img = {read_one(src, selected), read_one(cam.fov.src, selected)};
else
    img = read_one(src, selected);
end
end

function img = read_one(src, selected)
if isfield(src,'video_reader_object') && ~isempty(src.video_reader_object)
    img = read(src.video_reader_object,src.video_frame_selection(selected));
else
    filepath = src.filepath;
    [~,~,ext] = fileparts(filepath{selected});
    if strcmp(ext,'.b16')
        img=import.f_readB16(filepath{selected});
    else
        img=import.imread_wrapper(filepath{selected},src.framenum(selected),src.framepart(selected,:));
        if size(img,3)>3
            img=img(:,:,1:3); %Chronos prototype has 4channels (all identical...?)
        end
    end
end
end
