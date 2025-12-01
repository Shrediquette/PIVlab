function [alpha,beta] = get_tan_angles(coords, distance)
%UNTITLED get the alpha and beta angles
%   Detailed explanation goes here
    % [original_y, original_x] = transformPointsInverse(tform, ys, xs);
    % centered_x = original_x - intrinsics.PrincipalPoint(1);
    % centered_y = original_y - intrinsics.PrincipalPoint(2);
    %d = sqrt(centered_x1.^2 + centered_y1.^2);
    alpha = abs(coords(:,1)) ./ distance;
    beta = abs(coords(:,2)) ./ distance;
end