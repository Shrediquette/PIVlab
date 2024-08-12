function h = wfindobj(varargin)
%WFINDOBJ Find objects with specified property values.
%    H = WFINDOBJ('P1Name',P1Value,...) returns the handles of the
%    objects at the root level and below whose property values
%    match those passed as param-value pairs to the WFINDOBJ
%    command.
% 
%    H = WFINDOBJ(ObjectHandles, 'P1Name', P1Value,...) restricts
%    the search to the objects listed in ObjectHandles and their
%    descendants.
% 
%    H = WFINDOBJ(ObjectHandles, 'flat', 'P1Name', P1Value,...)
%    restricts the search only to the objects listed in
%    ObjectHandles.  Their descendants are not searched.
% 
%    H = WFINDOBJ returns the handles of the root object and all its
%    descendants.
% 
%    H = WFINDOBJ(ObjectHandles) returns the handles listed in
%    ObjectHandles, and the handles of all their descendants.
%
%    H = WFINDOBJ('figure','P1Name',P1Value,...) is equivalent to
%    H = WFINDOBJ(get(0,'Children'),'flat', 'P1Name', P1Value,...)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-96.
%   Last Revision: 25-Apr-2007.
%   Copyright 1995-2020 The MathWorks, Inc.

nbinput  = nargin;
old_show = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
switch nbinput
    case 0
        h = findobj;

    case 1
        h = varargin{1};
        if isequal(lower(h),'figure')
           h = get(0,'Children');
        else 
           h = findobj(h);
        end

    otherwise
        h = varargin{1};
        if  ~ischar(h)
            h = findobj(h,varargin{2:nbinput});
        elseif isequal(lower(h),'figure')
            h = get(0,'Children'); 
            h = findobj(h,'flat',varargin{2:nbinput});
        else
            h = findobj(0,varargin);
        end
end
set(0,'ShowHiddenHandles',old_show);
