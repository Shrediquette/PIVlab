function varargout = dw1dstem(axe,coefs,longs,varargin)
%DW1DSTEM Discrete wavelet 1-D stem.
%
% First input format:
%--------------------
%   varargout = DW1DSTEM(AXE,COEFS,LONGS,ABSMODE,VIEWAPP,COLORS)
%   varargout = DW1DSTEM(AXE,COEFS,LONGS,ABSMODE,VIEWAPP)
%   varargout = DW1DSTEM(AXE,COEFS,LONGS,ABSMODE)
%   varargout = DW1DSTEM(AXE,COEFS,LONGS)
%
% Second input format:
%--------------------
%   varargout = DW1DSTEM(AXE,COEFS,LONGS,'PropName1',ProVal1,...)
%   varargout = DW1DSTEM(AXE,COEFS,LONGS)
%   Valid 'PropNames' are: 'mode', 'viewapp' , 'colors'
%
% In each case
%-------------
%   ABSMODE = 0 or 1.
%   VIEWAPP = 0 or 1.
%   COLORS is a numeric array or the key word 'WTBX'.
%
%   The defaults are:
%   ABSMODE = 1; VIEWAPP = 0; COLORS = flipud(get(axe,'colororder'));
   
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Apr-98.
%   Last Revision: 20-Jul-2010.
%   Copyright 1995-2020 The MathWorks, Inc.


% Default Values.
%----------------
absmode = 1;
viewapp = 0;
colors  = get(axe,'colororder');
flagzero = 1;

% Check input (OLD & NEW version).
%---------------------------------
nbin = length(varargin);
if nbin>0
  numINPUT = 1;
  for k = 1:min(nbin,2)
    numINPUT = numINPUT & ...
        (isnumeric(varargin{k}) || islogical(varargin{k}));
  end
  if numINPUT
      switch nbin
        case 1 , absmode = varargin{1};
        case 2 , [absmode,viewapp] = deal(varargin{:});
        case 3 
          [absmode,viewapp,colors] = deal(varargin{:});
          if ~isnumeric(varargin{3}) && ~isequal(upper(colors),'WTBX')
              colors = get(axe,'colororder');
          end
      end
  else
      k = 1;
      while k<=nbin
        argNam = lower(varargin{k}); k = k+1;
        switch argNam
          case 'mode'     , absmode  = varargin{k}; k = k+1;
          case 'viewapp'  , viewapp  = varargin{k}; k = k+1;
          case 'colors'   , colors   = varargin{k}; k = k+1;
          case 'flagzero' , flagzero = varargin{k}; k = k+1;
        end
      end
  end
end
level = length(longs)-2;
if isequal(upper(colors),'WTBX')
   dum = wtbutils('colors','app',level);
   dum = dum(1,:);
   colors = [wtbutils('colors','det',level) ; dum];
end

lx    = longs(end);
lf    = 2*longs(end-1)-lx;
lf    = lf+2-rem(lf,2);
delete(get(axe,'Children'));

tag_axe = get(axe,'Tag');
next    = lower(get(axe,'NextPlot'));
Ymax    = level+viewapp;
set(axe,'NextPlot','add','YLim',[0.5 Ymax+0.5])

while size(colors,1)<Ymax
   colors = [colors;colors];
end
mul = max([0.85,0.96*(Ymax-1)/Ymax]);

hdl_lin = [];
YtickLab = {};
for k=1:Ymax  
    appFlag = (k==(level+1));    
    if appFlag
        kVal = k-1;
        d = coefs(1:longs(1));
        YtickLab = {YtickLab{:},['A' int2str(kVal)]};
    else
        kVal = k;
        d = detcoef(coefs,longs,kVal);
        YtickLab = {YtickLab{:},['D' int2str(kVal)]};
    end
    d  = d(:)';
    m  = max(abs(d));
    ld = length(d);    
    xloc = coefsLOC((1:ld),kVal,lf,lx);    
    if absmode
       d = abs(d);
       dbase = k-0.5;
    else
       d = d/2;
       dbase = k;
    end
    if m>0 , d = (mul*d)/m; end
    color = colors(k,:);
    hh = plotstem(axe,m,{1,xloc,lx},{d,dbase},color,flagzero);
    hdl_lin = [hdl_lin hh];
end
set(axe,'YTick',(1:Ymax),'YTickLabel',YtickLab,'NextPlot',next,'Tag',tag_axe);
varargout{1} = hdl_lin;

function [loc,low,up] = coefsLOC(idx,niv,lf,lx)
%COEFSLOC coefficient location

up  = idx;
low = idx;
for k=1:niv
    low = 2*low+1-lf;
    up  = 2*up;
end
loc = max(1,min(lx,round((low+up)/2)));


function h = plotstem(varargin)
%PLOTSTEM Plot discrete sequence data.
%   PLOTSTEM(AXE,MAXVAL,{xlow,xloc,xup},{Y,YBASE},COLOR,FLGZERO) or
%   PLOTSTEM(MAXVAL,{xlow,xloc,xup},Y,COLOR) or
%   PLOTSTEM(AXE,MAXVAL,{xlow,xloc,xup},Y,COLOR,FLGZERO)
%   PLOTSTEM(MAXVAL,{xlow,xloc,xup},Y,COLOR,FLGZERO)

if ishandle(varargin{1})
    axe     = varargin{1};
    xlow    = varargin{3}{1};
    x       = varargin{3}{2};
    xup     = varargin{3}{3};
    y       = varargin{4}{1};
    ybase   = varargin{4}{2};
    nextarg = 5;
else
    axe     = newplot;
    xlow    = varargin{3}{1};
    x       = varargin{3}{2};
    xup     = varargin{3}{3};
    y       = varargin{3}{1};
    ybase   = varargin{3}{2};
    nextarg = 4;
end
if nargin<nextarg
    c       = get(axe,'colororder');
    c       = c(1,:);
    flgZero = 1;
elseif nargin==nextarg
    c       = varargin{nextarg};
    flgZero = 1;
else
    c       = varargin{nextarg};
    flgZero = varargin{nextarg+1};
end
xAxeColor = get(axe,'XColor');

q =  [xlow xup];
h = NaN*ones(1,4);
h(1) = plot([q(1) q(2)],ybase+[0 0],'Parent',axe,'Color',xAxeColor);

indZ = find(abs(y)<eps);
xZ   = x(indZ);
yZ   = y(indZ);
x(indZ) = [];
y(indZ) = [];

n = length(x);
if n>0
    MSize = 2; Mtype = 'o';
    MarkerEdgeColor = c;
    MarkerFaceColor = c;
    xx = [x;x;nan*ones(size(x))];
    yy = [zeros(1,n);y;NaN*ones(size(y))];
    h(2) = plot(xx(:),ybase+yy(:),'Parent',axe,'LineStyle','-','Color',c);
    h(3) = plot(x,ybase+y,'Parent',axe,...
                'Marker',Mtype, ...
                'MarkerEdgeColor',MarkerEdgeColor, ...
                'MarkerFaceColor',MarkerFaceColor, ...
                'MarkerSize',MSize, ...
                'LineStyle','none',...
                'Color',c);
end

nZ = length(xZ);
if flgZero && (nZ>0)
    MSize = 2; Mtype = 'o';
    h(4)  = plot(xZ,ybase+yZ,'Parent',axe,...
                'Marker',Mtype, ...
                'MarkerEdgeColor',xAxeColor, ...
                'MarkerFaceColor',xAxeColor, ...
                'MarkerSize',MSize, ...
                'LineStyle','none',...
                'Color',xAxeColor);
end
