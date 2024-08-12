function [LoD,HiD,LoR,HiR] = lp2filters(Ha,Ga,Hs,Gs,signFLAG) %#ok<INUSD>
%LP2FILTERS Laurent polynomials to filters.
%   [LoD,HiD,LoR,HiR] = LP2FILTERS(Ha,Ga,Hs,Gs) returns the
%   filters associated to the Laurent polynomials (Ha,Ga,Hs,Gs).
%
%   [LoD,HiD,LoR,HiR] = LP2FILTERS(...,signFLAG) changes the
%   sign of the two high-pass filters (HiD,HiR). 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 24-Jun-2003.
%   Last Revision: 02-Sep-2003.
%   Copyright 1995-2021 The MathWorks, Inc.

if nargin>4  , IncPOW = 1; else , IncPOW = 0; end
isORTH = (Ha==Hs);
Ha = wavelet.internal.laurpoly.reflect(Ha);
Ga = wavelet.internal.laurpoly.reflect(Ga);
[LoD,HiD] = getFilters('a',Ha,Ga,isORTH,IncPOW);
[LoR,HiR] = getFilters('s',Hs,Gs,isORTH,IncPOW);

%--------------------------------------------------------
function [Lo,Hi] = getFilters(typeFILT,H,G,isORTH,IncPOW) %#ok<INUSL>

Lo = get(H,'coefs');
Hi = get(G,'coefs');
lenLo = length(Lo);
lenHi = length(Hi);
powHi = powers(G);
if lenLo==lenHi  % Orthogonal case in necessary here.
    switch typeFILT
        case 'a' , AddPOW = 0;
        case 's' , AddPOW = 1;
    end
else            % Part of biorthogonal case.
    [long,idx] = max([lenLo,lenHi]);
    add = fix(abs((lenLo-lenHi)/2));
    switch idx
        case 1 , Hi = extend_Filter(Hi,lenHi,long);
        case 2 , Lo = extend_Filter(Lo,lenLo,long);
    end
    switch typeFILT
        case 'a' , AddPOW = 1 + add;
        case 's' , AddPOW = 1;
    end
end
AddPOW = AddPOW + IncPOW;
powMUL = powHi(end) + AddPOW;
Hi = ((-1)^powMUL)*Hi;

% %----------------------------------------------------
% powLo = powers(H);
% disp('------------------------------------------')
% if lenLo~=lenHi
%     disp(['typeFILT: ' typeFILT]);
%     disp(['   add: ' sprintf('%3.0f',add) , ...
%           '  - idx: ' sprintf('%3.0f',idx)]);
% end
% disp(['AddPOW: ' sprintf('%3.0f',AddPOW)]);
% disp([' powHi: ' sprintf('%3.0f',powHi) ...
%         '  (len: ' sprintf('%2.0f',lenHi),')']);
% disp([' powLo: ' sprintf('%3.0f',powLo) ...
%         '  (len: ' sprintf('%2.0f',lenLo),')']);
% disp(['powMUL: ' sprintf('%3.0f',powMUL)]);
% disp(['dLenM4: ' sprintf('%3.0f',mod(lenHi-lenLo,4))]);
% if lenLo~=lenHi && idx==1
%     disp(['lenHiExt: ' sprintf('%3.0f',length(Hi)-lenHi)]);
% end
% disp('------------------------------------------')
% %----------------------------------------------------

%--------------------------------------------
function G = extend_Filter(F,len,long)

d = (long-len)/2;
G = [zeros(1,floor(d)) F zeros(1,ceil(d))];
%--------------------------------------------
