function f = w_factor(calu, calv)
%W_FACTOR Factor from the stereo-PIV out-of-plane component in px per frame to w in the user's units.
%   f = calibrate.w_factor(calu, calv)
%   x, y and z form a right-handed coordinate system (z = x cross y), w is positive along z.
%   The pixel W is positive along z of the image coordinates (x right, y down, z away from the
%   cameras). Reversing one of the axes x or y reverses z, reversing both keeps it.
f = abs(calu) * sign(calu) * sign(calv);
end
