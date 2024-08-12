function varargout = wplothis(axe,pcoor,cfill,cline)
%WPLOTHIS Plots histogram obtained with WGETHIST.
%   WPLOTHIS(A,P,CFILL,CLINE) or
%   WPLOTHIS(A,P,CFILL) or
%   WPLOTHIS(A,P)
% 
%   A       = axes handle.
%   P(1,:)  = X coordinates of points of histogram.
%   P(2,:)  = Y coordinates of points of histogram.
%   CFILL   = color for filling histogram.
%   CLINE   = line color.
%
%   See also WGETHIST.
  
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 11-Jul-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
% $Revision: 1.11.4.4 $

if nargin==2, cfill = 'r'; end
old_units = get(axe,'Units');
set(axe,'Units','pixels'); 
pos = get(axe,'Position');
set(axe,'Units',old_units); 
nb_clas = size(pcoor,2)/4;
mx_clas = pos(3)/3;
if nargin==4 || nb_clas>mx_clas
    plot_line = 1;
    if nb_clas>mx_clas , cline = cfill; end
else
    plot_line = 1; cline = 'k';
end
tag_axe = get(axe,'Tag');
hdl_fil = fill(pcoor(1,:),pcoor(2,:),cfill,'Parent',axe);
hdl_lin = [];
if plot_line
    set(axe,'NextPlot','Add');
    hdl_lin = plot(pcoor(1,:),pcoor(2,:),'Color',cline,'Parent',axe);
    set(axe,'NextPlot','Replace');
end
set(axe,'Units','Normalized'); 
h = get(axe,'Position');
n = 5*h(4);
yaxis = [0 max(pcoor(2,:))];
dval  = (yaxis(2)-yaxis(1))/(100*n);
yaxis = yaxis + [-dval dval];
if yaxis(1)==yaxis(2) ,  yaxis = yaxis+[-0.01 0.01]; end

xaxis = [min(pcoor(1,:)) max(pcoor(1,:))];
dval  = (xaxis(2)-xaxis(1))/100;
xaxis = xaxis + [-dval dval];
if xaxis(1)==xaxis(2) , xaxis = xaxis+[-0.01 0.01]; end
set(axe,'XLim',xaxis,'YLim',yaxis);
set(axe,'Units',old_units,'Tag',tag_axe);
if nargout>0 , varargout{1} = [hdl_fil;hdl_lin]; end
