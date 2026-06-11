function peaks = get_max(im, weight)
% Local maxima of im weighted by sqrt(abs(im)) when weight='sqrt'.
% Adapted from Wieneke (2013) disparity_uncertainty package.
[J, I] = size(im);
imC  = im(2:J-1, 2:I-1);
imW  = im(2:J-1, 1:I-2); imE  = im(2:J-1, 3:I);
imN  = im(1:J-2, 2:I-1); imS  = im(3:J,   2:I-1);
imNW = im(1:J-2, 1:I-2); imNE = im(1:J-2, 3:I);
imSW = im(3:J,   1:I-2); imSE = im(3:J,   3:I);
peaks = zeros(J, I);
peaks(2:J-1, 2:I-1) = (imC>imW & imC>imE & imC>imN & imC>imS & ...
                        imC>imNW & imC>imNE & imC>imSW & imC>imSE);
if strcmp(weight, 'I1I2')
    peaks = peaks .* im;
elseif strcmp(weight, 'sqrt')
    peaks = peaks .* sqrt(abs(im));
elseif ~strcmp(weight, 'peaks')
    error('weight must be peaks, sqrt or I1I2');
end
end
