function wsetxlab(axe,strxlab,col,vis)
%WSETXLAB Plot xlabel.
%    WSETXLAB(AXE,STRXLAB,COL,VIS)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 25-Jan-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

xlab = get(axe,'Xlabel');
if nargin<4  
    vis = 'on';
    if nargin<3 , col = get(xlab,'Color'); end
end
set(xlab,...
        'String',strxlab, ...
        'Visible',vis, ...
        'FontSize',get(axe,'FontSize'),...
        'Color',col ...
        );
