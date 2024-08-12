function [phiS,psiS,phiA,psiA,xval] = bswfun(Lo_D,Hi_D,Lo_R,Hi_R,IN5,IN6)
%BSWFUN Biorthogonal scaling and wavelet functions.
%   [PHIS,PSIS,PHIA,PSIA,XVAL] = BSWFUN(LoD,HiD,LoR,HiR)
%   returns approximations on the grid XVAL of the two 
%   pairs of scaling function and wavelet (PHIA,PSIA), 
%   (PHIS,PSIA) associated with the two pairs of filters
%   (LoD,HiD), (LoR,HiR).
%
%   BSWFUN(...,ITER) computes the two pairs of scaling 
%   and wavelet functions using ITER iterations.
%
%   BSWFUN(...,'plot') or BSWFUN(...,ITER,'plot') or 
%   BSWFUN(...,'plot',ITER), computes and, in addition, 
%   plots the functions.
%
%   See also WAVEFUN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 24-Jun-2003.
%   Last Revision: 20-Jul-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Comments:
%----------
% In the Daubechies' book pages 261-278 and more
% precisely pages 272-276:
%   (PHIA,PSIA) corresponds to (PHI,PSI)
%   (PHIS,PSIS) corresponds to (PHI_tilda,PSI_tilda)

% Reverse decomposition scaling function 
% and wavelet if flagREVERSE is true.
%---------------------------------------
% flagREVERSE = true;
if nargin > 4
    IN5 = convertStringsToChars(IN5);
end

if nargin > 5
    IN6 = convertStringsToChars(IN6);
end

flagREVERSE = false;

% Check input arguments.
iterDEF = 10;
switch nargin
    case {0,1,2,3}
        error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
    case 4
        flagPLOT = false;
        iter = iterDEF; 
    case 5
        if ischar(IN5)
            flagPLOT = true;
            iter = iterDEF;
        else
            flagPLOT = false;
            iter = IN5;
        end
    case 6
        flagPLOT = true;
        if ischar(IN5)
            iter = IN6;
        else
            iter = IN5;
        end
end
if (ischar(iter) || any(iter < 1) || any(iter ~= fix(iter)))
    iter = iterDEF;
end

% Compute scaling functions and wavelets.
coef = (sqrt(2)^iter);
if flagREVERSE  && isequal(Lo_R,wrev(Lo_D))
    phiA = coef*upcoef('a',1,wrev(Lo_D),NaN,iter);
    psiA = coef*upcoef('d',1,wrev(Lo_D),wrev(Hi_D),iter);    
else
    phiA = coef*upcoef('a',1,Lo_D,NaN,iter);
    psiA = coef*upcoef('d',1,Lo_D,Hi_D,iter);
end
phiS = coef*upcoef('a',1,Lo_R,NaN,iter);
psiS = coef*upcoef('d',1,Lo_R,Hi_R,iter);

% Plot scaling functions and wavelets if requested.
if flagPLOT
    flgNUM = 1;
    figure('DefaultAxesXGrid','On','DefaultAxesYGrid','On');
else
    flgNUM = 0;    
end
LW = 2;
phiCOL = 'r';
psiCOL = 'b';
strTitle = 'Analysis scaling function (phiA)';
phiA = getAndplotFUN(phiA,Lo_D,LW,phiCOL,1*flgNUM,strTitle);
strTitle = 'Analysis wavelet function (psiA)';
psiA = getAndplotFUN(psiA,Hi_D,LW,psiCOL,2*flgNUM,strTitle);
strTitle = 'Synthesis scaling function (phiS)';
[phiS,x_phiS] = getAndplotFUN(phiS,Lo_R,LW,phiCOL,3*flgNUM,strTitle);
strTitle = 'Synthesis wavelet function (psiS)';
psiS = getAndplotFUN(psiS,Hi_R,LW,psiCOL,4*flgNUM,strTitle);    
xval = x_phiS;

%-----------------------------------------------------------
function [y,x] = getAndplotFUN(y,F,LW,color,numSub,strTitle)

[x,y,ymin,ymax,dy] = getXY(y,F);
if numSub==0 , return; end

a = subplot(2,2,numSub); 
plot(x,y,color,'LineWidth',LW); 
try set(a,'XLim',[x(1) x(end)]); end %#ok<*TRYNC>
try set(a,'YLim',[ymin-dy ymax+dy]); end
title(strTitle,'FontSize',8,'FontWeight','bold')
%---------------------------------------------------------
function [x,y,ymin,ymax,dy] = getXY(fVAL,filtre)

y = fVAL; 
ymin = min(y); ymax = max(y); 
if abs(ymax-ymin)<100*eps 
    y = [0 y 0]; ymin = min(y); ymax = max(y);
end
dy = (ymax-ymin)/100;
ly = length(y);
L  = length(filtre);
x  = linspace(0,L-1,ly);
%---------------------------------------------------------
