function [LoDz,HiDz,LoRz,HiRz,PRCond,AACond] = filters2lp(Lo,varargin)
%FILTERS2LP Filters to Laurent polynomials.
%   [LoDz,HiDz] = FILTERS2LP(Lo) returns the Laurent polynomials that
%   correspond to the z-transform of the lowpass and highpass analysis
%   filters associated with the lowpass filter specified in the cell array
%   Lo. The Laurent polynomials LoDz and HiDz correspond to the lowpass and
%   highpass analysis filters, respectively.
%
%   If the wavelet is orthogonal, then Lo is a one-element cell array that
%   corresponds to LoR. The corresponding highpass filter is HiR = qmf(LoR).
%   For biorthogonal wavelets, Lo is a two-element cell array specified as
%   Lo = {LoR, LoD}. In this case, HiR = qmf(fliplr(LoD)).
%
%   [LoDz,HiDz,LoRz,HiRz] = FILTERS2LP(Lo) returns the Laurent polynomials
%   that correspond to the z-transform of the synthesis filters associated
%   with the lowpass filter specified in the cell array Lo. The Laurent
%   polynomials LoRz and HiRz correspond to the lowpass and highpass
%   synthesis filters respectively.
% 
%   [...,PRCond,AACond] = FILTERS2LP(Lo) returns the perfect reconstruction
%   condition PRCond and the anti-aliasing condition AACond. PRCond and
%   AACond are Laurent polynomials. The conditions are as follows:
%      PRCond(z) = LoRz(z) * LoDz(z)  + HiRz(z) * HiDz(z)
%      AACond(z) = LoRz(z) * LoDz(-z) + HiRz(z) * HiDz(-z)
%
%   The pairs (LoRz,HiRz) and (LoDz,HiDz) are associated with perfect
%   reconstruction filters if and only if:
%      PRCond(z) = 2 and AACond(z) = 0.
%
%   If PRCond(z) = 2 * z^d, a delay is introduced in the reconstruction
%   process.
%
%   [...] = FILTERS2LP(...,PmaxLoRz) specifies the maximum power of LoRz.
%   PmaxLoRz must be an integer (default 0).
%
%   [...] = FILTERS2LP(...,AddPOW) sets the maximum order of the Laurent
%   polynomial HiRz such that 
%       PmaxHiRz = PmaxLoRz + length(HiRz.Coefficients) - 2 + AddPOW,
%   where 
%       PmaxHiRz is the maximum order of the Laurent polynomial HiRz,
%       PmaxLoRz is the maximum order of the Laurent polynomial LoRz,
%       AddPOW is an integer (default is 0).
%   Note that AddPOW must be an even integer to preserve the perfect
%   reconstruction condition.
%
%   % Example: Obtain the Laurent polynomials that correspond to the  
%   %   lowpass filters LoR and LoD for the bior2.2 wavelet.
%   [LoD,~,LoR,~] = wfilters('bior2.2');
%   [LoDz,HiDz,LoRz,HiRz] = filters2lp({LoR,LoD}); 
%
%   See also wave2lp, laurentPolynomial, laurentMatrix, lp2filters.

%   Copyright 1995-2021 The MathWorks, Inc.

%#codegen

% Check input arguments.
narginchk(1,4);
PmaxLoRz = 0; 
AddPOW = 0; 
qmfFLAG = 0;

nbIn = length(varargin);

switch nbIn
    case 1
        PmaxLoRz = varargin{1};
        
    case 2
        PmaxLoRz = varargin{1};
        AddPOW = varargin{2};
        
    case 3
        PmaxLoRz = varargin{1};
        AddPOW = varargin{2};
        qmfFLAG = varargin{3};
end

LoR2 = Lo{1};

if (numel(Lo) == 1)
    HiR = qmf(LoR2,qmfFLAG);
else
    HiR = qmf(flip(Lo{2}),qmfFLAG);
end
%--------------------------------------
% The last input argument qmfFLAG has has no effect on the final result.
% It's only used for control scope.
%--------------------------------------
% Length of filters.
len_LR = length(LoR2);
len_HR = length(HiR);
if isnan(PmaxLoRz)
    PmaxLoRz = floor(len_LR/2)-1;
end

% Initialize synthesis low-pass polynomial.
if isrow(LoR2) || iscolumn(LoR2)
    LoR = LoR2(:).';
end

LoRz = reduceCM(laurentPolynomial('Coefficients',LoR,'MaxOrder',PmaxLoRz));

% Suppress the null power max coefficients.
acualPMAX = LoRz.MaxOrder;
dPOW = PmaxLoRz-acualPMAX;

