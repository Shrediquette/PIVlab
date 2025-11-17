function [img1m, img2m, mask] = image_intersection(img1, img2)
%IMAGE_INTERSECTION Summary of this function goes here
%   Detailed explanation goes here    
    mask = make_intersction_mask(img1, img2);

    img1m = zeros(size(img1), 'uint8');
    img2m = zeros(size(img2), 'uint8');
    img1m(mask) = img1(mask);
    img2m(mask) = img2(mask);

    %[ix, iy] = find(mask);
    %limits = [min(ix),max(ix); min(iy),max(iy)];
    %img1m = img1m(limits(1,1):limits(1,2), limits(2,1):limits(2,2));
    %img2m = img2m(limits(1,1):limits(1,2), limits(2,1):limits(2,2));

end


function [img_mask] = make_intersction_mask(img1, img2)
    img_a = img1 > 0;
    img_b = img2 > 0;
    img_mask = img_a & img_b;
end
