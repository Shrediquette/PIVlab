function y = meyeraux(x)
%MEYERAUX Meyer wavelet auxiliary function.
%   Y = MEYERAUX(X) returns values of the auxiliary
%   function used for Meyer wavelet generation evaluated
%   at the elements of the vector or matrix X.
%
%   The function is 35*x^4 - 84*x^5 + 70*x^6 - 20*x^7.
%
%   See also MEYER.

%   Copyright 1995-2020 The MathWorks, Inc.

%#codegen
narginchk(1,1);
nargoutchk(0,1);
validateattributes(x,{'single','double'},{'real','finite','nonempty'},'meyeraux','x');
% Auxiliary function values.
p = [-20 70 -84 35 0 0 0 0];
y = zeros(size(x),'like',x);
y = polyval(p,x).*(x>0 & x <= 1);
y(x > 1) = 1;


