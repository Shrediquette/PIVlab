function w = symaux(N,sumw)
%SYMAUX Symlet wavelet filter computation.
%   Symlets are the "least asymmetric"
%   Daubechies' wavelets.
%   W = SYMAUX(N,SUMW) is the order N Symlet scaling
%   filter such that SUM(W) = SUMW.
%   Possible values for N are:
%          N = 1, 2, 3, ...
%   Caution: Instability may occur when N is too large.
%
%   W = SYMAUX(N) is equivalent to W = SYMAUX(N,1)
%   W = SYMAUX(N,0) is equivalent to W = SYMAUX(N,1)
%
%   See also SYMWAVF, WFILTERS.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-Feb-98.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if nargin < 2 || sumw==0 , sumw = 1;  end

if N==1  % Haar filters
    w = [0.5 0.5];
    w = sumw*(w/sum(w)); 
    return
end

% Compute the "Lagrange a trous" filter of order N.
% and the roots (abs(R) ~= 1).
%--------------------------------------------------
[~,Proots] = wlagrang(N);

% Find complex and real zeros.
% The real zeros are grouped by duplets:
%   [z,1/z]
% The complex zeros are grouped by quadruplets: 
%   [z,conj(z),1/z,1/conj(z)]
%------------------------------------------------ 
realzeros   = Proots(imag(Proots)==0);
nbrealzeros = length(realzeros);
imagzeros   = Proots(imag(Proots)~=0);
nbimagzeros = length(imagzeros);

% Get complex modulus and angle for each group of complex zeros.
tmp  = imagzeros(1:2:nbimagzeros/2);
rho  = abs(tmp);
teta = angle(tmp);

%--------------------------------------------------------------
% Calculate phase contribution of complex and real zeros
% for all the combination of these zeros.
% A combination is composed by one real zero in each duplets
% and two conjugate complex zeros in each quadruplets.
% Each combination of zeros is identified with a binary number.
% The phase of kth combination is the opposite of the phase
% of the combination which num is (2^NbGroup-k+1). 
%--------------------------------------------------------------
nbfr = 200;
freq = linspace(0,2*pi,nbfr);
uZ   = exp(-1i*freq);
nbGroupOfRealZ = nbrealzeros/2;
nbGroupOfImagZ = nbimagzeros/4;
nbGroupOfZeros = nbGroupOfImagZ+nbGroupOfRealZ;
pow2NbGroup    = 2^(nbGroupOfZeros-1);   
indImagZ       = [1:nbGroupOfImagZ];
indRealZ       = [nbGroupOfImagZ+1:nbGroupOfZeros];
phas           = zeros(pow2NbGroup,nbfr);
for numG=1:pow2NbGroup
    [indReZ,indImZ] = getZeroInd(numG,nbGroupOfZeros,nbGroupOfRealZ, ...
                        indRealZ,indImagZ);
    tmp = realzeros(indReZ);
    for ii=1:nbGroupOfRealZ
        phas(numG,:) = phas(numG,:) + phasecontrib(uZ,tmp(ii));
    end                             
    tmp = rho;
    tmp(indImZ) = 1./tmp(indImZ);
    for ii=1:nbGroupOfImagZ       
        phas(numG,:) = phas(numG,:) + phasecontrib(uZ,tmp(ii),teta(ii));
    end
end

% To retain only the non linear part of the phase.
phas = nonlinph(phas,freq);

% We select the combination which phase is closer to zero
% (The L2-norm or variance of the phase is minimum).
phas = sum(phas'.^2);
[~,imin]  = min(phas);
%-----------------------------------------------------
% The following choice is only for compatibility 
% with load symN
switch N
   case {4,5,7,8} , imin = 2*pow2NbGroup-imin+1;
end
%-----------------------------------------------------

[indReZ,indImZ] = getZeroInd(imin,nbGroupOfZeros,nbGroupOfRealZ, ...
                        indRealZ,indImagZ);
% Choose real zeros.
realzeros = realzeros(indReZ);

% Choose imaginary zeros.
tmp = rho;
tmp(indImZ) = 1./tmp(indImZ);
tmp = tmp.*exp(1i*teta);
tmp = [tmp conj(tmp)]';
imagzeros = tmp(:);

% Construction of the filter from its zeros.
w = real(poly([realzeros;imagzeros;-ones(N,1)]));
w = sumw*(w/sum(w)); 

%-----------------------------------------------------------------------%
function [iReZ,iImZ] = getZeroInd(num,nbGrZ,nbGrReZ,indReZ,indImZ) 
% Get indices of zeros for a group which number is num.

bin  = dec2bin(num-1,nbGrZ);
bin  = logical(str2num(bin')');
iReZ = [1:2:2*nbGrReZ]+bin(indReZ);
iImZ = bin(indImZ);
%-----------------------------------------------------------------------%
function F = phasecontrib(Z,R,teta)
%PHASECONTRIB  
%   F = PHASECONTRIB(Z,R,TETA) or F = PHASECONTRIB(Z,R)
%   returns the phase contribution of a complex pair of zeros
%   or of a real zero.

switch nargin
  case 2 , V = Z-R;                                   % real case
  case 3 , V = (Z-R*exp(1i*teta)).*(Z-R*exp(-1i*teta)); % imaginary case
end

% Compute continuous phase over the pi-borders.
F  = atan2(imag(V),real(V));
N  = length(F);
DF = F(1:N-1)-F(2:N);
I  = find(abs(DF)>3.5);
for ii=I
     F = F+2*pi*sign(DF(ii))*[zeros(1,ii) ones(1,N-ii)];
end
F = F-F(1);
%-----------------------------------------------------------------------%
function nlphase = nonlinph(v,freq)
%NONLINPH NLPHASE = NONLINPH(V) eliminates the linear 
% part of the phase vector V.

[m,n] = size(v);
nlphase = zeros(m,n);
for row=1:m
    nlphase(row,:) = v(row,:)-v(row,n)*freq/(2*pi);
end
%-----------------------------------------------------------------------%
