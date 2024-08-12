function varargout = wfigutil(option,fig,in3,in4)
%WFIGUTIL Utilities for figures.
%   XL = WFIGUTIL('xprop',FIG,NBX)
%   YL = WFIGUTIL('yprop',FIG,NBY)
%   [XL,YL] = WFIGUTIL('xyprop',FIG,NBX,NBY)
%   [XL,YL,POS] = WFIGUTIL('prop_size',FIG,NBX,NBY)
%   XL is the normalized value of nbx x_pixels in the figure FIG.
%   YL is the normalized value of nby y_pixels in the figure FIG.
%   POS is the position (in pixels) of the figure FIG.
%
%   POS = WFIGUTIL('pos',FIG) gives position in pixels.
%
%   [LEFT,UP] = WFIGUTIL('left_up',FIG) or
%   [LEFT,UP] = WFIGUTIL('left_up',FIG,DX,DY)
%   gives the left_up corner in pixels or LEFT+DX and UP+DY.        

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

old_units = get(fig,'Units');
set(fig,'Units','Pixels'); 
pos = get(fig,'Position');
switch option
    case 'xprop'     , varargout = {in3/pos(3)};
    case 'yprop'     , varargout = {in3/pos(4)};
    case 'xyprop'    , varargout = {in3/pos(3) , in4/pos(4)};
    case 'prop_size' , varargout = {in3/pos(3) , in4/pos(4) , pos};
    case 'pos'       , varargout = {pos};
    case 'left_up'
        scr = getMonitorSize;
        if nargin==2 , in3 = 0; in4 = 0; end
        varargout = {pos(1)+in3 , scr(4)-pos(2)-pos(4)+in4};
end
set(fig,'Units',old_units); 
