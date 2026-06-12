function [xsub, ysub] = subpixel(im)
% 3-point log-Gaussian subpixel position for every pixel in im.
% Adapted from the MATLAB package by Dr. A. Sciacchitano (TU Delft, July 2016).
if min(im(:)) < 0
    im = im + abs(min(im(:))) + eps;
end
im = log(im);
[J, I] = size(im);
imE = zeros(J,I)+eps; imW = zeros(J,I)+eps;
imN = zeros(J,I)+eps; imS = zeros(J,I)+eps;
imE(:,1:end-1) = im(:,2:end);
imW(:,2:end)   = im(:,1:end-1);
imN(2:end,:)   = im(1:end-1,:);
imS(1:end-1,:) = im(2:end,:);
xsub = (imW - imE) ./ 2 ./ (imE + imW - 2*im);
ysub = (imS - imN) ./ 2 ./ (imS + imN - 2*im);
end
