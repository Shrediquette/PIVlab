function [psidft,F] = wavbpfilters(wname,omega,scales)
%   This function is for internal use only. It may change or be removed in
%   a future release.
%   [psidft,F] = wavbpfilters(wname,omega,scales)
%   For code generation, omega and scales should be varsize inputs

%   Copyright 2017-2020 The MathWorks, Inc.

%#codegen
narginchk(3,3);
coder.internal.prefer_const(wname);
wname = char(wname);
coder.internal.assert(isrow(omega) && isrow(scales),...
    'Wavelet:codegeneration:ScalesOmegaRowVector');
if numel(scales) == 1
    somega = bsxfun(@times,scales,omega);
else
    somega = scales'*omega;
end
psidft = zeros(numel(scales),numel(omega));
fc = zeros(1,1);
switch wname
    case 'amor'
        fc = 6;
        mul = 2;
        squareterm = (somega-fc).*(somega-fc);
        gaussexp = -squareterm./2;
        expnt = gaussexp.*(somega > 0);
        psidft = mul*exp(expnt).*(somega > 0);
    case 'bump'
        fc = 5;
        sigma = 0.6;
        w = (somega-fc)./sigma;
        absw2 = w.*w;
        expnt = -1./(1-absw2);
        daughter = 2*exp(1)*exp(expnt).*(abs(w)<1-eps(1));
        daughter(isnan(daughter)) = 0;
        psidft = daughter;
end

% Convert to cyclical frequency
FourierFactor = fc/(2*pi);
F = FourierFactor./scales;





