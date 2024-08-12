function [cp,xlim,ylim] = waxecp(~,axe)
%WAXECP BUG for axes CurrentPoint property.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-Feb-98.
%   Last Revision: 20-Jul-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% We suppose that fig and axes use same units.
%---------------------------------------------
xlim = get(axe,'XLim');
ylim = get(axe,'YLim');
cp   = get(axe,'CurrentPoint');
cp   = cp(1,1:2);
