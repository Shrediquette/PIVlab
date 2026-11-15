function [u, v] = helper_coordinate_flow_field(F, x, y)
%HELPER_COORDINATE_FLOW_FIELD Pixel displacement (u right, v down, like PIVlab internally) of the test
%   flow of helper_coordinate_flow at the pixel positions x, y (y down).
X = x - F.xc;
Y = -(y - F.yc);                              % upward on the screen
U = -F.omega * Y + (F.a + F.s) * X;           % to the right
V = F.omega * X + (F.a - F.s) * Y;            % upward
u = U;
v = -V;                                       % pixel v is positive downward
end
