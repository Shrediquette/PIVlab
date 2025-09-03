dummy_images = "C:\Users\mat.tolladay\Documents\mathworks\dummy_data";
camera_names = ["camera_1", "camera_2"];
image_names = ["particles", "sand", "smoke"];

trial_data = "smoke";
image_set_indx = find(trial_data == image_names) %[output:44d18671]

masks = struct();
masks.particles.camera_1 = [];
masks.particles.camera_2 = [];
masks.sand.camera_1 = [[351 966];[463 2289];[2542 2107];[2521 966]];
masks.sand.camera_2 = [[1107 1057];[1072 2135];[3018 2324]; [3018 1106]];
masks.smoke.camera_1 = [[295 1];[421 1843];[2972 1685];[2972 321]];
masks.smoke.camera_2 = [[825 583]; [862 2047]; [3387 1948]; [3340 583]];

calib_image1 = imread(dummy_images + filesep + "camera_1" + filesep + trial_data + "_calib.jpg", AutoOrient=true);
calib_image2 = imread(dummy_images + filesep + "camera_2" + filesep + trial_data + "_calib.jpg", AutoOrient=true);
test_image1 = imread(dummy_images + filesep + "camera_1" + filesep + trial_data + ".jpg", AutoOrient=true);
test_image2 = imread(dummy_images + filesep + "camera_2" + filesep + trial_data + ".jpg", AutoOrient=true);

calib_image1 = rgb2gray(calib_image1);
calib_image2 = rgb2gray(calib_image2);
test_image1 = rgb2gray(test_image1);
test_image2 = rgb2gray(test_image2);

image_size = min([size(calib_image1, [1,2]); size(calib_image2, [1,2])]);
if size(calib_image1, [1,2]) ~= image_size
    calib_image1 = imresize(calib_image1, image_size);
    test_image1 = imresize(test_image1, image_size);
end
if size(calib_image2, [1,2]) ~= image_size
    calib_image2 = imresize(calib_image2, image_size);
    test_image2 = imresize(test_image2, image_size);
end

pattern_type = "charuco-board";
pattern_dims = [7 10];
pattern_name = "DICT_5X5_100";
checker_size = 100;  % pixels
checker_size_mm = 28.4;  % mm
marker_size = 75;  % pixels
marker_size_mm = 0.75 * checker_size_mm;  % mm

worldPoints = patternWorldPoints(pattern_type, pattern_dims, checker_size_mm);

parameters = struct();

% Camera properties
for camera = camera_names
    calib_files = dummy_images + filesep + camera + filesep + image_names + "_calib.jpg";
    camera_image_size = size(imread(calib_files(1)), [1,2]);
    imagePoints = detectCharucoBoardPoints(calib_files, pattern_dims, pattern_name, checker_size_mm, marker_size_mm);
    parameters.(camera) = estimateCameraParameters(imagePoints, worldPoints, ImageSize=camera_image_size);
end
camProjection1 = cameraProjection(...
    parameters.camera_1.Intrinsics,...
    parameters.camera_1.PatternExtrinsics(find(trial_data == image_names))...
);
camProjection2 = cameraProjection( ...
    parameters.camera_2.Intrinsics,...
    parameters.camera_2.PatternExtrinsics(find(trial_data == image_names))...
);

% Stereoscopic properties
image_points1 = detectCharucoBoardPoints(...
    calib_image1,...
    pattern_dims, pattern_name, checker_size_mm, marker_size_mm,...
    SquarenessTolerance=0.1 ...
);
image_points2 = detectCharucoBoardPoints(...
    calib_image2,...
    pattern_dims, pattern_name, checker_size_mm, marker_size_mm,...
    SquarenessTolerance=0.1 ...
);
stereo_image_points = cat(4, image_points1, image_points2) %[output:1f71ee35]
nan_values = any(isnan(stereo_image_points), [2 4]);
stereo_image_points = stereo_image_points(~nan_values,:,:,:);
[fundamental_matrix, inliers] = estimateFundamentalMatrix(...
    stereo_image_points(:,:,:,1), stereo_image_points(:,:,:,2)...
);

