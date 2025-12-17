function [u,v,w] = recover_3d_velocities(u1, v1, a1, b1, u2 ,v2 ,a2 , b2)
%RECOVER_3D_VELOCITIES Recover 3-D velocities for a pair of 2-D velocities
%and the tangent of the angles between the 2-D plane and the respective
%cameras
%   Arguments
%       u1, v1, u2, v2: The horizontal and vertical components of the
%       velocity for cameras 1 and 2
%       a1, b1, a2, b2: The angles between a horizontal and vertical plane
%       that are perpendicular to both u and v
%   Returns:
%       u, v, w: The 3-D velocities

    % Calculate the new 3-d velocities using 
    % u = (u1 * tan(alpha2) + u2 * tan(alpha1)) / (tan(alpha1) + tan(alpha2))
    % v = (v1 * tan(beta2) + v2 * tan(beta2)) / (tan(beta1) + tan(beta2))
    % w = (u1 - u2) / (tan(alpha1) + tan(alpha2))
    % or
    % w = (v1 + v2) / (tan(beta1) + tan(beta2))
    % if one of the denominators approaches zero (eg )  then use
    % v = 0.5 * (v1+v2) + 0.5 * w * (tan(beta1) - tan(beta2))
    % to avoid the singularity
    % See equations 7.3 -> 7.8 (pages 213, 214) in Particle Image
    % Velocimetry: Apractical Guide (2007), M. Raffel, C. E. Willert, S. T.
    % Wereley, J. Kompenhans, Springer
    da = a1 + a2;
    db = b1 + b2;
    alpha_mask = abs(atan(a1)) < 0.002 | abs(atan(a2)) < 0.002;
    beta_mask = abs(atan(b1)) < 0.002 | abs(atan(b2)) < 0.002;

    u = (u1 .* a2 + u2 .* a1) ./ da;
    v = (v1 .* b2 + v2 .* b1) ./ db;

    w = (u1 - u2) ./ da;

    if any(alpha_mask,'all') || any(beta_mask, 'all')
        u_mean = 0.5 * (u1 + u2);
        u_diff = 0.5 * (u1 - u2);
        v_mean = 0.5 * (v1 + v2);
        v_diff = 0.5 * (v1 - v2);
        u_coef = (b1 - b2) ./ da;
        v_coef = (a1 - a2) ./ db;
        
        u(alpha_mask) = u_mean(alpha_mask) + v_diff(alpha_mask) .* v_coef(alpha_mask);
        v(beta_mask) = v_mean(beta_mask) + u_diff(beta_mask) .* u_coef(beta_mask);
        
        w(alpha_mask) = (u(alpha_mask) - u(alpha_mask)) ./ da(alpha_mask);
        w(beta_mask) = (v1(beta_mask) - v2(beta_mask)) ./ db(beta_mask);
    end
end