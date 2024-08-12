function rowidx = reflectIdx(Nx,Nh)
% This function is for internal use only. It may change or be removed in a
% future release.

% Copyright 2019-2020 The MathWorks, Inc.

%#codegen

% This is the amount of extension
I = [Nh:-1:1, 1:Nx, Nx:-1:Nx-Nh+1];

% Correct for the case in which the row dimension is less than the filter
% or half filter length
if Nx<Nh
    % Find negative values and 0
    K = (I<1);
    I(K) = 1-I(K);
    % Find indices greater than the row dimension of the data
    J = (I>Nx);
    while any(J)
        I(J) = 2*Nx+1-I(J);
        K = (I<1);
        I(K) = 1-I(K);
        J = (I>Nx);
    end
end
rowidx = I(:);

