function anorm = morsenormconstant(ga,be)
% anorm = morsenormconstant(ga,be) returns the normalizing constant so that
% the 0-th order Morse wavelet at the peak frequency is equal to 2.
% 
% This function is for internal use only, it may change in a future
% release.
%

% Copyright 2017-2020 The MathWorks, Inc.
%#codegen 

anorm = 2*exp(be/ga*(1+(log(ga)-log(be))));
