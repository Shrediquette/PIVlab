function scalf = mbscalf(wshortname)
% MBSCALF Morris minimum-bandwidth discrete-time wavelets
% SCALF = MBSCALF(WNAME) returns the Morris minimum-bandwidth scaling
% filter specified by the character vector or scalar string, WNAME.
% For the Morris minimum-bandwidth scaling filters, WNAME has the form
% "mbN.L", where N is the number of filter coefficients (taps) and L is the
% level of the discrete wavelet transform used in the optimization. 
% These orthogonal wavelets do not pass the default orthogonality checks 
% in ISORTHWFB.
%
% Valid options for WNAME are:
% "mb4.2"
% "mb8.2"
% "mb8.3"
% "mb8.4"
% "mb10.3"
% "mb12.3"
% "mb14.3"
% "mb16.3"
% "mb18.3"
% "mb24.3"
% "mb32.3"
%
%   %Example: Obtain the scaling and wavelet filters corresponding to the
%   %   "mb10.3" wavelet. Note that this wavelet filter does not pass the
%   %   default orthogonality check in ISORTHWFB. The filter does pass the
%   %   check with a relaxed tolerance.
%   scalf = mbscalf("mb10.3");
%   [LoD,HiD,LoR,HiR] = orthfilt(scalf);
%   [tf,checks] = isorthwfb(LoD,Tolerance=1e-7);
%
%  See also symwavf, dbwavf, modwt, modwpt, wavedec, dwpt, isorthwfb

% Morris, Joel M, and Ravindra Peravali. “Minimum-Bandwidth Discrete-Time Wavelets.”
% Signal Processing 76, no. 2 (1999): 181–93. 
% https://doi.org/10.1016/s0165-1684(99)00007-9.
%   Copyright 2021 The MathWorks, Inc.

%#codegen
narginchk(1,1);
validateattributes(wshortname,{'char','string'},{'scalartext'},...
    'mbscalf','wname');
validWav = {'mb4.2','mb8.2','mb8.4','mb8.3','mb10.3','mb12.3','mb14.3',...
    'mb16.3','mb18.3','mb24.3','mb32.3'};
coder.internal.errorIf(~any(strcmpi(wshortname,validWav)), ...
    'Wavelet:scalingfilters:InvalidMBFilter');
switch lower(wshortname)
    case 'mb4.2'
        g = [4.801755e-01
            8.372545e-01
            2.269312e-01
            -1.301477e-01];

    case 'mb8.2'

        g = [-1.673619e-1
            1.847751e-2
            5.725771e-1
            7.351331e-1
            2.947855e-1
            -1.108673e-1
            7.106015e-3
            6.436345e-2];

    case 'mb8.4'

        g = [-1.787864e-2
            9.887925e-2
            -2.049740e-1
            3.566566e-1
            8.712437e-1
            2.409542e-1
            5.871568e-2
            1.061655e-2];

    case 'mb8.3'

        g = [1.747383e-1
            7.678509e-1
            5.226249e-1
            8.270743e-2
            -2.055127e-1
            -9.446614e-2
            2.152563e-1
            -4.898544e-2];

    case 'mb10.3'

        g = [3.188392e-1
            7.169548e-1
            5.579753e-1
            -1.735427e-2
            -2.359393e-1
            -3.283228e-3
            1.172360e-1
            -1.189280e-2
            -5.100438e-2
            2.268232e-2];

    case 'mb12.3'

        g = [7.356898e-2
            2.175567e-2
            -2.041863e-1
            -9.434022e-2
            4.237179e-1
            7.418968e-1
            4.477119e-1
            1.497352e-2
            -5.097581e-2
            8.122164e-2
            1.727010e-2
            -5.840059e-2];

    case 'mb14.3'

        g = [6.960165e-2
            7.46906e-2
            -1.053585e-1
            -5.851532e-2
            4.015697e-1
            7.397584e-1
            4.872647e-1
            -2.518057e-2
            -1.458452e-1
            9.9694643e-4
            3.626539e-2
            -5.855763e-2
            -3.639085e-2
            3.390892e-2];

    case 'mb16.3'

        g = [-1.302770e-2
            2.173677e-2
            1.136116e-1
            -5.776570e-2
            -2.278359e-1
            1.188725e-1
            6.349228e-1
            6.701646e-1
            2.345342e-1
            -5.656657e-2
            -1.987986e-2
            5.474628e-2
            -2.483876e-2
            -4.984698e-2
            9.620427e-3
            5.765899e-3];

    case 'mb18.3'

        g = [2.845451e-3
            2.0621143e-3
            5.960100e-2
            4.400159e-2
            -8.004102e-2
            -1.969748e-2
            4.430378e-1
            7.57328e-1
            4.257641e-1
            -7.140818e-2
            -1.600841e-1
            3.144752e-2
            3.118641e-2
            -5.736141e-2
            -1.475223e-2
            2.011227e-2
            -4.506789e-4
            6.218698e-4];

    case 'mb24.3'

        g = [-2.132706e-5
            4.745736e-4
            7.456041e-4
            -4.879053e-3
            -1.482995e-03
            4.199576e-2
            -2.658282e-3
            -6.559513e-3
            1.019512e-1
            1.689456e-1
            1.243531e-1
            1.949147e-1
            4.581101e-1
            6.176385e-1
            2.556731e-1
            -3.091111e-1
            -3.622424e-1
            -4.575448e-3
            1.479342e-1
            1.027154e-2
            -1.644859e-2
            -2.062335e-3
            1.193006e-3
            5.361301e-5];


    case 'mb32.3'

        g = [2.934664e-9
            -4.368483e-9
            -5.813355e-8
            7.337985e-8
            2.168256e-6
            -2.967332e-6
            9.422566e-4
            -1.412518e-3
            -1.748239e-2
            2.179998e-2
            1.029296e-1
            -7.504936e-2
            -2.914947e-1
            -8.504750e-2
            4.626222e-1
            7.046699e-1
            3.963843e-1
            2.623884e-2
            5.233453e-2
            1.369482e-1
            -4.659416e-3
            -2.780765e-2
            6.851759e-3
            7.779398e-3
            -1.380539e-3
            -1.049553e-3
            5.785866e-5
            4.049514e-5
            -7.808336e-7
            -5.402846e-7
            7.777396e-9
            5.224708e-9];

    otherwise
        % This is just for codegeneration, this othewise will not be hit.
        g = [4.801755e-01
            8.372545e-01
            2.269312e-01
            -1.301477e-01];
end
scalf = g(:).';

end