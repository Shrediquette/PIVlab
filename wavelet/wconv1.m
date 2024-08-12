function y = wconv1(x,f,shape)
%WCONV1 1-D Convolution.
%   Y = WCONV1(X,F) performs the 1-D convolution of the 
%   vectors X and F.
%   Y = WCONV1(...,SHAPE) returns a subsection of the
%   convolution with size specified by SHAPE (See CONV2).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% The following is needed for the legacy CWT() with a complex filter
complexFilter = ~isreal(f);
if complexFilter
    f = conj(f);
end

if nargin<3
    shape = 'full';
end

y = conv(x,f,shape);
if isrow(x) && ~isrow(y)
    y = reshape(y,1,[]);
end
