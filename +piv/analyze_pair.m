function r = analyze_pair(image1, image2, mask_positions, s)
%ANALYZE_PAIR Pre-process one image pair and run the PIV analysis (no GUI needed).
%   r = piv.analyze_pair(image1, image2, mask_positions, s)
%
%   image1, image2  images as read by import.read_frame (background already subtracted)
%   mask_positions  PIVlab mask objects of this pair (cell, see mask.convert_masks_to_binary),
%                   or a logical mask image (true = masked), or [] / {} for no mask
%   s               settings struct, see piv.settings_from_gui (GUI) or pivlab.defaults (API):
%                   algorithm ('fft' | 'dcc'), autolimit, minintens, maxintens, roirect,
%                   clahe, clahesize, highp, highpsize, intenscap, wienerwurst, wienerwurstsize,
%                   interrogationarea, step, subpixfinder, passes, int2, int3, int4, mask_auto,
%                   imdeform, repeat, do_pad, repeat_last_pass, delta_diff_min,
%                   compute_uncertainty, do_correlation_matrices
%
%   r  struct with x, y, u, v, typevector, correlation_map, u2, v2, umap
%      (the content of PIVlab's resultslist rows 1-5 and 12-15)
%
%   Used by the GUI analysis loops (serial and parallel) and by pivlab.piv.

image1 = piv.prepare_image(image1, s);
image2 = piv.prepare_image(image2, s);

if islogical(mask_positions) && isequal(size(mask_positions),size(image1(:,:,1)))
    converted_mask = mask_positions;
else
    if isempty(mask_positions)
        mask_positions = cell(0);
    end
    converted_mask=mask.convert_masks_to_binary(size(image1(:,:,1)),mask_positions);
end

u2=[]; v2=[]; umap=[];
switch s.algorithm
    case 'dcc'
        [x, y, u, v, typevector] = piv.piv_DCC (image1,image2,s.interrogationarea, s.step, s.subpixfinder, converted_mask, s.roirect);
        correlation_map=zeros(size(x)); %no correlation coefficient in DCC.
    case 'fft'
        [x, y, u, v, typevector,correlation_map,~,~,u2,v2,umap] = piv.piv_FFTmulti( ...
            image1=image1, image2=image2, interrogationarea=s.interrogationarea, step=s.step, ...
            subpixfinder=s.subpixfinder, mask_inpt=converted_mask, roi_inpt=s.roirect, ...
            passes=s.passes, int2=s.int2, int3=s.int3, int4=s.int4, imdeform=s.imdeform, ...
            repeat=s.repeat, mask_auto=s.mask_auto, do_linear_correlation=s.do_pad, ...
            do_correlation_matrices=s.do_correlation_matrices, ...
            repeat_last_pass=s.repeat_last_pass, delta_diff_min=s.delta_diff_min, ...
            compute_uncertainty=s.compute_uncertainty);
    otherwise
        error('piv:analyze_pair:algorithm','Unknown algorithm "%s" (use ''fft'' or ''dcc'').', s.algorithm)
end
r = struct('x',x,'y',y,'u',u,'v',v,'typevector',typevector,'correlation_map',correlation_map, ...
    'u2',u2,'v2',v2,'umap',umap);
end
