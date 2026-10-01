function [imdeform, repeat, do_pad] = corr_quality_params(quali)
%CORR_QUALITY_PARAMS Correlation robustness setting -> PIV parameters.
%   quali: 1 = standard, 2 = high, 3 = extreme (the "Correlation robustness" popup in PIVlab)
%   imdeform: image deformation interpolator, repeat: repeated correlation in the last pass,
%   do_pad: linear correlation (zero padding).
switch quali
    case 2 % high quality
        imdeform='*spline';
        repeat = 0;
        do_pad = 1;
    case 3 % ultra quality
        imdeform='*spline';
        repeat = 1;
        do_pad = 1;
    otherwise % normal quality
        imdeform='*linear';
        repeat = 0;
        do_pad = 0;
end
end
