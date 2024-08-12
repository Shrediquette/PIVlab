function rbioinfo
%RBIOINFO Information on reverse biorthogonal spline wavelets.
%
%   Reverse Biorthogonal Wavelets
%
%   General characteristics: Compactly supported 
%   biorthogonal spline wavelets for which 
%   symmetry and exact reconstruction are possible
%   with FIR filters (in orthogonal case it is 
%   impossible except for Haar).
%
%   Family                  Biorthogonal
%   Short name              rbio
%   Order Nd,Nr             Nd = 1 , Nr = 1, 3, 5
%   r for reconstruction    Nd = 2 , Nr = 2, 4, 6, 8
%   d for decomposition     Nd = 3 , Nr = 1, 3, 5, 7, 9
%                           Nd = 4 , Nr = 4
%                           Nd = 5 , Nr = 5
%                           Nd = 6 , Nr = 8
%
%   Examples                rbio3.1, rbio5.5
%
%   Orthogonal              no
%   Biorthogonal            yes
%   Compact support         yes
%   DWT                     possible
%   CWT                     possible
%
%   Support width           2Nd+1 for rec., 2Nr+1 for dec.
%   Filters length          max(2Nd,2Nr)+2 but essentially
%   rbio Nd.Nr              lr                      ld
%                     effective length        effective length
%                       of Hi_D                  of Lo_D
%
%   rbio 1.1                 2                       2
%   rbio 1.3                 6                       2
%   rbio 1.5                10                       2
%   rbio 2.2                 5                       3
%   rbio 2.4                 9                       3
%   rbio 2.6                13                       3
%   rbio 2.8                17                       3
%   rbio 3.1                 4                       4
%   rbio 3.3                 8                       4
%   rbio 3.5                12                       4
%   rbio 3.7                16                       4
%   rbio 3.9                20                       4
%   rbio 4.4                 9                       7
%   rbio 5.5                 9                      11
%   rbio 6.8                17                      11
%
%   Regularity for          
%   psi rec.                Nd-1 and Nd-2 at the knots
%   Symmetry                yes  
%   Number of vanishing 
%   moments for psi dec.    Nd
%
%   Remark: rbio 4.4 , 5.5 and 6.8 are such that reconstruction and 
%   decomposition functions and filters are close in value.           
%
%   Reference: I. Daubechies, 
%   Ten lectures on wavelets, 
%   CBMS, SIAM, 61, 1994, 271-280.
%
%   See Information on biorthogonal spline wavelets.   

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-1998.
%   Last Revision: 09-Nov-2001.
%   Copyright 1995-2021 The MathWorks, Inc.
