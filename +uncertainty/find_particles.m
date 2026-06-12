function [iPeak, jPeak] = find_particles(im, index, rsearch)
% Brightest 4-connected local maximum within rsearch of index in im.
% Adapted from the MATLAB package by Dr. A. Sciacchitano (TU Delft, July 2016).
[J, I] = size(im);
[jp, ip] = ind2sub(size(im), index);
r = 0; iPeak = 0; jPeak = 0; imax = 0;
while r <= rsearch && imax == 0
    for j = max(2, jp-r) : min(J-1, jp+r)
        for i = max(2, ip-r) : min(I-1, ip+r)
            if im(j,i) > im(j-1,i) && im(j,i) > im(j,i-1) && ...
               im(j,i) > im(j+1,i) && im(j,i) > im(j,i+1) && im(j,i) > imax
                jPeak = j; iPeak = i; imax = im(j,i);
            end
        end
    end
    r = r + 1;
end
end
