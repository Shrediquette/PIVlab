function callback = cwtselect(ax)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jul-2010.
%   Last Revision: 10-Jun-2013.

%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2013/07/05 04:29:47 $ 

callback = @(o,e)changeMOUSE(o,e,ax);

function changeMOUSE(~,~,ax) 

% fig = e.HitObject;
% fig = get(ax,'Parent');
fig = ancestor(ax,'figure');

handles = guihandles(fig);
cwtftbtn('down',fig,ax,handles.Pus_MAN_DEL)
