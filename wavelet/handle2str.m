function hstr = handle2str(hdl)
%HANDLE2STR Convert a handle to a string. 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Apr-2013.
%   Last Revision: 02-May-2014.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.1.6.2.4.1 $  $Date: 2014/01/04 07:40:07 $


%###########################################################
%%%    UNDER DEVELOPMENT
%###########################################################
type = get(hdl,'type');
if isequal(type,'figure') && ...
        ~isnumeric(hdl) && isprop(hdl,'Number')
    if isequal(get(hdl,'IntegerHandle'),'on')
        hstr = int2str(hdl.Number);
    else
        hstr = sprintf('%20.15f',double(hdl.Number));
    end
else
    if size(type,1)<2
        % disp(['type = ' type])
    else
    end
    hstr = sprintf('%20.15f',double(hdl));
    % hstr = hstr(~isspace(hstr));
end
%###########################################################
