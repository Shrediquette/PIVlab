function map = getscaledmap(axe,NbCOL,flagNaN)
%GETSCALEDMAP Built a scaled colormap using axes colororder.
%   MAP = GETSCALEDMAP(AXE,NbCOL,flagNaN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2005.
%   Last Revision: 26-Sep-2006.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin<1 , axe = gca; end
map = get(axe,'ColorOrder');
if nargin<2 , return; end
if nargin<3 , flagNaN = 0; end
nbInMAP = size(map,1);
if NbCOL>4*nbInMAP
    nbDIV = ceil(NbCOL/nbInMAP);
    power = fliplr(linspace(0.1,0.7,nbDIV));
else
    power = [0.75 0.30 0.25 0.20];
end
tmp = map;
tmp(tmp==0) = 0.1;
map = [];
for k = 1:length(power)
    map = [map ; tmp.^power(k)];    
end
map = map(1:NbCOL,:);
if flagNaN , map(1,:) = 1; end   
