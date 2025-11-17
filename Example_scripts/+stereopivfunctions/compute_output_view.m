function [output_view] = compute_output_view(image_size, tform1, tform2)
%COMPUTE_OUTPUT_VIEW Summary of this function goes here
%   Detailed explanation goes here
    [xl1, yl1] = outputLimits(tform1, [1 image_size(2)], [1 image_size(1)]);
    [xl2, yl2] = outputLimits(tform2, [1 image_size(2)], [1 image_size(1)]);
    xLimits = [xl1; xl2];
    yLimits = [yl1; yl2];
    xMin = min([1; xLimits(:,1)]);
    xMax = max([image_size(2); xLimits(:,2)]);
    yMin = min([1; yLimits(:,1)]);
    yMax = max([image_size(1); yLimits(:,2)]);
    width  = round(xMax - xMin);
    height = round(yMax - yMin);
    output_view = imref2d(...
        [height width], ...
        [min(xLimits(:,1)), max(xLimits(:,2))], ...
        [min(yLimits(:,1)), max(yLimits(:,2))]...
    );
end