function cwtftinfo
%CWTFTINFO Information on wavelets for CWTFT
% CWTFTINFO provides information on the available wavelets for 
% Continuous Wavelet Transform using FFT.
%
%   PSI_HAT denotes the Fourier transform of the wavelet.
%
%   Morlet: 
%     'morl':
%       PSI_HAT(k) = pi^(-1/4)exp(-(k-k0)^2/2)H(k) where H(k) is the
%       Heaviside function.
%       Parameter: k0, default k0 = 6. 
%       k0 is the center frequency in radians/sample. The center frequency 
%       cycles/sample is k0/(2*pi).       
%
%     'morlex': (without Heaviside function)
%       PSI_HAT(k) = pi^(-1/4)exp(-(k-k0)^2/2)
%       Parameter: k0, default k0 = 6. 
%       k0 is the center frequency in radians/sample. The center frequency 
%       in cycles/sample is k0/(2*pi).
%
%     'morl0':  (with exact zero mean value)
%       PSI_HAT(k) = pi^(-1/4) [exp(-(k-k0)^2/2) - exp(k0^2/2)]
%       Parameter: k0, default k0 = 6. 
%       k0 is the center frequency in
%       radians/sample. The center frequency in cycles/sample is
%       k0/(2*pi).
%
%   DOG:  
%     'dog': m order Derivative Of Gaussian 
%       PSI_HAT(k) = -(i^m/sqrt(gamma(m+0.5)))(k^m)exp(-k^2/2)
%       Parameter: m (order of derivative), default m = 2. The order
%       m must be even.
%       sqrt(m+1/2) is the approximate center frequency in radians/sample.
%       The center frequency cycles/sample is sqrt(m+1/2)/(2*pi).
%                  
%     'mexh':
%       PSI_HAT(k) = (1/gamma(2+0.5))k^2 exp(-k^2/2)
%       (DOG wavelet with m = 2)
%       sqrt(5/2) is the approximate center frequency in radians/sample.
%       The center frequency is cycles/sample is sqrt(5/2)/(2*pi).
%
%   Paul:
%     'paul':
%       PSI_HAT(k) = (2^m)/sqrt(m(2*m-1)!)k^m exp(-k) Parameter: m,
%       default m = 4. m+1/2 is the approximate center frequency in
%       radians/sample. (m+1/2)/(2*pi) is the center frequency
%       in cycles/sample.
%
%   Bump:
%       'bump'
%       PSI_HAT(k) = exp(1-(1/(1-(k-mu)^2/sigma^2)))(abs((k-mu)/sigma)<1)
%       Parameters: mu,sigma. default:    mu=5, sigma = 0.6.
%       Allowable parameter ranges:  3 <= mu <= 6
%                                    0.1 < sigma <1.2
%       Note that mu-sigma is strictly positive.
%       mu is the center frequency in radians/sample. The center frequency
%       in cycles/sample is mu/(2*pi).
%      
%       
%
%   See also CWTFT, CWT, ICWTFT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 04-Mar-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

help cwtftinfo
