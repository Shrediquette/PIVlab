function [Ha,Ga,Hs,Gs,PRCond,AACond] = filters2lp(type,LoR,varargin)
%FILTERS2LP Filters to Laurent polynomials.
%   [Ha,Ga,Hs,Gs] = FILTERS2LP('o',LoR) returns the Laurent 
%   polynomials (Ha,Ga,Hs,Gs) associated to the low-pass 
%   filter LoR and the corresponding high-pass filter 
%   HiR = qmf(LoR) (orthogonal case). 
%
%   [Ha,Ga,Hs,Gs] = FILTERS2LP('b',LoR,LoD) returns the 
%   Laurent polynomials (Ha,Ga,Hs,Gs) associated to the
%   low-pass filter LoR and the low-pass filter LoD.
%   In that case, HiR = qmf(fliplr(LoD))(biorthogonal case).
%
%   [...] = FILTERS2LP(...,PmaxHS) let's specify the maximum  
%   power of Hs. PmaxHS must be an integer. The default value
%   is zero.
%
%   [...] = FILTERS2LP(...,AddPOW) let's change the default 
%   maximum power of Gs : PmaxGS = PmaxHS + length(Gs) - 2, 
%   adding the integer AddPOW. The default value for AddPOW
%   is zero. AddPOW must be an even integer to preserve the
%   perfect condition reconstruction.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Jul-2003.
%   Copyright 1995-2021 The MathWorks, Inc.

% Check input arguments.
if nargin<2
    error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
end
type = char(lower(type));
switch type(1)
    case 'o' , firstARG = 0;
    case 'b' , firstARG = 1;
end
argNUM = firstARG:firstARG + 4;
nbIn = length(varargin);
switch nbIn
    case argNUM(1)
        PmaxHS = 0; AddPOW = 0; qmfFLAG = 0; 
        
    case argNUM(2)
        PmaxHS = varargin{argNUM(2)};
        qmfFLAG = 0; AddPOW = 0; 
        
    case argNUM(3)
        [PmaxHS,AddPOW] = deal(varargin{argNUM(2:3)});
        qmfFLAG = 0;
        
    case argNUM(4)
        [PmaxHS,AddPOW,qmfFLAG] = deal(varargin{argNUM(2:4)});
        
    otherwise
        error(message('Wavelet:FunctionInput:TooMany_ArgNum'));
end
switch type(1)
    case 'o' , HiR = qmf(LoR,qmfFLAG);
    case 'b' , HiR = qmf(wrev(varargin{1}),qmfFLAG);
end
%--------------------------------------
% The last input argument qmfFLAG has
% has no effect on the final result. It's
% only used for control scope.  
%--------------------------------------

% Set unit Laurent monomial.
Z = laurpoly(1,1);

% Length of filters.
len_LR = length(LoR);
len_HR = length(HiR);
if isnan(PmaxHS)
    PmaxHS = floor(len_LR/2)-1;
end

% Initialize synthesis low-pass polynomial.
Hs = laurpoly(LoR,PmaxHS);

% Suppress the null power max coefficients.
acualPMAX = powers(Hs,'max');
dPOW = PmaxHS-acualPMAX;
if dPOW ~= 0 , Hs = Hs * Z^dPOW; end

% Initialize synthesis high-pass polynomial.
% In orthogonal case , Ha = Hs and Ga = Gs. So ...
% PminHS = PmaxHS - len_LR + 1;
% PmaxGS = - PminHS -1;
PmaxGS = PmaxHS + len_HR - 2; 
qmfPOW = 1 - qmfFLAG;
Gs = (-1)^qmfPOW * laurpoly(HiR,PmaxGS);

%---------------------------------------------------------
% Perfect Reconstruction is given by (see also praacond):
%    PRCond(z) = Hs(z) * Ha(1/z)  + Gs(z) * Ga(1/z)
% or in an equivalent way:
%    PRCond = -z * ( Hs(z)*Gs(-z)-Hs(-z)*Gs(z))
%---------------------------------------------------------

% if  d_LEN ~= 0
    HsRGs   = Hs*modulate(Gs);
    cfsHsGs = lp2num(HsRGs);
    revCFS  = cfsHsGs(end:-1:1);
    idxHsGs = find(revCFS);
    powHsGs = powers(HsRGs);
    powHsGs = powHsGs(idxHsGs);
    idxODD  = mod(powHsGs,2);
    nbODD   = sum(idxODD);
    nbEVEN  = length(idxHsGs)-nbODD;
    if nbODD==1
        oddPOW = powHsGs(logical(idxODD));
        if oddPOW~=-1 , Gs = Gs*Z^(-1-oddPOW); end
    elseif nbEVEN==1
        evenPOW = powHsGs(logical(1-idxODD));
        Gs = Gs*Z^(-1-evenPOW);
    else
        error(message('Wavelet:FunctionInput:Invalid_BiorFilt'));
    end
% end
    
if AddPOW ~= 0 , Gs = Gs*Z^AddPOW; end
Ha = -Z^(-1) * modulate(reflect(Gs));
Ga =  Z^(-1) * modulate(reflect(Hs));

if nargout>4
    [PRCond,AACond] = praacond(Hs,Gs,Ha,Ga);
end
