function [Ha,Ga,Hs,Gs] = wlift(Ha,Ga,Hs,Gs,IN5,IN6,IN7) %#ok<INUSD>
%WLIFT Make elementary lifting step.
%   [HaN,GaN,HsN,GsN] = WLIFT(Ha,Ga,Hs,Gs,ELS) returns 
%   the four Laurent polynomials HaN, GaN, HsN and GsN 
%   obtained by an "elementary lifting step" (ELS) starting  
%   from the four Laurent polynomials Ha, Ga, Hs and Gs.
%   ELS is a structure such that:
%     - TYPE = ELS.type gives the "type" of the elementary   
%       lifting step. The valid values for TYPE are: 
%          'p' (primal) or 'd' (dual).
%     - VALUE = ELS.value gives the Laurent polynomial T
%       associated to the elementary lifting step. If VALUE
%       is a vector, the Laurent polynomial T is equal to 
%       laurpoly(VALUE,0).
%
%   A SPECIAL CASE of ELS is a "scaling step". In that case,
%   TYPE is equal to 's' (scaling) and VALUE is a scalar 
%   different from zero. A "scaling step" is equivalent to a 
%   sequence of four other steps ('d','p','d','p') or
%   ('p','d','p','d') with constant Laurent polynomials.
%
%   [...] = WLIFT(...,TYPE,VALUE) gives the same results.
%
%   If TYPE = 'p' , Ga and Hs are not changed and
%      GsN(z) = Gs(z) + Hs(z) * T(z^2) 
%      HaN(z) = Ha(z) - Ga(z) * T(1/z^2)   
%
%   If TYPE = 'd' , Ha and Gs are not changed and
%      HsN(z) = Hs(z) + Gs(z) * T(z^2)  
%      GaN(z) = Ga(z) - Ha(z) * T(1/z^2)
%
%   If TYPE = 's' , Ha, Ga, Hs and Gs are changed and
%      Hs(z) = Hs(z) * VALUE ;  Gs(z) = Gs(z) / VALUE
%      Ha(z) = Ha(z) / VALUE;   Ga(z) = Ga(z) * VALUE
%
%   If ELS is an array of elementary lifting steps,
%   WLIFT(...,ELS) performs each step successively.
%
%   WLIFT(...,flagPLOT) plots the successive "biorthogonal"
%   pairs: ("scale function" , "wavelet"). 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 27-May-2003.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
narginchk(4,7)
if isstruct(IN5)
    ELS = IN5;
    nextARG = 6;
else
    ELS = struct('type',IN5,'value',IN6);
    nextARG = 7;
end
if nargin < nextARG , flagPLOT = false; else flagPLOT = true; end

if flagPLOT
    [LoD,HiD,LoR,HiR] = lp2filters(Ha,Ga,Hs,Gs);
    bswfun(LoD,HiD,LoR,HiR,'plot');
end

for k = 1:length(ELS)
    type = ELS(k).type;
    switch type
        case {'p','d'}
            P = ELS(k).value;
            if isnumeric(P) , P = laurpoly(P); end
            P = dyadup(P);
            switch type
                case 'p'  % 'primal'
                    Gs = Gs + Hs * P; Ha = Ha - Ga * reflect(P);
                case 'd'  % 'dual'
                    Hs = Hs + Gs * P; Ga = Ga - Ha * reflect(P);
            end
            
        case 's'
            cfsNOR = ELS(k).value;
            Hs = cfsNOR*Hs; Gs = Gs/cfsNOR;
            Ha = Ha/cfsNOR; Ga = cfsNOR*Ga;
    end
    if flagPLOT
        [LoD,HiD,LoR,HiR] = lp2filters(Ha,Ga,Hs,Gs);
        bswfun(LoD,HiD,LoR,HiR,'plot');
    end
end    
