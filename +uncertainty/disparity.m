function [Xdisparity, Ydisparity, immult, peaks] = disparity(im1, im2, rsearch, weight)
% Full-image particle-disparity computation for PIV uncertainty.
% Adapted from Wieneke (2013) disparity_uncertainty package.
% See: Sciacchitano, Wieneke & Scarano (2013) Meas. Sci. Technol. 24 035401.
if nargin < 4, weight = 'peaks'; end

immult = im1 .* im2;
[J, I] = size(im1);
im1pos = im1 > 0; im2pos = im2 > 0;
im1 = im1 + abs(min(im1(:))) + eps;
im2 = im2 + abs(min(im2(:))) + eps;

[X1, Y1] = meshgrid(1:I, 1:J);
[X2, Y2] = meshgrid(1:I, 1:J);
Xpos1 = X1; Ypos1 = Y1;
Xpos2 = X2; Ypos2 = Y2;

peaks = uncertainty.get_max(immult, weight);
peaksIndex = find(peaks > 0);

[X1sub, Y1sub] = uncertainty.subpixel(im1); X1sub(isnan(X1sub)) = 0; Y1sub(isnan(Y1sub)) = 0;
[X2sub, Y2sub] = uncertainty.subpixel(im2); X2sub(isnan(X2sub)) = 0; Y2sub(isnan(Y2sub)) = 0;

for nIndex = 1:numel(peaksIndex)
    peakIndexLoc = peaksIndex(nIndex);
    [ip1, jp1] = uncertainty.find_particles(im1, peakIndexLoc, rsearch);
    [ip2, jp2] = uncertainty.find_particles(im2, peakIndexLoc, rsearch);
    if ip1*ip2*jp1*jp2 > 0
        Xpos1(peakIndexLoc) = X1(jp1,ip1) + X1sub(jp1,ip1);
        Ypos1(peakIndexLoc) = Y1(jp1,ip1) - Y1sub(jp1,ip1);
        Xpos2(peakIndexLoc) = X2(jp2,ip2) + X2sub(jp2,ip2);
        Ypos2(peakIndexLoc) = Y2(jp2,ip2) - Y2sub(jp2,ip2);
    else
        peaks(peakIndexLoc) = 0;
    end
end

Xdisparity = Xpos2 - Xpos1;
Ydisparity = Ypos2 - Ypos1;

Thr = 0 * std(immult(:)) / 3;
Xdisparity = Xdisparity .* (immult > Thr) .* im1pos .* im2pos;
Ydisparity = Ydisparity .* (immult > Thr) .* im1pos .* im2pos;
peaks      = peaks      .* (immult > Thr) .* im1pos .* im2pos;
end
