function [x,t] = instdfft(xhat,lowb,uppb)
%INSTDFFT Inverse non-standard 1-D fast Fourier transform.
%   [X,T] = INSTDFFT(XHAT,LOWB,UPPB) returns the inverse
%   nonstandard FFT of XHAT, on a power-of-2 regular
%   grid (non necessarily integers) on the interval
%   [LOWB,UPPB].
%   Output arguments are X the recovered signal computed
%   on the time interval T given by
%   T = LOWB + [0:n-1]*(UPPB-LOWB)/n, where n is the
%   length of XHAT. Outputs are vectors of length n.
%
%   The length of XHAT must be a power of 2.
%
%   See also FFT, IFFT, NSTDFFT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
n = length(xhat);
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

% Transform back xhat to standard fft form.
xhat = fftshift(xhat.*exp(2*pi*1i*omega*lowb)/delta);

% Compute standard ifft.
x = ifft(xhat);

% Remove small imaginary parts.
sim = find(imag(x) < sqrt(eps));
if ~isempty(sim), x(sim) = real(x(sim)); end

% Time grid.
t = lowb + (0:n-1)*delta;
