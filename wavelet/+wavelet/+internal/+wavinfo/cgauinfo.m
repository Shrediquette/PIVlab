function cgauinfo
%CGAUINFO Information on complex Gaussian wavelets.
%
%   Complex Gaussian Wavelets.
%
%   Definition: derivatives of the complex Gaussian 
%   function
%
%   cgau(x) = Cn * diff(exp(-i*x)*exp(-x^2),n) where diff denotes
%   the symbolic derivative and where Cn is a constant
%
%   Family                  Complex Gaussian
%   Short name              cgau
%
%   Wavelet name            'cgauN' Valid choices for N are 1,2,3,...8
%
%   Orthogonal              no
%   Biorthogonal            no
%   Compact support         no
%   DWT                     no
%   Complex CWT             possible
%
%   Support width           infinite
%   Symmetry                yes
%                       n even ==> Symmetry
%                       n odd  ==> Anti-Symmetry

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jul-99.
%   Last Revision: 05-Jul-1999.
%   Copyright 1995-2021 The MathWorks, Inc.
