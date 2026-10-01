function img = prepare_image(img, s)
%PREPARE_IMAGE Intensity limits + pre-processing of one image, exactly as used for the PIV analysis.
%   img = piv.prepare_image(img, s)
%   s: settings struct (see piv.analyze_pair). With s.autolimit == 1 the intensity limits are
%   determined from the image itself (stretchlim), otherwise s.minintens / s.maxintens are used.
if s.autolimit == 1
    if size(img,3)>1
        stretcher = stretchlim(rgb2gray(img));
    else
        stretcher = stretchlim(img);
    end
else
    stretcher = [s.minintens s.maxintens];
end
img = preproc.PIVlab_preproc( ...
    in=img, roirect=s.roirect, clahe=s.clahe, clahesize=s.clahesize, ...
    highp=s.highp, highpsize=s.highpsize, intenscap=s.intenscap, ...
    wienerwurst=s.wienerwurst, wienerwurstsize=s.wienerwurstsize, ...
    minintens=stretcher(1), maxintens=stretcher(2));
end
