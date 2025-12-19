function [img1m, img2m, piv_mask] = image_intersection(img1, img2)
%IMAGE_INTERSECTION The mask for a pair of images in a common view where
%both images contain non-zero data
%   Detailed explanation goes here    
    mask = make_intersction_mask(img1, img2);

    img1m = zeros(size(img1), 'uint8');
    img2m = zeros(size(img2), 'uint8');
    img1m(mask) = img1(mask);
    img2m(mask) = img2(mask);
    piv_mask = not(mask);
end


function [img_mask] = make_intersction_mask(img1, img2)
    img_a = img1 > 0;
    img_b = img2 > 0;
    img_mask = img_a & img_b;
end
