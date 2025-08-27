function [LoG] = lap_of_grad(img, sigma)
%LAP_OF_GRAD Summary of this function goes here
%   Detailed explanation goes here
if ndims(img) > 2
    img = rgb2gray(img);
end
cutoff = ceil(2 * sigma);
G = fspecial('gaussian', [1, 2 * cutoff + 1], sigma);
d2G = G .* ((-cutoff:cutoff) .^2 - sigma ^ 2) / (sigma ^ 4);
dxx = conv2(d2G, G, img, 'same');
dyy = conv2(G, d2G, img, 'same');
LoG = dxx + dyy;
LoG = LoG - min(LoG(:));
LoG = LoG / max(LoG(:));
end