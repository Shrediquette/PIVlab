function [xhat,omega] = nstdfft(x,lowb,uppb)
%NSTDFFT Non-standard 1-D fast Fourier transform.
%   [XHAT,OMEGA] = NSTDFFT(X,LOWB,UPPB) returns a
%   nonstandard FFT of signal X sampled on a power-of-2
%   regular grid (non necessarily integers) on the
%   interval [LOWB,UPPB].
%
%   Output arguments are XHAT the shifted FFT of X
%   computed on the interval OMEGA given by
%   OMEGA = [-n:2:n-2]/(2*(UPPB-LOWB)) where n is the
%   length of X. Outputs are vectors of length n.
%
%   Length of X must be a power of 2.
%
%   See also FFT, FFTSHIFT, INSTDFFT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
n = length(x);
if errargt(mfilename,log(n)/log(2),'int')
    error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
if errargt(mfilename,uppb-lowb,'re0')
    error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end

% Time grid resolution.
delta = (uppb-lowb)/n;

% Frequency grid.
omega = (-n:2:n-2)/(2*n*delta);

% Compute non standard fft.
xhat = delta*exp(-2*pi*1i*omega*lowb).*fftshift(fft(x));