% Initialize synthesis high-pass polynomial.
% In orthogonal case , LoDz = LoRz and HiDz = HiRz. So ...
% PminLoRz = PmaxLoRz - len_LR + 1;
% PmaxGS = - PminLoRz -1;
PmaxGS = PmaxLoRz + len_HR - 2;
qmfPOW = 1 - qmfFLAG;

if rem(qmfPOW,2)
    CGs = -HiR;
else
    CGs = HiR;
end
HiRz = reduceCM(laurentPolynomial('Coefficients',CGs,'MaxOrder',PmaxGS));

%---------------------------------------------------------
% Perfect Reconstruction is given by (see also praacond):
%    PRCond(z) = LoRz(z) * LoDz(z)  + HiRz(z) * HiDz(z)
%---------------------------------------------------------
% Set unit Laurent monomial.
Z = laurentPolynomial('Coefficients',1,'MaxOrder',1);
if dPOW ~= 0, LoRz = LoRz * (Z^dPOW); end

HsRGs   = reduceCM(LoRz*modulate(HiRz));
cfsHsGs = HsRGs.Coefficients;
revCFS  = cfsHsGs(end:-1:1);
idxHsGs = find(revCFS);
powMAX = HsRGs.MaxOrder;
powMIN = powMAX-length(cfsHsGs)+1;
powHsGs = powMIN:powMAX;
powHsGs = powHsGs(idxHsGs);
idxODD  = mod(powHsGs,2);
nbODD   = sum(idxODD);
nbEVEN  = length(idxHsGs)-nbODD;

if nbODD == 1
    oddPOW = powHsGs(logical(idxODD));
    if oddPOW ~= -1 , HiRz = HiRz*Z^(-1-oddPOW); end
elseif nbEVEN == 1
    evenPOW = powHsGs(logical(1-idxODD));
    HiRz = HiRz*Z^(-1-evenPOW);
else
    coder.internal.error('Wavelet:FunctionInput:Invalid_BiorFilt');
end

if AddPOW ~= 0 , HiRz = HiRz*(Z^AddPOW); end

Z_1 = laurentPolynomial('Coefficients',1,'MaxOrder',-1);
Har = (-Z_1) * modulate(reflect(HiRz));
Gar =  Z_1 * modulate(reflect(LoRz));
LoDz = reflect(Har);
HiDz = reflect(Gar);

if nargout > 4
    [PRCond,AACond] = praacond(LoRz,HiRz,LoDz,HiDz);
end
end

function Q = modulate(P)
%MODULATE Modulation for a Laurent polynomial.
%   Q = MODULATE(P) returns the Laurent polynomial Q obtained by a
%   modulation on the Laurent polynomial P: Q(z) = P(-z).
%   
%   See also DYADDOWN, DYADUP, NEWVAR, REFLECT.

C = P.Coefficients;
D = P.MaxOrder;
L = length(C);
pow = (D:-1:D-L+1);
S = (-1).^pow;
newC = S.*C;
Q = laurentPolynomial('Coefficients',newC,'MaxOrder',D);
end

function objN = reduceCM(obj)
C = obj.Coefficients;
M = obj.MaxOrder;
C(abs(C) <= sqrt(eps(underlyingType(C)))) = 0;
idx = (find(abs(C) > 0));

if isempty(idx)
    CN = 0;
    MN = M;
else
    CN = C(idx(1):idx(end));
    ord = (0:-1:-(numel(C)-1))+M;
    MN = ord(idx(1));
end

objN = laurentPolynomial('Coefficients',CN,'MaxOrder',MN);
end

function [PRCond,AACond] = praacond(LoRz,HiRz,LoDz,HiDz)
%PRAACOND Perfect reconstruction and anti-aliasing conditions.
%   If (LoRz,HiRz) and (LoDz,HiDz) are two pairs of Laurent polynomials,
%   [PRCond,AACond] = PRAACOND(LoRz,HiRz,LoDz,HiDz) returns the values of PRCond(z)
%   and AACond(z) which are the Perfect Reconstruction and the
%   Anti-Aliasing "values":
%      PRCond(z) = LoRz(z) * LoDz(z)  + HiRz(z) * HiDz(z)
%      AACond(z) = LoRz(z) * LoDz(-z) + HiRz(z) * HiDz(-z)
%
%   The pairs (LoRz,HiRz) and (LoDz,HiDz) are associated to perfect
%   reconstruction filters if and only if:
%      PRCond(z) = 2 and AACond(z) = 0.
%
%   If PRCond(z) = 2 * z^d, a delay is introduced in the reconstruction
%   process.

PRCond = LoRz * (LoDz) + HiRz * (HiDz);
AACond = LoRz * modulate((LoDz)) + HiRz * modulate((HiDz));
end
