function varargout = conofinf(wname,scales,LSig,x,ArgPLOT)
%CONOFINF Cone of influence for CWT.
%   For a signal of length LSIG, analyzed with the continuous wavelet
%   transform (CWT) using the wavelet WNAME, and for the scales SCALES,
%   CONE = CONOFINF(WAME,SCALES,LSIG,X) returns the cone of influence
%   (COI) of the Xth value of the signal.  The Xth value of the signal 
%   may be outside the interval [1,LSIG].
%   CONE is a NbScales by LSIG matrix such that CONE(i,j) = 1
%   when the jth component of the CWT at the ith scale is influenced
%   by the Xth value of the signal, and CONE(i,j) = 0 otherwise.
%
%   If X is a vector, CONE is a cell array. Each cell contains the COI 
%   of the corresponding component of X.
%
% 	In addition, [CONE,PL,PR,PLmin,PRmax] = CONOFINF(...,X) returns several 
%   polynomials of degree 1. PL and PR are the equations of the left and 
%   right edges of the COI respectively.
%   If X is a vector of length LX, PL and PR are LX by 2 matrices.
%   (1-PL(:,2))./PL(:,1) and 1-PR(:,2))./PR(:,1) give respectively    
%   the abscissa of left and right edges for the scale 1.
%
%   PLmin and PRmax are polynomials of degree 1 which give the equation
%   of the minimal left vertex, and the equation of the maximal right  
%   vertex respectively, completely included in the (NbScales by LSIG) 
%   domain of the CWT.
%   
%   Note that [PLmin,PRmax] = CONOFINF(WAME,SCALES,LSIG) or 
%             [PLmin,PRmax] = CONOFINF(WAME,SCALES,LSIG,[]) 
%   returns only the PLmin and PRmax polynomials.
%
%   In Addition, you can plot the cones of influence using:
%       [...] = CONOFINF(...,'plot')

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 08-Feb-2010.
%   Last Revision: 04-Jan-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check inputs.
if nargin > 0
    wname = convertStringsToChars(wname);
end

if nargin > 4
    ArgPLOT = convertStringsToChars(ArgPLOT);
end

flagPLOT = false;
if length(scales)<2 , scales = 1:scales; end
if isempty(LSig) || ~isnumeric(LSig) || numel(LSig)>1 || ...
        (LSig<1) || LSig~=fix(LSig)
    error(message('Wavelet:FunctionInput:TypeOfbArg'))   
end
if nargin<4 , x = []; end
if nargin>4 , flagPLOT = ~isequal(ArgPLOT,false); end

% Check outputs.
if ~isempty(x) , maxOUT = 7; else maxOUT = 4; end
nargoutchk(0,maxOUT)

% Get the support of the wavelet.
bounds = wavsupport(wname);

% Compute the limits of cones of influence.
xR = LSig-bounds(2)*scales(end);
xL = -bounds(1)*scales(end)+1;
Lmin = [0 scales(end);xL 0];
Rmax = [xR 0;LSig scales(end)];

% Compute the cone of influence for each x value.
if ~isempty(x)
    x = x(:);
    scales = scales(:)';
    nbS = length(scales);
    nbX = length(x);
    L = repmat(bounds(1)*scales,nbX,1) + repmat(x,1,nbS);
    R = repmat(bounds(2)*scales,nbX,1) + repmat(x,1,nbS);
    
    PL = zeros(nbX,2);
    PR = zeros(nbX,2);
    for k = 1:nbX
        PL(k,:) = getLine([L(k,[1 end])' , scales([1 end])']);
        PR(k,:) = getLine([R(k,[1 end])' , scales([1 end])']);
    end
        
    cone = cell(1,nbX);
    warning('Off','MATLAB:colon:nonIntegerIndex')
    for k = 1:nbX
        coneofx = zeros(nbS,LSig);
        L(k,:) = max(L(k,:),1);
        R(k,:) = min(R(k,:),LSig);
        for j=1:nbS
            coneofx(j,L(k,j):R(k,j)) = 1;
        end
        cone{k} = coneofx;
    end
    warning('On','MATLAB:colon:nonIntegerIndex')
    if nbX==1 , cone = cone{1}; end 
else
    L = []; R = []; cone = [];
end
Pmin = getLine(Lmin);
Pmax = getLine(Rmax);
xMin = (1-Pmin(2))/Pmin(1);
xMax = (1-Pmax(2))/Pmax(1);
if ~isempty(x)
    varargout = {cone,PL,PR,Pmin,Pmax,xMin,xMax};
else
    varargout = {Pmin,Pmax,xMin,xMax};
end

% Plot the cones if requested.
if ~flagPLOT , return; end

LW = 2;
hold on;
plot(Lmin(:,1),Lmin(:,2),'b','LineWidth',LW);
stem(xMin,scales(1),'filled',...
    'MarkerSize',7,'MarkerEdgeColor','b','MarkerFaceColor','b');
plot(Rmax(:,1),Rmax(:,2),'r','LineWidth',LW);
stem(xMax,scales(1),'filled',...
    'MarkerSize',7,'MarkerEdgeColor','r','MarkerFaceColor','r');

if ~isempty(x)
    LW = 1;
    midPts = 0.5*(L(:,1)+R(:,1));
    for k = 1:nbX
        plot(L(k,:),scales,'m:','LineWidth',LW);
        plot(R(k,:),scales,'m:','LineWidth',LW);
        stem(midPts(k,1),scales(1),'filled',...
            'MarkerSize',7,'MarkerEdgeColor','k','MarkerFaceColor','k');
        iL1 = find(L(k,:)==1,1,'first');
        iL2 = find(L(k,:)==1,1,'last');
        if isempty(iL1) , iL1 = nbS ; iL2 = nbS; end
        iR1 = find(R(k,:)==LSig,1,'first');
        iR2 = find(R(k,:)==LSig,1,'last');
        if isempty(iR1) , iR1 = nbS; iR2 = nbS; end
        t = [L(k,iL1) L(k,1) R(k,1) R(k,iR1)     ...
                R(k,iR2) L(k,iL2)  L(k,iL1)];
        s = [scales(iL1) 1  1  scales(iR1)  ...
                scales(iR2) scales(iL2)  scales(iL1)];
        hcoi = fill(t,s,[1 1 1]);
        set(hcoi,'alphadatamapping','direct','facealpha',.5)
    end    
end
if isempty(x)
    t = [Lmin(1,1) , Lmin(2,1) , Rmax(1,1)  , Rmax(2,1) , Lmin(1,1)];
    s = [Lmin(1,2) , Lmin(2,2) , Rmax(1,2)  , Rmax(2,2) , Lmin(1,2)];
    hcoi = fill(t,s,[1 0.8 1]);
    set(hcoi,'alphadatamapping','direct','facealpha',.4)
end
if LSig<=20
    xlim = [min([xMax,1]) max([xMin,LSig])];
    plotXL = true;
else
    xlim = [1,LSig];
    plotXL = false;
end
if plotXL
    stem([1 LSig],[scales(1),scales(1)],'filled','MarkerSize',7,...
    'MarkerEdgeColor',[0 0.8 0],'MarkerFaceColor',[0 0.8 0]);
end
set(gca,'XLim',xlim,'YLim',[1,scales(end)]);
hold off;

function P = getLine(L)

dx = L(2,1)-L(1,1);
dy = L(2,2)-L(1,2);
P(1) = dy/dx;
dxy = L(1,2)*L(2,1)-L(1,1)*L(2,2);
P(2) = dxy/dx;



