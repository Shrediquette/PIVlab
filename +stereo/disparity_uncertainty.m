function accuracy = disparity_uncertainty(calib, raw, model)
%DISPARITY_UNCERTAINTY Estimated error of a disparity map from the scatter between the image pairs.
%   accuracy = stereo.disparity_uncertainty(calib, raw, model)
%   calib  stereo.calibrate (calib.mask: true outside the measurement area)
%   raw    one disparity measurement (stereo.measure_disparity): x, y and the validated map of every image
%          pair, u_frames and v_frames (3rd dimension = pairs, in the order in which they were measured)
%   model  the model of the disparity map (stereo.fit_disparity)
% The pairs are split into two halves (every second pair, so both halves cover the series). Each half gets its
% own model fit. The difference of two independent half means has four times the variance of the mean of all
% pairs, so half the rms difference of the two fitted maps (inside the measurement area) estimates the error
% of the map from all pairs [px rms]. NaN with fewer than 4 pairs or if a half has too few valid vectors.
accuracy = NaN;
n = size(raw.u_frames, 3);
if n < 4
    return
end
fits = cell(1, 2);
for h = 1:2
    half.x = raw.x;
    half.y = raw.y;
    u = raw.u_frames(:, :, h:2:n);
    v = raw.v_frames(:, :, h:2:n);
    half.u = mean(u, 3, 'omitnan');
    half.v = mean(v, 3, 'omitnan');
    half.n_valid = sum(~isnan(u) & ~isnan(v), 3);
    try
        fits{h} = stereo.fit_disparity(calib, half, model);
    catch
        return % too few valid vectors in a half
    end
end
x = double(raw.x);
y = double(raw.y);
inside = ~calib.mask(sub2ind(size(calib.mask), min(max(round(y), 1), size(calib.mask, 1)), ...
    min(max(round(x), 1), size(calib.mask, 2))));
du = fits{1}.u(inside) - fits{2}.u(inside);
dv = fits{1}.v(inside) - fits{2}.v(inside);
accuracy = sqrt(mean(du .^ 2 + dv .^ 2)) / 2;
end
