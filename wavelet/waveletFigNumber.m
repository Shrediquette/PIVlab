function num = waveletFigNumber(fig)
%waveletFigNumber Return the number associated to a figure. 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Jun-2013.
%   Last Revision: 11-Jul-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2013/08/23 23:45:14 $


%###########################################################
%%%    UNDER DEVELOPMENT
%###########################################################
type = get(fig,'type');
if isequal(type,'figure') && ~isnumeric(fig)
    if isprop(fig,'Number')
        num = fig.Number;
    else
        num = fig;
    end
else
    num = fig;
end
%###########################################################
