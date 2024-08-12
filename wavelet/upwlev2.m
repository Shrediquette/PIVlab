function [Nc,Ns,a] = upwlev2(c,s,IN3,IN4)
%UPWLEV2 Single-level reconstruction of 2-D wavelet decomposition.
%   [NC,NS,CA] = UPWLEV2(C,S,'wname') performs the single-level
%   reconstruction of wavelet decomposition structure 
%   [C,S] giving the new one [NC,NS], and extracts the last
%   approximation coefficients matrix CA.
%
%   [C,S] is a decomposition at level n = size(S,1)-2, so
%   [NC,NS] is the same decomposition at level n-1 and CA 
%   is the approximation matrix at level n.
%
%   'wname' is a string containing the wavelet name,
%   C is the original wavelet decomposition vector and
%   S the corresponding bookkeeping matrix (for 
%   detailed storage information, see WAVEDEC2).
%
%   Instead of giving the wavelet name, you can give the
%   filters.
%   For [NC,NS,CA] = UPWLEV2(C,S,Lo_R,Hi_R),
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter.
%
%   NOTE: If C and S are obtained from an indexed image analysis
%   (respectively a truecolor image analysis) then CA is an
%   m-by-n matrix (respectively an m-by-n-by-3 array).
%   So the sizes of the vector NC and the matrix NS depend on
%   the analyzed image format.
%   For more information on image formats, see the reference
%   pages of IMAGE and IMFINFO functions.
%
%   See also IDWT2, UPCOEF2, WAVEDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if nargin > 2 && isStringScalar(IN3)
    IN3 = convertStringsToChars(IN3);
end

if nargin == 3
    [Lo_R,Hi_R] = wfilters(IN3,'r');
else
    Lo_R = IN3;
	Hi_R = IN4;
end
[ns,dim] = size(s);
if dim==2 
    dim = 1;
end

% Extract last approximation.
nr   = s(1,1);
nc   = s(1,2);
last = nr*nc*dim;
a    = reshape(c(1:last),nr,nc,dim);

% One step reconstruction of the wavelet decomposition structure.
if ns>2
    s2 = s(2,:);
    s3 = s(3,:);
    Ns = [s3 ;s(3:ns,:)];
    nr = s2(1,1); nc = s2(1,2); nb = nr*nc*dim;    
    first = last+1; last = last+nb;
    h     = reshape(c(first:last),nr,nc,dim);
    first = last+1; last = last+nb;
    v     = reshape(c(first:last),nr,nc,dim);
    first = last+1; last = last+nb;
    d     = reshape(c(first:last),nr,nc,dim);
    ra = idwt2(a,h,v,d,Lo_R,Hi_R,s3);
    Nc = [ra(:)' c(last+1:end)];
else
    Ns = [];
    Nc = [];
end
