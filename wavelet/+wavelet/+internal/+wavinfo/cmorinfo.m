function cmorinfo
%CMORINFO Information on complex Morlet wavelet.
%
%   Complex Morlet Wavelet
%
%   Definition: a complex Morlet wavelet is
%       cmor(x) = (pi*Fb)^{-0.5}*exp(2*i*pi*Fc*x)*exp(-(x^2)/Fb)
%   depending on two parameters:
%       Fb is a bandwidth parameter
%       Fc is a wavelet center frequency
%
%   Family                  Complex Morlet
%   Short name              cmor
%
%   Wavelet name            cmor"Fb"-"Fc"
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
%   Birkhauser, 1998, 65.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Jun-99.
%   Last Revision: 08-Jul-1999.
%   Copyright 1995-2021 The MathWorks, Inc.

