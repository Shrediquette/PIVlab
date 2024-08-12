function scalf = blscalf(wshortname)
% BLSCALF Best-localized Daubechies scaling filter
% SCALF = BLSCALF(WNAME) returns the best-localized Daubechies scaling
% filter corresponding to WNAME. Valid entries for WNAME are "bl7", "bl9",
% or "bl10". SCALF should be used in conjunction with ORTHFILT to obtain
% scaling and wavelet filters with the proper normalization.
% The scaling filters tabulated here agree exactly with Doroslovacki
% (1998). The sum of filter coefficients is nearly sqrt(2) and the L2 norm
% is nearly 1.0.
%
%   %Example: Obtain the scaling and wavelet filters corresponding to the
%   %   "bl10" wavelet.
%   scalf = blscalf("bl10");
%   [LoD,HiD,LoR,HiR] = orthfilt(scalf);
%   [tf,checks] = isorthwfb(LoD);
%
% See also symwavf, dbwavf, modwt, modwpt, wavedec, dwpt

% Doroslovacki, M.L. "On the Least Asymmetric Wavelets.”
% IEEE Transactions on Signal Processing 46, no. 4 (1998): 1125–30.
% https://doi.org/10.1109/78.668562.
%
%   Copyright 2021 The MathWorks, Inc.


%#codegen

narginchk(1,1);
validateattributes(wshortname,{'char','string'},{'scalartext'},...
    'blscalf','wname');
coder.internal.errorIf(~any(strcmpi(wshortname,{'bl7','bl9','bl10'})), ...
    'Wavelet:scalingfilters:InvalidBLFilter');

switch lower(wshortname)
    case 'bl7'

        g = [2.291833954100913e-03
            -3.283297847308129e-03
            -1.812660513110648e-02
            2.046420757782253e-02
            4.474234946874048e-02
            -1.010109208664125e-01
            -5.680447688227074e-02
            4.836109156937821e-01
            7.819215932965554e-01
            3.602184608985549e-01
            -6.413128981891700e-02
            -6.490800355337438e-02
            1.721337629944389e-02
            1.201541928348415e-02];

    case 'bl9'

        g = [5.774604551247538e-3
            1.396363624871906e-2
            -3.484602376983684e-2
            -1.143343069619310e-1
            8.056700088685460e-2
            5.926551374433956e-1
            7.374707619933686e-1
            2.337782900224977e-1
            -1.432929759396520e-1
            -2.114803106887737e-2
            8.561240172652788e-2
            -2.189514157347583e-4
            -2.953614337336035e-2
            4.067656296578464e-3
            5.984552518172132e-3
            -1.916107004755742e-3
            -6.273974067727908e-4
            2.594576266544161e-4];

    case 'bl10'

        g = [8.625782242896322e-4
            7.154205305516501e-4
            -7.056764090970080e-3
            5.956827305406235e-4
            4.968612650759787e-2
            2.624036470542513e-2
            -1.215521061578162e-1
            -1.501923954136436e-2
            5.137098728334054e-1
            7.669548365010849e-1
            3.402160135110789e-1
            -8.787871073786671e-2
            -6.708990716806683e-2
            3.384235500646907e-2
            -8.687519578684053e-4
            -2.300546128629051e-2
            -1.140429777332407e-3
            5.071649194579267e-3
            3.401492622331587e-4
            -4.101159165851847e-4];
    otherwise

        % This will not be hit, but coder needs to know that g is defined
        % on all paths.
        g = [2.291833954100913e-03
            -3.283297847308129e-03
            -1.812660513110648e-02
            2.046420757782253e-02
            4.474234946874048e-02
            -1.010109208664125e-01
            -5.680447688227074e-02
            4.836109156937821e-01
            7.819215932965554e-01
            3.602184608985549e-01
            -6.413128981891700e-02
            -6.490800355337438e-02
            1.721337629944389e-02
            1.201541928348415e-02];

end

scalf = g.';

end
