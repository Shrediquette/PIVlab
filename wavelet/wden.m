function [xd,cxd,lxd,thrs] = wden(in1,in2,in3,in4,in5,in6,in7)
%WDEN Automatic 1-D denoising using wavelets.
%   XD = WDEN(X,TPTR,SORH,SCAL,N,WNAME) returns a denoised version XD
%   of the input signal X obtained by thresholding the wavelet
%   coefficients.
%   TPTR is the threshold selection rule specified as a string. Supported
%   options for TPTR are:
%   'modwtsqtwolog' uses the maximal overlap discrete wavelet
%   transform (MODWT) to denoise the signal with Donoho and Johnstone's
%   universal threshold and level-dependent thresholding.
%   The remaining TPTR options use the critically sampled DWT to denoise the
%   signal:
%   'rigrsure' uses the principle of Stein's Unbiased Risk.
%   'heursure' is a heuristic variant of Stein's Unbiased Risk.
%   'sqtwolog' uses Donoho and Johnstone's universal threshold with the
%   DWT.
%   'minimaxi' uses minimax thresholding.
%
%   SORH specifies soft or hard thresholding with 's' or 'h'.
%   SCAL defines the type of threshold rescaling:
%   'one' for no rescaling.
%   'sln' for rescaling using a noise estimate based on the first-level
%   coefficients.
%   'mln' for rescaling using level-dependent estimates of the noise.
%   'mln' is the only option supported for MODWT denoising.
%
%   N is the level of the wavelet transform and WNAME is the wavelet
%   specified as a string. For MODWT denoising, WNAME must correspond to an
%   orthogonal wavelet.
%
%   XD = wden(C,L,TPTR,SORH,SCAL,N,WNAME) returns the denoised
%   signal obtained by operating on the DWT coefficient vector C and number
%   of DWT coefficients by level L. C and L are outputs of WAVEDEC. You
%   must use the same wavelet in both WAVEDEC and WDEN.
%
%   XD = wden(W,'modwtsqtwolog',SORH,'mln',N,WNAME) returns the
%   denoised signal obtained by operating on the MODWT transform matrix W.
%   W is the output of MODWT. You must use the same wavelet in both
%   MODWT and WDEN.
%
%   [XD,CXD] = WDEN(...) returns the denoised wavelet coefficients. For
%   DWT denoising, CXD is a vector (see WAVEDEC). For MODWT denoising, CXD
%   is a matrix with N+1 rows (see MODWT). The number of columns is equal
%   to the length of the input signal X.
%
%   [XD,CXD,LXD] = WDEN(...) returns the number of coefficients by level
%   for DWT denoising. See the help for WAVEDEC for details. The LXD output
%   is not supported for MODWT denoising.
%
%   [XD,CXD,LXD,THR] = WDEN(...) returns the denoising thresholds by level
%   for DWT denosing.
%
%   [XD,CXD,THR] = WDEN(...) returns the denoising thresholds by level for
%   MODWT denoising when you specify 'modwtsqtwolog'.
%
%   %Example 1:
%   %   Denoise a signal consisting of a 2-Hz sine wave with transients
%   %   at 0.3 and 0.72 seconds. Use Donoho and Johnstone's universal
%   %   threshold with level-dependent estimation of the noise.
%   %   Obtain denoised versions using the DWT and MODWT. Compare the
%   %   results.
%   N = 1000;
%   t = linspace(0,1,N);
%   x = 4*sin(4*pi*t);
%   x = x - sign(t - .3) - sign(.72 - t);
%   y = x+0.15*randn(size(t));
%   xdDWT = wden(y,'sqtwolog','s','mln',3,'db2');
%   xdMODWT = wden(y,'modwtsqtwolog','s','mln',3,'db2');
%   subplot(2,1,1)
%   plot(xdDWT), title('DWT Denoising'); axis tight;
%   subplot(2,1,2)
%   plot(xdMODWT), title('MODWT Denoising'); axis tight;
%
%   %Example 2:
%   %   Denoise a blocky signal using the Haar wavelet with MODWT and DWT
%   %   denoising. Compare the L2 and L-infty norms of the difference
%   %   between the original signal and the denoised versions.
%   [x,xn] = wnoise('blocks',10,3);
%   xdMODWT = wden(xn,'modwtsqtwolog','s','mln',6,'haar');
%   xd = wden(xn,'sqtwolog','s','mln',6,'haar');
%   plot(x)
%   hold on
%   plot(xd,'r--')
%   plot(xdMODWT,'k-.')
%   legend('Original','DWT','MODWT')
%   hold off
%   norm(abs(x-xd),2), norm(abs(x-xd),Inf)
%   norm(abs(x-xdMODWT),2), norm(abs(x-xdMODWT),Inf)
%
%   See also THSELECT, MODWT, WAVEDEC, WDENCMP, WFILTERS, WTHRESH.

