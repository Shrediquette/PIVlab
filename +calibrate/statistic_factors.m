function f = statistic_factors(calu, calv, statistic)
%STATISTIC_FACTORS Factors from the pixel data of a frame to the user's units, for normal frames and
%   frames of temporal statistics.
%   f = calibrate.statistic_factors(calu, calv, statistic)
%   statistic  '' or 'mean' or 'sum': velocities (u*calu, v*calv, w along z = x cross y)
%              'std':  standard deviation, never negative (|calu|, |calv|)
%              'tke':  turbulent kinetic energy 0.5*var, in velocity units squared (calu^2, calv^2)
%   f.u, f.v, f.w  factors for u, v and the stereo-PIV component w
switch lower(char(statistic))
    case 'tke'
        f.u = calu^2;
        f.v = calv^2;
        f.w = calu^2;
    case 'std'
        f.u = abs(calu);
        f.v = abs(calv);
        f.w = abs(calu);
    otherwise
        f.u = calu;
        f.v = calv;
        f.w = calibrate.w_factor(calu, calv);
end
end
