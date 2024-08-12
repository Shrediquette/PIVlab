function [Ea,Eh,Ev,Ed] = wenergy2(C,S)
%WENERGY2 Energy for 2-D wavelet decomposition.
%   For a two dimensional wavelet decomposition [C,S], 
%   (see WAVEDEC2) [Ea,Eh,Ev,Ed] = WENERGY2(C,S) returns
%   Ea, which is the percentage of energy corresponding to
%   the approximation, and vectors Eh, Ev, Ed, which contain 
%   respectively the  percentages of energy corresponding to 
%   the horizontal, vertical and diagonal details.
%
%   [Ea,EDetail] = WENERGY2(C,S) returns Ea, and EDetail, 
%   which is the sum of vectors Eh, Ev and Ed.  
%
%   Example:
%     load detail
%     [C,S] = wavedec2(X,2,'sym4');
%     [Ea,Eh,Ev,Ed] = wenergy2(C,S)
%     [Ea,EDetails] = wenergy2(C,S)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

Et = sum(C.^2);
level = size(S,1)-2;
Ca = C(1:prod(S(1,:)));
Ea = 100*sum(Ca.^2)/Et;
Eh = zeros(1,level); Ev = Eh; Ed = Eh;
for k=1:level 
    [Ch,Cv,Cd] = detcoef2('all',C,S,k);
    Eh(k) = 100*sum(Ch(:).^2)/Et;
    Ev(k) = 100*sum(Cv(:).^2)/Et; 
    Ed(k) = 100*sum(Cd(:).^2)/Et; 
end
if nargout==2
    Eh = Eh + Ev + Ed;
end
