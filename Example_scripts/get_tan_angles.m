function [alpha,beta] = get_tan_angles(xs, ys, intrinsics, tform)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [original_y, original_x] = transformPointsInverse(tform, ys, xs);
    centered_x = original_x - intrinsics.PrincipalPoint(1);
    centered_y = original_y - intrinsics.PrincipalPoint(2);
    %d = sqrt(centered_x1.^2 + centered_y1.^2);
    alpha = abs(centered_x) ./ intrinsics.FocalLength(1);
    beta = abs(centered_y) ./ intrinsics.FocalLength(2);
end