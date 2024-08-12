function A = getdec(t,option) %#ok<INUSD>
%GETDEC Get decomposition components.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 29-Dec-2006.
%   Copyright 1995-2020 The MathWorks, Inc.

tn  = leaves(t);
lev = treedpth(t);
d = read(t,'data',tn);

NA = 2^lev;
A  = d{1}/NA;
mA = max(abs(A(:)));
for k = 2:3:length(d)
    A = wkeep2(A,size(d{k}));
    A = [ A , normCFS(d{k},mA); normCFS(d{k+1},mA) , normCFS(d{k+2},mA) ]; %#ok<AGROW>
end
%--------------------------------------
function Y = normCFS(X,mA,option) %#ok<INUSD>

mX = max(abs(X(:)));
if mX==0
    Y  = mA*ones(size(X)); 
else
    Y  = mA*(1-abs(X)/mX);
end
%--------------------------------------
