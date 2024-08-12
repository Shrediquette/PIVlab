function y = unpadimage(x,log2ds,origsize)
% This function is for internal use only. It may change or be removed in a
% future release.

%   Copyright 2018-2020 The MathWorks, Inc.

% Here we only care about the X and Y size
[M,N,~] = size(x);
szX = [M N];
% Prevent from being empty
origds = 1+fix((origsize(1:2)-1)./2^log2ds);

if any(origds > szX)
    error(message('Wavelet:scattering:resnotmatch2',log2ds));
end
d = (szX-origds)/2;
first = 1+floor(d);
last = szX-ceil(d);
y = x(first(1):last(1),first(2):last(2),:);


