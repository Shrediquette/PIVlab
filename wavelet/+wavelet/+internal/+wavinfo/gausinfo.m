function gausinfo
%GAUSINFO Information on Gaussian wavelets.
%
%   Gaussian Wavelets
%
%   Definition: derivatives of the Gaussian 
%   probability density function.
%
%   gaus(x,n) = Cn * diff(exp(-x^2),n) where diff denotes 
%   the symbolic derivative and where Cn is such that 
%   the 2-norm of gaus(x,n) = 1.
%
%   Family                  Gaussian
%   Short name              gaus
%
%   Wavelet name            'gausN'  Valid choices for N are 1,2,3,...8
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
%                       n even ==> Symmetry
%                       n odd  ==> Anti-Symmetry

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Nov-97.
%   Last Revision: 15-Jul-1999.
%   Copyright 1995-2021 The MathWorks, Inc.
