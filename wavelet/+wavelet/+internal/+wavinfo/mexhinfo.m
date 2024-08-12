function mexhinfo
%MEXHINFO Information on Mexican Hat wavelet.
%
%   Mexican Hat Wavelet
%
%   Definition: second derivative of the Gaussian 
%   probability density function
%
%   mexh(x) = c * exp(-x^2/2) * (1-x^2)
%   where c = 2/(sqrt(3)*pi^{1/4}) 
%
%   Family                  Mexican hat
%   Short name              mexh
%
%   Orthogonal              no
%   Biorthogonal            no
%   Compact support         no
%   DWT                     no
%   CWT                     possible
%
%   Support width           infinite
%   Effective support       [-5 5]
%   Symmetry                yes
%
%   Reference: I. Daubechies, 
%   Ten lectures on wavelets, 
%   CBMS, SIAM, 61, 1994, 75.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 01-May-1998.
%   Copyright 1995-2021 The MathWorks, Inc.
