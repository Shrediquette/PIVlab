function [img_p, features, points_obj] = image_feature_extraction(img)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    %img_p = imdiffusefilt(img, NumberOfIterations=3, ConductionMethod="quadratic", GradientThreshold=[9 7 6]);
    %img_p = imnlmfilt(img,"DegreeOfSmoothing",10, "SearchWindowSize",17, "ComparisonWindowSize",15);
    %
    img_p = imgaussfilt(imflatfield(img,300), 21, FilterSize=51);
    img_p = imadjust(img_p);%,[0.0 0.15],[0 1], 0.5);%, stretchlim(img_p), [0 1], 0.7);
    regions = detectMSERFeatures(...
        img_p, ...
        ThresholdDelta=1, ...
        RegionAreaRange=[500, 1e6] ...
    );
    [features, points_obj] = extractFeatures(img_p, regions);
    %show_regions(img_p, regions) % Show the detected regions
end


function show_regions(img, regions)
    figure; 
    imshow(img); 
    hold on;
    plot(regions,'showPixelList',true,'showEllipses',false);
    hold off
    drawnow
end