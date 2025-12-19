function [img_p, features, points_obj] = image_feature_extraction(img)
%IMAGE_FEATURE_EXTRACTION preprocess an image and detect MSER features
%   This function has been designed to aid feature detection on images of
%   vapour. 
% Arguments:
%   img: An image object process
% Ouputs:
%   img_p: The processed image used in the feature detection
%   features: The detected features
%   points_obj: THe points associated with the features

    test = false;

    % Try imhistmatch
    img_p = imgaussfilt(imflatfield(img,300), 21, FilterSize=51);
    img_p = imadjust(img_p);
    regions = detectMSERFeatures(...
        img_p, ...
        ThresholdDelta=1, ...
        RegionAreaRange=[500, 1e6] ...
    );
    [features, points_obj] = extractFeatures(img_p, regions);
    if test
        show_regions(img_p, regions) % Show the detected regions
    end
end


function show_regions(img, regions)
    figure; 
    imshow(img); 
    hold on;
    plot(regions,'showPixelList',true,'showEllipses',false);
    hold off
    drawnow
end