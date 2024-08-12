function varargout = biorfilt(Df,Rf,~)
%BIORFILT Biorthogonal wavelet filter set.
%   The BIORFILT command returns either four or eight filters
%   associated with biorthogonal wavelets.
%
%   [LO_D,HI_D,LO_R,HI_R] = BIORFILT(DF,RF) computes four
%   filters associated with biorthogonal wavelet specified
%   by decomposition filter DF and reconstruction filter RF.
%   These filters are:
%   LO_D  Decomposition low-pass filter
%   HI_D  Decomposition high-pass filter
%   LO_R  Reconstruction low-pass filter
%   HI_R  Reconstruction high-pass filter
%
%   [LO_D1,HI_D1,LO_R1,HI_R1,LO_D2,HI_D2,LO_R2,HI_R2] = 
%                       BIORFILT(DF,RF,'8')
%   returns eight filters, the first four associated with
%   the decomposition wavelet and the last four associated
%   with the reconstruction wavelet.
%
%   See also BIORWAVF, ORTHFILT.

%   Copyright 1995-2021 The MathWorks, Inc.

%#codegen

% The filters must be of the same even length.
if iscolumn(Df)
    Dfrow = Df(:).';
else
    Dfrow = Df;
end
if iscolumn(Rf)
    Rfrow = Rf(:).';
else
    Rfrow = Rf;
end
lr = length(Rfrow);
ld = length(Dfrow);
lmax = max(lr,ld);
if signalwavelet.internal.isodd(lmax) 
    lmax = lmax+1; 
end

Rfextend = [zeros(1,floor((lmax-lr)/2),'like',Dfrow) Rfrow zeros(1,ceil((lmax-lr)/2),'like',Dfrow)];
Dfextend = [zeros(1,floor((lmax-ld)/2),'like',Dfrow) Dfrow zeros(1,ceil((lmax-ld)/2),'like',Dfrow)];

[Lo_D1,Hi_D1,Lo_R1,Hi_R1] = orthfilt(Dfextend);
[Lo_D2,Hi_D2,Lo_R2,Hi_R2] = orthfilt(Rfextend);
switch nargin
  case 2 
      varargout = {Lo_D1,Hi_D2,Lo_R2,Hi_R1};
  case 3 
      varargout = {Lo_D1,Hi_D1,Lo_R1,Hi_R1,Lo_D2,Hi_D2,Lo_R2,Hi_R2};
end
