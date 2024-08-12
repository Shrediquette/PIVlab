function fbspinfo
%FBSPINFO Information on complex Frequency B-Spline wavelet.
%
%   Complex Frequency B-Spline Wavelet
%
%   Definition: a complex Frequency B-Spline wavelet is
%       fbsp(x) = Fb^{0.5}*(sinc(Fb*x/M))^M *exp(2*i*pi*Fc*x)
%   depending on three parameters:
%           M is an integer order parameter (>=1)
%           Fb is a bandwidth parameter
%           Fc is a wavelet center frequency
%
%   For M = 1, the condition Fc > Fb/2 is sufficient to ensure
%   that zero is not in the frequency support interval.
%
%   Family                  Complex Frequency B-Spline
%   Short name              fbsp
%
%   Wavelet name            fbsp"M"-"Fb"-"Fc"
%
%   Orthogonal              no
%   Biorthogonal            no
%   Compact support         no
%   DWT                     no
%   complex CWT             possible
%
%   Support width           infinite
%
%   Reference: A. Teolis, 
%   Computational signal processing with wavelets, 
%   Birkhauser, 1998, 63.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Jun-99.
%   Last Revision: 05-Jun-2003.
%   Copyright 1995-2021 The MathWorks, Inc.
