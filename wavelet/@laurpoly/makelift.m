function [Ha,Ga,Hs,Gs] = makelift(Ha,Ga,Hs,Gs,type,T)
%MAKELIFT Make an elementary lifting step.
%   [HaN,GaN,HsN,GsN] = MAKELIFT(Ha,Ga,Hs,Gs,TYPE,T)
%   returns the four Laurent polynomials HaN, GaN, HsN and
%   GsN obtained by an elementary lifting step starting
%   with the four Laurent polynomials Ha, Ga, Hs and Gs.
%   
%   T is a Laurent polynomial and TYPE gives the "type" of
%   the lifting step:  'p' (primal) or 'd' (dual).
%
%   If TYPE = 'p' , Ga and Hs are not changed and
%      GsN(z) = Gs(z) + Hs(z) * T(z^2);   
%      HaN(z) = Ha(z) - Ga(z) * T(1/z^2);   
%
%   If TYPE = 'd' , Ha and Gs are not changed and
%      HsN(z) = Hs(z) + Gs(z) * T(z^2);   
%      GaN(z) = Ga(z) - Ha(z) * T(1/z^2);

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 27-May-2003.
%   Last Revision: 08-Jul-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

type = lower(type(1));
T = dyadup(T);
switch type
    case 'p'  % 'primal'
        Gs = Gs + Hs * T;
        Ha = Ha - Ga * reflect(T);
        
    case 'd'  % 'dual'
        Hs = Hs + Gs * T;
        Ga = Ga - Ha * reflect(T);
end
