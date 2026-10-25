function folders = capture_folders(projectpath, n)
%CAPTURE_FOLDERS Folders for the recorded images of n cameras.
%   One camera: the project folder. Stereo (n = 2): its subfolders cam1 and cam2; the images in them have the
%   same names as in 2D (PIVlab_0000_A.tif, ...).
if n == 1
    folders = {projectpath};
else
    folders = cell(1, n);
    for k = 1:n
        folders{k} = fullfile(projectpath, sprintf('cam%d', k));
    end
end
end
