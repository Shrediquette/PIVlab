function syminfo
%SYMINFO Information on near symmetric wavelets.
%
%   Symlets Wavelets
%
%   General characteristics: Compactly supported wavelets with
%   least asymmetry and highest number of vanishing moments
%   for a given support width.
%   Associated scaling filters are near linear-phase filters.
%
%   Family                  Symlets
%   Short name              sym
%   Order N                 N = 2, 3, ... 45 (a positive integer from 2
%                                             to 45)
%   Examples                sym2, sym8
%
%   Orthogonal              yes
%   Biorthogonal            yes
%   Compact support         yes
%   DWT                     possible
%   CWT                     possible
%
%   Support width           2N-1
%   Filters length          2N
%   Regularity              
%   Symmetry                near from
%   Number of vanishing 
%   moments for psi         N
%
%   Reference: I. Daubechies, 
%   Ten lectures on wavelets, 
%   CBMS, SIAM, 61, 1994, 198-202 and 254-256.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Dec-1999.
%   Copyright 1995-2021 The MathWorks, Inc.
