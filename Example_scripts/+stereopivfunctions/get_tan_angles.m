function [alpha,beta] = get_tan_angles(coords, camera_position, lightplane_normal, e_X, e_Y)
%get_tang_angles get the alpha and beta angles
% alpha and beta are the resolved angles between the vector connecting 
% the camera to the point in the laser light field where a velocity 
% vector has been calculated and the normal of the lightplane.
% Arguments
%   coords: the 3-D coordinates of the sampling points 
%   camera_position: the 3-D coordinates of the camera
%   lightplane_normal: the normal vector for the laser light plane

    % calculate the normalised vectors connecting the camera to the
    % sampling points
    camera_to_coords = coords - camera_position;
    camera_to_coords = camera_to_coords / vecnorm(camera_to_coords);
    
    % Resolve the vectors to vertical and horizontal components in the
    % plane of the light field using the rows and columns of the sampling
    % points as the Y and X directions in the plane

    % Use the dot and cross products to calculate the angles to the plane
    % tan = sin/con = a X b / a . b

    alpha = abs(coords(:,1)) ./ distance;
    beta = abs(coords(:,2)) ./ distance;
end