dummy_images = "C:\Users\mat.tolladay\Documents\mathworks\dummy_data";
camera_names = ["camera_1", "camera_2"];
image_names = ["particles", "sand", "smoke"];


charuco_img = imread(dummy_images + filesep + "base_images" + filesep + "ChArUco_7X10_5X5_100_75.png", AutoOrient=true);

trial_data = "sand";

image_set_indx = find(trial_data == image_names);



data_img = imread(dummy_images + filesep + "base_images" + filesep + trial_data + ".jpg", AutoOrient=true);