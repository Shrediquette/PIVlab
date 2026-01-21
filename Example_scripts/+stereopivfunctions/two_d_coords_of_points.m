function [coords, normal, mu, rt] = two_d_coords_of_points(points)
%TWO_D_COORDS_OF_POINTS Compute the 2-d coordinates of a set of 3-D
%points that lie on a plane
%   Arguments:
%       points: A set of 3-D coordinates (N x 3) that lie on a plane
%   Returns:
%       coords: The 2-D coordinates of the points on the plane
%       normal: The unit normal vector of the plane
%       mu: The centroid of the points in 3-D space
%       rt: The 3-D rigid transform that maps the 3-D coordinates to the
%           2-D plane
    [normal, mu] = find_normal_of_plane(points); 
    R = rotation(normal);
    rt = rigidtform3d(R, mu);
    
    [a, b, c] = transformPointsInverse(rt, points(:,1), points(:,2), points(:,3));  % [a,b] are the 2d world points in real units (c ~= 0)
    % make a quick check that the transformed points have c ~= 0
    x = max(a) - min(a);
    y = max(b) - min(b);
    ev = abs(mean(c) / max(x,y));
    assert(ev < 0.1, sprintf("Bad plane coordinates out-of-plane ratio = %f", ev))
    coords = [a,b];
end


function r = rotation(normal)
    S = reflection(eye(3), normal + [0,0,1]);      % S*u = -v, S*v = -u 
    r = reflection(S, normal); 
end


function r = reflection(u, n)
    r = u - 2 * n' * (n*u) / (n*n');
end


function [normal, mu] = find_normal_of_plane(points)
%FIND_NORMAL_OF_PLANE Find the normal of the plane in which a set of  point
%points lie
%   points is a Nx3 array of coordinates which lie in a plane
%   returns:
%       normal: the normal vector of the plane
%       mu: the centroid of the points
    mu = mean(points, 1); % Find the centroid of the points
    [~,~,V] = svd(points - mu); % The last column of V (the vector corresponding to the smallest SV) is the unit normal to the plane
    normal = V(:,end)';
end