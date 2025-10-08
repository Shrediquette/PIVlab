function [img, features, points_obj] = image_feature_extraction(img)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    img = imadjust(imflatfield(img, 200), stretchlim(img), [0 1], 0.7);
    img = imdiffusefilt(img,NumberOfIterations=50, ConductionMethod="quadratic", GradientThreshold=40);
    regions = detectMSERFeatures(...
        img, ...
        ThresholdDelta=7, ...
        RegionAreaRange=[1000, 1e6], ...
        MaxAreaVariation=100 ...
    );
    [features, points_obj] = extractFeatures(img, regions);
    show_regions(img, regions) % Show the detected regions
end


function show_regions(img, regions)
    figure; 
    imshow(img); 
    hold on;
    plot(regions,'showPixelList',true,'showEllipses',false);
    hold off
    drawnow
end