function [etot, ebias, erms, Npart, C] = error_window(displ, peaks, grdx, grdy, ws, nRmsLength, position_weight, ROI) %#ok<INUSL>
% Per-window uncertainty aggregation using Gaussian weighting.
% displ, peaks: full-image disparity map and peak weights from uncertainty.disparity.
% grdx, grdy:   PIV grid coordinate vectors (pixels, 1-based).
% ws:           window size in pixels (odd number recommended).
% nRmsLength:   smoothing passes (1 = no smoothing, kept for API compatibility).
% position_weight: 'gauss' (recommended) or 'tophat'.
% ROI:          [xmin xmax ymin ymax] in pixels, or [] for full image.
% Adapted from the MATLAB package by Dr. A. Sciacchitano (TU Delft, July 2016):
%   http://piv.de/uncertainty/?page_id=221
% Reference: Sciacchitano A, Wieneke B and Scarano F (2013),
%   PIV uncertainty quantification by image matching,
%   Meas. Sci. Technol. 24 045302. DOI: 10.1088/0957-0233/24/4/045302

lenx = length(grdx); leny = length(grdy);
[J, I] = size(peaks);

r = (ws-1)/2;
if strcmp(position_weight, 'tophat')
    coeff = 1;
    gaussweight = ones(2*r+1);
elseif strcmp(position_weight, 'gauss')
    coeff = 1.75;
    gaussweight = uncertainty.gauss2d(round(2*coeff*r+1), round(2*coeff*r+1));
else
    error('"position_weight" must be "tophat" or "gauss"');
end

if isempty(ROI)
    ROI = [1, I, 1, J];
end

ebias = zeros(leny, lenx);
erms  = zeros(leny, lenx);
Npart = zeros(leny, lenx);
etot  = zeros(leny, lenx);
C     = 0;

for jgrid = 1:leny
    j = grdy(jgrid);
    jmin = max(1, j - coeff*r); jmax = min(J, j + coeff*r);
    for igrid = 1:lenx
        i = grdx(igrid);
        if i >= ROI(1) && i <= ROI(2) && j >= ROI(3) && j <= ROI(4)
            imin = max(1, i - coeff*r); imax = min(I, i + coeff*r);

            displwin  = displ(jmin:jmax, imin:imax);
            gaussloc  = gaussweight(1+coeff*r-(j-jmin) : 1+coeff*r+(jmax-j), ...
                                    1+coeff*r-(i-imin) : 1+coeff*r+(imax-i));
            peakswin  = peaks(jmin:jmax, imin:imax) .* gaussloc;
            peaksold  = peakswin;
            displold  = displwin;
            displwin  = displold(displold ~= 0);
            peakswin  = peakswin(displold ~= 0);

            outliers = uncertainty.outliers(displwin);
            displwin(outliers == 1) = [];
            peakswin(outliers == 1) = [];

            if isempty(peakswin) || sum(peakswin) == 0
                continue
            end

            ebiasloc = sum(displwin .* peakswin) / sum(peakswin);
            ermsloc  = sqrt(sum(peakswin .* (displwin - ebiasloc).^2) / sum(peakswin));
            Nweight  = sum(sum((peaksold > 0) .* gaussloc));
            if Nweight < 1, Nweight = 1; end

            ebias(jgrid, igrid) = ebiasloc;
            erms(jgrid,  igrid) = ermsloc;
            etot(jgrid,  igrid) = sqrt(ermsloc^2 / Nweight + ebiasloc^2);
            Npart(jgrid, igrid) = Nweight;
        end
    end
end

ebias(isnan(ebias)) = 0;
erms(isnan(erms))   = 0;
etot(isnan(etot))   = 0;
end