%   Copyright 1995-2020 The MathWorks, Inc.

% Convert any strings to char arrays
if nargin > 1 && isStringScalar(in2)
    in2 = convertStringsToChars(in2);
end

if nargin > 2 && isStringScalar(in3)
    in3 = convertStringsToChars(in3);
end

if nargin > 3 && isStringScalar(in4)
    in4 = convertStringsToChars(in4);
end

if nargin > 4 && isStringScalar(in5)
    in5 = convertStringsToChars(in5);
end

if nargin > 5 && isStringScalar(in6)
    in6 = convertStringsToChars(in6);
end

if nargin > 6 && isStringScalar(in7)
    in7 = convertStringsToChars(in7);
end

nargoutchk(0,4);
nbIn = nargin;
switch nbIn
    case {0,1,2,3,4,5}
        error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
    case 6
        x = in1; tptr = in2; sorh = in3;
        scal = in4; n = in5; w = in6;
    case 7
        c = in1; l = in2; tptr = in3;
        sorh = in4; scal = in5; n = in6; w = in7;
end
if errargt(mfilename,tptr,'str')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
if errargt(mfilename,sorh,'str')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
if errargt(mfilename,scal,'str')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
if errargt(mfilename,n,'int')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
if errargt(mfilename,w,'str')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

% Adding MODWT denoising
if strcmpi(tptr,'modwtsqtwolog')
    if nargout>3
        error(message('Wavelet:modwt:TooManyOutputs'));
    end
    [xd,cxd,lxd] = modwtdenoise1D(x,w,n,sorh,scal);
    return;
end

if nbIn==6
    % Wavelet decomposition of x.
    [c,l] = wavedec(x,n,w);
end

% Threshold rescaling coefficients.
switch scal
    case 'one' , s = ones(1,n);
    case 'sln' , s = ones(1,n)*wnoisest(c,l,1);
    case 'mln' , s = wnoisest(c,l,1:n);
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

% Wavelet coefficients thresholding.
first = cumsum(l)+1;
first = first(end-2:-1:1);
ld   = l(end-1:-1:2);
last = first+ld-1;
cxd = c;
lxd = l;
if iscolumn(c)
    thrs = zeros(n,1);
else
    thrs = zeros(1,n);
end
for k = 1:n
    flk = first(k):last(k);
    if strcmp(tptr,'sqtwolog') || strcmp(tptr,'minimaxi')
        thr = thselect(c,tptr);
    else
        if s(k) < sqrt(eps) * max(c(flk))
            thr = 0;
        else
            thr = thselect(c(flk)/s(k),tptr);
        end
    end                                     % threshold.
    thrs(k)      = thr * s(k);                  % rescaled threshold.
    cxd(flk) = wthresh(c(flk),sorh,thrs(k));    % thresholding or shrinking.
end

% Wavelet reconstruction of xd.
xd = waverec(cxd,lxd,w);
