function [c,l,a] = upwlev(c,l,IN3,IN4)
%UPWLEV Single-level reconstruction of 1-D wavelet decomposition.
%   [NC,NL,CA] = UPWLEV(C,L,'wname') performs the single-level
%   reconstruction of the wavelet decomposition structure
%   [C,L] giving the new one [NC,NL], and extracts the last
%   approximation coefficients vector CA.
%
%   [C,L] is a decomposition at level n = length(L)-2, so
%   [NC,NL] is the same decomposition at level n-1 and CA 
%   is the approximation coefficients vector at level n.
%
%   'wname' is a string containing the wavelet name,
%   C is the original wavelet decomposition vector and
%   L the corresponding bookkeeping vector (for 
%   detailed storage information, see WAVEDEC).
%
%   Instead of giving the wavelet name, you can give the
%   filters.
%   For [NC,NL,CA] = UPWLEV(C,L,Lo_R,Hi_R),
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter.
%
%   See also IDWT, UPCOEF, WAVEDEC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if nargin > 2
    IN3 = convertStringsToChars(IN3);
end

if nargin == 3
    [Lo_R,Hi_R] = wfilters(IN3,'r');
else
    Lo_R = IN3; Hi_R = IN4;
end

% Extract last approximation.
ll = length(l);
l1 = l(1);
a  = c(1:l1);

% One step reconstruction of the wavelet decomposition structure.
if ll > 2
    l2 = l(2);
    l3 = l(3);
    l  = l(2:ll); l(1) = l3;

    d  = c(l1+1:l1+l2);
    ra = idwt(a,d,Lo_R,Hi_R,l3);
    c  = c(l1+l2+1-l3:end);
    c(1:l3) = ra;
else
    l = [];
    c = [];
end
