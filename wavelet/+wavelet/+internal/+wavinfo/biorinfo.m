function biorinfo
%BIORINFO Information on biorthogonal spline wavelets.
%
%   Biorthogonal Wavelets
%
%   General characteristics: Compactly supported 
%   biorthogonal spline wavelets for which 
%   symmetry and exact reconstruction are possible
%   with FIR filters (in orthogonal case it is 
%   impossible except for Haar).
%
%   Family                  Biorthogonal
%   Short name              bior
%   Order Nr,Nd             Nr = 1 , Nd = 1, 3, 5
%   r for reconstruction    Nr = 2 , Nd = 2, 4, 6, 8
%   d for decomposition     Nr = 3 , Nd = 1, 3, 5, 7, 9
%                           Nr = 4 , Nd = 4
%                           Nr = 5 , Nd = 5
%                           Nr = 6 , Nd = 8
%
%   Examples                bior3.1, bior5.5
%
%   Orthogonal              no
%   Biorthogonal            yes
%   Compact support         yes
%   DWT                     possible
%   CWT                     possible
%
%   Support width           2Nr+1 for rec., 2Nd+1 for dec.
%   Filters length          max(2Nr,2Nd)+2 but essentially
%   bior Nr.Nd              ld                      lr      
%                    effective length        effective length
%                        of Lo_D                 of Hi_D
%
%   bior 1.1                 2                       2      
%   bior 1.3                 6                       2
%   bior 1.5                10                       2              
%   bior 2.2                 5                       3              
%   bior 2.4                 9                       3      
%   bior 2.6                13                       3              
%   bior 2.8                17                       3              
%   bior 3.1                 4                       4              
%   bior 3.3                 8                       4              
%   bior 3.5                12                       4
%   bior 3.7                16                       4
%   bior 3.9                20                       4
%   bior 4.4                 9                       7
%   bior 5.5                 9                      11
%   bior 6.8                17                      11
%
%   Regularity for          
%   psi rec.                Nr-1 and Nr-2 at the knots
%   Symmetry                yes  
%   Number of vanishing 
%   moments for psi dec.    Nr
%
%   Remark: bior 4.4 , 5.5 and 6.8 are such that reconstruction and 
%   decomposition functions and filters are close in value.           
%
%   Reference: I. Daubechies, 
%   Ten lectures on wavelets, 
%   CBMS, SIAM, 61, 1994, 271-280.
%
%   See Information on reverse biorthogonal spline wavelets.   

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 08-Oct-1999.
%   Copyright 1995-2021 The MathWorks, Inc.
