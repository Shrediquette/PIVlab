function wpviewcf(wpt,colmode,nb_colors)
%WPVIEWCF Plot wavelet packets colored coefficients.
%   WPVIEWCF(T,CMODE) plots the colored coefficients
%   for the terminal nodes of the tree T.
%   T is a wptree Object.
%   CMODE is an integer which represents the color mode with:
%       1: 'FRQ : Global + abs'
%       2: 'FRQ : By Level + abs'
%       3: 'FRQ : Global'
%       4: 'FRQ : By Level'
%       5: 'NAT : Global + abs'
%       6: 'NAT : By Level + abs'
%       7: 'NAT : Global'
%       8: 'NAT : By Level'
%
%   wpviewcf(T,CMODE,NB) uses NB colors.
%
%   Example:
%     x = sin(8*pi*(0:0.005:1));
%     t = wpdec(x,4,'db1');
%     plot(t);
%     wpviewcf(t,1);
%
%   See also WPDEC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Sep-96.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
switch nargin
  case 1 , nb_colors = 128; colmode = 1;
  case 2 , nb_colors = 128;
end
flg_line = 5;

order = treeord(wpt);
dmax  = treedpth(wpt);
nodes = leaves(wpt);
sizes = fmdtree('tn_read',wpt,'sizes');
nbtn  = length(nodes);
[depths,posis] = ind2depo(order,nodes);
cfs   = read(wpt,'data');

if find(colmode==[1 2 3 4])
    ord = wpfrqord(nodes);
else
    ord = (1:nbtn);
end
if find(colmode==[1 2 5 6])
    abs_val = 1;
elseif find(colmode==[3 4 7 8])
    abs_val = 0;
end
if find(colmode==[1 3 5 7])
    cfs = wcodemat(cfs,nb_colors,'row',abs_val);
end

switch colmode
   case 1 , strtit = getWavMSG('Wavelet:moreMSGRF:FRQ_GLB_ABS');
   case 2 , strtit = getWavMSG('Wavelet:moreMSGRF:FRQ_LEV_ABS');
   case 3 , strtit = getWavMSG('Wavelet:moreMSGRF:FRQ_GLB');
   case 4 , strtit = getWavMSG('Wavelet:moreMSGRF:FRQ_LEV');
   case 5 , strtit = getWavMSG('Wavelet:moreMSGRF:NAT_GLB_ABS');
   case 6 , strtit = getWavMSG('Wavelet:moreMSGRF:NAT_LEV_ABS');
   case 7 , strtit = getWavMSG('Wavelet:moreMSGRF:NAT_GLB');
   case 8 , strtit = getWavMSG('Wavelet:moreMSGRF:NAT_LEV');
end

sizes = max(sizes,[],2);
deb = ones(1,nbtn);
fin = zeros(1,nbtn);
for k = 1:nbtn
    fin(k)   = deb(k)+sizes(k)-1;
    deb(k+1) = fin(k)+1;
end
nbrows   = (2.^(dmax-depths));
NBrowtot = sum(nbrows);
NBcoltot = max(read(wpt,'sizes',0));
matcfs   = zeros(NBrowtot,NBcoltot);
ypos     = zeros(nbtn,1);

if nbtn>1
    for k = 1:nbtn
        ypos(ord(k)) = sum(nbrows(ord((1:k-1))));
    end
end     
ypos = NBrowtot+1-ypos-nbrows;
ymin = (ypos-1)/NBrowtot;
ymax = (ypos-1+nbrows)/NBrowtot;
ytics = sort((ymax+ymin)/2);
nbDIGIT   = ceil(log10(max(nodes)+sqrt(eps)));
formatNum = ['%' sprintf('%d',nbDIGIT) '.0f'];
ylabs = ' ';
ylabs = ylabs(ones(nbtn,nbDIGIT));

ordered_nodes = flipud(nodes(ord));
for k = 1:nbtn
    ylabs(k,:) = sprintf(formatNum,ordered_nodes(k));
end

ylim = [0 1];
alfa = 1/(2*NBrowtot);
ydata = [(1-alfa)*ylim(1)+alfa*ylim(2) (1-alfa)*ylim(2)+alfa*ylim(1)];
if NBrowtot==1
    ydata(1) = 1/2; ydata(2) = 1;
end
xlim = [1 NBcoltot];
fig  = figure;
colormap(cool(nb_colors));
axe  = axes('Parent',fig);
set(axe,'XLim',xlim,'YLim',ylim,'NextPlot','replace');
imgcfs = image(...
               'Parent',axe,                       ...
               'XData',(1:NBcoltot),               ...
               'YData',ydata,                      ...
               'CData',matcfs,                     ...
               'UserData',[depths posis ymin ymax] ...
                );
NBdraw  = 0;
for k = 1:nbtn
    d = depths(k);
    z = cfs(deb(k):fin(k));
    z = z(ones(1,2^d),:);
    z = wkeep1(z(:)',NBcoltot);
    if find(colmode==[2 4 6 8])
        z = wcodemat(z,nb_colors,'row',abs_val);
    end
    r1 = ypos(k);
    r2 = ypos(k)+nbrows(k)-1;
    matcfs(r1:r2,:) = z(ones(1,nbrows(k)),:);
    if dmax<=flg_line && nbtn~=1
        line(...
             'Parent',axe,               ...
             'XData',[0.5 NBcoltot+0.5], ...
             'YData',[ymin(k) ymin(k)],  ...
             'LineWidth',2               ...
              );
    end
    NBdraw = NBdraw+1;
    if NBdraw==10 || k==nbtn
        set(imgcfs,'XData',(1:NBcoltot),'YData',ydata,'CData',matcfs);
        NBdraw = 0;
    end
end
ftnsize = get(0,'FactoryTextFontSize');
set(axe, ...
    'YDir','reverse',                ...
    'XLim',xlim,'YLim',ylim,         ...
    'YTick',ytics,'YTickLabel',ylabs,...
    'FontSize',ftnsize,              ...
    'Layer','top',                   ...
    'Box','on');
title(strtit,'Fontsize',ftnsize+1,'FontWeight','bold');
ylabel(getWavMSG('Wavelet:moreMSGRF:Idx_Of_TN'));
xlabel(getWavMSG('Wavelet:moreMSGRF:Time_Space_VAL'));
