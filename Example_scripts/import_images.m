function [images, filenames] = import_images(directory, ext)
%IMPORT_IMAGES Summary of this function goes here
%   Detailed explanation goes here
    files = dir(directory + "\*." + ext );
    images = cell([length(files),1]);
    filenames = cell([length(files),1]);
    for indx = 1:length(files)
        file = fullfile(files(indx).folder, files(indx).name);
        filenames{indx} = file;
        images{indx} = imread(file);
    end
end