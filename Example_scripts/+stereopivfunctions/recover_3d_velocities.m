function [u,v,w] = recover_3d_velocities(u1, v1, a1, b1, u2 ,v2 ,a2 , b2)
%UNTITLED3 Summary of this function goes here
% Calculate the new 3-d velocities using 
% u = (u1 * tan(alpha2) + u2 * tan(alpha1)) / (tan(alpha1) + tan(alpha2))
% v = (v1 * tan(beta2) + v2 * tan(beta2)) / (tan(beta1) + tan(beta2))
% w = (u1 - u2) / (tan(alpha1) + tan(alpha2))
% or
% w = (v1 + v2) / (tan(beta1) + tan(beta2))
% if one of the denominators approaches zero (eg )  then use
% v = 0.5 * (v1+v2) + 0.5 * w * (tan(beta1) - tan(beta2))
% to avoid the singularity
    da = a1 + a2;
    db = b1 + b2;
    alpha_mask = abs(atan(a1)) < 0.001 & abs(atan(a2)) < 0.001;
    beta_mask = abs(atan(b1)) < 0.001 & abs(atan(b2)) < 0.001;

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