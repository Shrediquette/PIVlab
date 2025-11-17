function [u,v,w] = recover_3d_velocities(u1, v1, a1, b1, u2 ,v2 ,a2, b2)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    da = a1 + a2;
    db = b1 + b2;
    alpha_mask = da < 0.01;
    beta_mask = db < 0.01;
    
    u_mean = 0.5 * (u1 + u2);
    v_mean = 0.5 * (v1 + v2);
    u_coef = (b1 - b2) ./ da;
    v_coef = (a1 - a2) ./ db;

    u = (u1 .* a2 + u2 .* a1) ./ da;
    v = (v1 .* b2 + v2 .* b1) ./ db;

    u(alpha_mask) = u_mean(alpha_mask) + v_mean(alpha_mask) .* v_coef(alpha_mask);
    v(beta_mask) = v_mean(beta_mask) + u_mean(beta_mask) .* u_coef(beta_mask);

    w = (u1 - u2) ./ da;
    w(alpha_mask) = (u(alpha_mask) - u(alpha_mask)) ./ da(alpha_mask);
    w(beta_mask) = (v1(beta_mask) - v2(beta_mask)) ./ db(beta_mask);
end