[R, t] = cameraPose(fundamental_matrix, parameters.camera_1, parameters.camera_2, image_points1(~nan_values,:), image_points2(~nan_values,:))

% Feature detection
features = detectMSERFeatures(test_image1, ThresholdDelta=1.0);
[f1, points_obj1] = extractFeatures(test_image1, features);
c1 = features.Location;
features = detectMSERFeatures(test_image2, ThresholdDelta=1.0);
[f2, points_obj2] = extractFeatures(test_image2, features);
c2 = features.Location;

indexPairs = matchFeatures(f1,f2, MatchThreshold=10, MaxRatio=0.5);
length(indexPairs) %[output:3a0363f4]
matchedPoints1 = points_obj1(indexPairs(:,1),:);
matchedPoints2 = points_obj2(indexPairs(:,2),:);

[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
  matchedPoints1,matchedPoints2,Method="RANSAC", ...
  NumTrials=10000,DistanceThreshold=0.1,Confidence=99.99);

inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);

[tform1, tform2] = estimateStereoRectification(fMatrix, ... %[output:group:94cfaa4a] %[output:18ef78e7]
  inlierPoints1.Location,inlierPoints2.Location, size(test_image2)); %[output:group:94cfaa4a] %[output:18ef78e7]

[I1Rect, I2Rect] = rectifyStereoImages(test_image1, test_image2,tform1,tform2);
figure %[output:2d477779]
imshow(stereoAnaglyph(I1Rect,I2Rect)) %[output:2d477779]


% Mask
c1_poly = masks.(trial_data).camera_1;
c1_mask = inpolygon(c1(:,1), c1(:,2), c1_poly(:,1), c1_poly(:,2));
c1 = c1(c1_mask,:);

c2_poly = masks.(trial_data).camera_2;
c2_mask = inpolygon(c2(:,1), c2(:,2), c2_poly(:,1), c2_poly(:,2));
c2 = c2(c2_mask,:);

% Feature matching
[~, smallest_feature_set] = min([size(c1,1), size(c2,1)]);
% pv1 = [c1 ./ size(test_image1), ones(size(c1,1), 1)];
% pv2 = [c2 ./ size(test_image2), ones(size(c2,1), 1)];
pv1 = [c1, ones(size(c1,1), 1)];
pv2 = [c2, ones(size(c2,1), 1)];
pdm = pv2 * fundamental_matrix * pv1';
[v, indx] = min(abs(pdm), [], smallest_feature_set);
is_low = v < 0.0001;
if smallest_feature_set == 1
    c1_isin_c2 = c1(is_low,:);
    c2_isin_c1 = c2(indx(is_low),:);
else
    c1_isin_c2 = c1(indx(is_low),:);
    c2_isin_c1 = c2(is_low,:);
end

f1 = figure(1)
imshow(test_image1)
hold on
scatter(c1(:,1), c1(:,2), [], "green", "filled")
scatter(c1_isin_c2(:,1), c1_isin_c2(:,2), 10, "red", "filled")
hold off

f2 = figure(2)
imshow(test_image2)
hold on
scatter(c2(:,1), c2(:,2), [], "green", "filled")
scatter(c2_isin_c1(:,1), c2_isin_c1(:,2), 10, "red", "filled")
hold off

