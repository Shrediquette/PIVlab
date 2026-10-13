function tf = opposite_sides(calib)
%OPPOSITE_SIDES True if the two cameras are on opposite sides of the light sheet (board plane z = 0).
%   tf = stereo.opposite_sides(calib)
tf = sign(calib.centre(1, 3)) ~= sign(calib.centre(2, 3));
end
