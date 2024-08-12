function [psidft,F] = morsebpfilters(omega,scales,ga,be)
% This function is for internal use. It may change in a future release.
% [psidft,F] = morsebpfilters(omega,scales,ga,be);
% For code generation - varsize inputs on omega and scales. These are
% required to be row vectors

%   Copyright 2017-2020 The MathWorks, Inc.
%#codegen

coder.varsize('omega')
coder.varsize('scales');
coder.internal.assert(isrow(omega),'Wavelet:codegeneration:ScalesOmegaRowVector');
coder.internal.assert(isrow(scales),'Wavelet:codegeneration:ScalesOmegaRowVector');
coder.internal.prefer_const(ga,be);
if numel(scales) == 1
    somega = bsxfun(@times,scales,omega);
else
    somega = scales'*omega;
end
fo = wavelet.internal.cwt.morsepeakfreq(ga,be);
absomega = abs(somega);
% For the case when gamma is 3, this matrix multiply is much faster than
% the element-by-element power operator.
if ga == 3
    powscales = absomega.*absomega.*absomega;
else
    powscales = absomega.^ga;
end
% basicmorse = 2*exp(-be.*log(fo)+fo.^ga+be.*log(absomega)-powscales).*(somega>0);
factor = exp(-be*log(fo)+fo^ga);
psidft = 2*factor*exp(be.*log(absomega)-powscales).*(somega>0);
% psidft = Akbg*basicmorse;
F  = (fo./scales)/(2*pi);





