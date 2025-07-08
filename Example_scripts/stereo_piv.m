%[text] ## **Stereo PIV processing (PIVlab issue** 139)
%[text] This script is designed to develop and test code required to introduce stereo PIV processing capabilities into PIVlab.
%%
%[text] ### Import Data
%[text] First we need data. The data used herehas been provided by William Thieke.
data_dir = "..\..\data_from_william\stereo\" %[output:480d6693]
cameras = ["camera_1", "camera_2"];
%[text] We start by importing the calibration data. The calibration target consists of a 7x10 Charuco grid pattern .
image_data = struct();
ext = "bmp";
for camera = cameras
    directory = data_dir + camera + "_calibration_imgs";
    [images, file_names] = import_images(directory, ext);
    image_data.calibration.(camera).images = images;
    image_data.calibration.(camera).files = file_names;
    directory = data_dir + "PIV_imgs_move_closer/" + camera;
    [images, file_names] = import_images(directory, ext);
    image_data.test1.(camera).images = images;
    image_data.test1.(camera).files = file_names;
    directory = data_dir + "PIV_imgs_move_up/" + camera;
    [images, file_names] = import_images(directory, ext);
    image_data.test2.(camera).images = images;
    image_data.test2.(camera).files = file_names;
end
%[text] We can also import the test data
%%
%[text] ### Camera corrections
%[text] To correct for camera based image distortion we use calibration images of a charuco pattern calibration target to obtain an estimate of the camera parameters:
pattern_type = "charuco-board";
pattern_dims = [7 10];
pattern_name = "DICT_5X5_100";
checker_size = 100;
marker_size = 75;
image_size = [1200 1920];

worldPoints = patternWorldPoints(pattern_type, pattern_dims, checker_size * 3);

parameters = struct();
for camera = cameras
    imagePoints = detectCharucoBoardPoints(image_data.calibration.(camera).files, pattern_dims, pattern_name,checker_size, marker_size);
    parameters.(camera) = estimateCameraParameters(imagePoints, worldPoints, ImageSize=image_size);
end
%[text] We can also use estimateCameraParameters in stereo to provide data about the relative location of the cameras:
stereo_image_points = detectCharucoBoardPoints(image_data.calibration.camera_1.files, image_data.calibration.camera_2.files,pattern_dims, pattern_name,checker_size, marker_size);
stereo_parameters = estimateCameraParameters(stereo_image_points, worldPoints, ImageSize=image_size);
%%
%[text] 
%[text] We can use the camera paramters to correct the images in the dataset.
datasets = fieldnames(image_data);
for indx = 1:length(datasets)
    for camera = cameras
        images = image_data.(datasets{indx}).(camera).images;
        for jndx = 1:length(images)
            images{jndx} = undistortImage(images{jndx}, parameters.(camera));
        end
        image_data.(datasets{indx}).(camera).images = images;
    end   
end
%%
%[text] The triangulate object can then be used to triangulate common points (e.g. the charuco grid)
worldPoints = triangulate(stereo_image_points(:,:,1,1), stereo_image_points(:,:,1,2), stereo_parameters) %[output:7bb07d63]
%[text] 
%%


%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":32.6}
%---
%[output:480d6693]
%   data: {"dataType":"textualVariable","outputData":{"name":"data_dir","value":"\"..\\..\\data_from_william\\stereo\\\""}}
%---
%[output:7bb07d63]
%   data: {"dataType":"matrix","outputData":{"columns":3,"exponent":"3","name":"worldPoints","rows":54,"type":"double","value":[["0.6618","0.3269","4.9090"],["0.6622","0.2269","4.9126"],["0.6627","0.1276","4.9163"],["0.6630","0.0274","4.9201"],["0.6631","-0.0720","4.9240"],["0.6634","-0.1720","4.9276"],["0.5870","0.3242","4.8431"],["0.5875","0.2242","4.8470"],["0.5878","0.1248","4.8507"],["0.5883","0.0247","4.8546"],["0.5886","-0.0749","4.8584"],["0.5887","-0.1749","4.8621"],["0.5120","0.3216","4.7775"],["0.5124","0.2215","4.7810"],["0.5127","0.1221","4.7848"]]}}
%---
