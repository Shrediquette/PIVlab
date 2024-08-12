function [sx,sy] = wp2dcoor(x,y,axe,in4)
%WP2DCOOR Wavelet packets 2-D coordinates.
%   Write function used by DYNVTOOL.
%   [SX,SY] = WP2DCOOR(X,Y,AXE,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Jul-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

sx = sprintf('X = %0.f',round(x));
sy = sprintf('Y = %0.f',round(y));
if axe==in4
    img = findobj(in4,'Type','image');
    if ~isempty(img)
        for k = 1:length(img)
            us = get(img(k),'UserData');
            if (us(3)<x) && (x<us(4)) && (us(5)<y) && (y<us(6))
               sx = ['Ind  : (' sprintf('%.0f',depo2ind(4,[us(1) us(2)])) ')'];
               sy = ['Pack : (' sprintf('%.0f',us(1)) ',' ...
                                       sprintf('%.0f',us(2)) ')'];
               break;
            end
        end
    end
end