p = triangulate(c2_isin_c1, c1(is_low,:), camProjection1, camProjection2);
pc = median(p, 1);
[~,~,v] = svd(p - pc)

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":23.1}
%---
%[output:44d18671]
%   data: {"dataType":"textualVariable","outputData":{"name":"image_set_indx","value":"3"}}
%---
%[output:1f71ee35]
%   data: {"dataType":"textualVariable","outputData":{"name":"stereo_image_points","value":"stereo_image_points(:,:,1,1) =\n\n   1.0e+03 *\n\n       NaN       NaN\n    3.0265    1.7059\n    3.0290    1.5321\n       NaN       NaN\n       NaN       NaN\n       NaN       NaN\n       NaN       NaN\n       NaN       NaN\n    2.8662    1.5412\n       NaN       NaN\n       NaN       NaN\n       NaN       NaN\n       NaN       NaN\n       NaN       NaN\n    2.7040    1.5425\n    2.7023    1.3741\n    2.7078    1.1969\n       NaN       NaN\n    2.5413    1.8823\n    2.5367    1.7161\n       NaN       NaN\n       NaN       NaN\n    2.5353    1.2013\n       NaN       NaN\n    2.3718    1.8928\n    2.3658    1.7246\n       NaN       NaN\n       NaN       NaN\n    2.3675    1.1993\n    2.3658    1.0234\n    2.2047    1.8945\n    2.2014    1.7267\n       NaN       NaN\n       NaN       NaN\n    2.1943    1.2033\n    2.1963    1.0212\n    2.0289    1.9056\n    2.0300    1.7274\n       NaN       NaN\n       NaN       NaN\n    2.0205    1.2016\n       NaN       NaN\n    1.8491    1.9164\n    1.8521    1.7387\n    1.8455    1.5630\n    1.8454    1.3832\n    1.8385    1.2045\n       NaN       NaN\n    1.6721    1.9213\n       NaN       NaN\n       NaN       NaN\n    1.6589    1.3868\n    1.6589    1.2027\n    1.6501    1.0172\n\n\nstereo_image_points(:,:,1,2) =\n\n   1.0e+03 *\n\n    2.8066    2.3451\n    2.8039    2.1633\n    2.8013    1.9814\n    2.7986    1.7987\n    2.7963    1.6165\n    2.7948    1.4331\n    2.6204    2.3374\n    2.6171    2.1570\n    2.6139    1.9772\n    2.6106    1.7966\n    2.6079    1.6169\n    2.6060    1.4360\n    2.4394    2.3298\n    2.4360    2.1512\n    2.4321    1.9731\n    2.4289    1.7948\n    2.4259    1.6173\n    2.4237    1.4393\n    2.2611    2.3222\n    2.2577    2.1458\n    2.2543    1.9694\n    2.2508    1.7931\n    2.2480    1.6179\n    2.2453    1.4422\n    2.0881    2.3156\n    2.0847    2.1411\n    2.0811    1.9668\n    2.0782    1.7922\n    2.0756    1.6188\n    2.0730    1.4450\n    1.9191    2.3099\n    1.9157    2.1372\n    1.9126    1.9646\n    1.9099    1.7916\n    1.9076    1.6199\n    1.9051    1.4477\n    1.7524    2.3045\n    1.7490    2.1338\n    1.7459    1.9630\n    1.7441    1.7911\n    1.7411    1.6211\n    1.7385    1.4501\n    1.5888    2.2999\n    1.5851    2.1309\n    1.5824    1.9613\n    1.5810    1.7911\n    1.5771    1.6223\n    1.5741    1.4526\n    1.4289    2.2948\n    1.4259    2.1271\n    1.4230    1.9594\n    1.4202    1.7909\n    1.4164    1.6233\n    1.4128    1.4546\n"}}
%---
%[output:3a0363f4]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"135"}}
%---
%[output:18ef78e7]
%   data: {"dataType":"warning","outputData":{"text":"Warning: An epipole may be located inside of an image. The epipoles are located at [342.7455,668.2491] in I1 and [836.9971,1105.2269] in I2, but the specified imageSize was [3060,4080]. Severe distortion may result if T1 or T2 are used to transform these images. See isEpipoleInImage for more information."}}
%---
%[output:2d477779]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAp4AAAAwCAYAAAC4\/3okAAAAAXNSR0IArs4c6QAABNJJREFUeF7t3VtuEzEUBuBTaNWHPiBlHVyXgUBcFsJFsDv2NQ8joKCDcip3uAgBcYz7RaoaTTxj+7Mj\/XLGyclut\/sSHgQIECBAgAABAgQOLHAieB5Y2OUJECBAgAABAgS+CQieJgIBAgQIECBAgEAXAcGzC7NKCBAgQIAAAQIEBE9zgAABAgQIECBAoIuA4NmFWSUECBAgQIAAAQKCpzlAgAABAgQIECDQRUDw7MKsEgIECBAgQIAAAcHTHCBAgAABAgQIEOgiIHh2YVYJAQIECBAgQICA4GkOECBAgAABAgQIdBEQPLswq4QAAQIECBAgQEDwNAcIECBAgAABAgS6CBw9eN65vIz76xqX+fudEfGl6fatiGvH29fzeT6qfL1Wx3+l15bZXqfO+9CFXyUECBAgQIAAgT4Cp6encXZ21qeyn9Ry9OB5b13jybJchc4Mgp8i4vY+iGa7M4BmwKxw+nl\/bBs2s0yF1TqnyuT18vx85PMsW39Zpsq\/O+pwqJwAAQIECBAgcBiBi4uLOD8\/P8zFf\/OqRw+ed9c1nu6DZwbA+stwWcEw+5LHMzhmQGxXLCtsZpkKpvX6tlwFzLpWnvv+N6EUI0CAAAECBAj8zwKCZ0TkiufjZblaccwweNqsTlbozCBaq6Dblc4MnHlO+zF9nZf\/83itcua5b\/7nWaPtBAgQIECAAIE\/EBA898Gz\/ai9PvLeBsYKkj+6t7NWSbf3idbxDJ0fI8LH6H8wS51CgAABAgQITCEgeEZ821iUwbMe7b2ZdSxXLLebhmpltL2vM8vXR\/G5QprnvJ1iqugEAQIECBAgQODvBATPffB8tizXdqfXamcFyQqe7WpoPq9V0AyZtXEoj1nZ\/LuJ6WwCBAgQIEBgPgHBcx88ny\/Ld1+b1G40quDZ3quZO9\/br1eyUWi+N4geESBAgAABAv9OQPBsgmeFywyT7Uag9muPir52t+d\/q5v\/bkK6EgECBAgQIDCvgOAZEQ\/WNXLFs90g1N632a5qZtDMUOq+zXnfFHpGgAABAgQIHEZA8NwEz\/ZXiOqezfruzdeHGQNXJUCAAAECBAjcCAHBMyIe7lc8253rtYNd2LwR7wOdJECAAAECBDoICJ774Pmy2dUubHaYeaogQIAAAQIEbpyA4BkRj9Y1XixLvLpxw6\/DBAgQIECAAIF+AoJnP2s1ESBAgAABAgQIHFngZLfbbX\/i\/MhNUj0BAgQIECBAgMCMAoLnjKOqTwQIECBAgACBAQUEzwEHRZMIECBAgAABAjMKCJ4zjqo+ESBAgAABAgQGFBA8BxwUTSJAgAABAgQIzCggeM44qvpEgAABAgQIEBhQQPAccFA0iQABAgQIECAwo4DgOeOo6hMBAgQIECBAYEABwXPAQdEkAgQIECBAgMCMAoLnjKOqTwQIECBAgACBAQUEzwEHRZMIECBAgAABAjMKCJ4zjqo+ESBAgAABAgQGFBA8BxwUTSJAgAABAgQIzCggeM44qvpEgAABAgQIEBhQQPAccFA0iQABAgQIECAwo4DgOeOo6hMBAgQIECBAYEABwXPAQdEkAgQIECBAgMCMAoLnjKOqTwQIECBAgACBAQUEzwEHRZMIECBAgAABAjMKCJ4zjqo+ESBAgAABAgQGFPgKec3VISNdVNsAAAAASUVORK5CYII=","height":0,"width":0}}
%---
