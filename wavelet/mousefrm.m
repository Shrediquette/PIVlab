function mousefrm(h,forme)
%MOUSEFRM Change mouse aspect.
%   MOUSEFRM(H,F)
%   H = figure handles or figure number.
%   F = char vector for pointer aspect : 'arrow', 'watch', ....


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
% $Revision: 1.12.4.2 $

narginchk(2,2)

if ~ishandle(h) || isempty(findobj(h, 'flat', 'Type', 'Figure'))
    return;
end
set(h,'Pointer',forme);




