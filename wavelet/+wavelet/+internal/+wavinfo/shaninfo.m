function shaninfo
%SHANINFO Information on complex Shannon wavelet.
%
%   Complex Shannon Wavelet
%
%   Definition: a complex Shannon wavelet is
%           shan(x) = Fb^{0.5}*sinc(Fb*x)*exp(2*i*pi*Fc*x)
%   depending on two parameters:
%           Fb is a bandwidth parameter
%           Fc is a wavelet center frequency
%
%   The condition Fc > Fb/2 is sufficient to ensure that
%   zero is not in the frequency support interval.
%
%   Family                  Complex Shannon
%   Short name              shan
%
%   Wavelet name            shan"Fb"-"Fc"
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
%   Birkhauser, 1998, 62.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Jun-99.
%   Last Revision: 05-Jun-2003.
%   Copyright 1995-2021 The MathWorks, Inc.
