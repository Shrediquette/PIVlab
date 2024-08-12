function varargout = wtbxappdata(option,fig,varargin)
%WTBXAPPDATA Cache for GUIDATA, SETAPPDATA, GETAPPDATA.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 31-Jan-2003.
%   Last Revision: 20-Jul-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

if ~ishandle(fig) , varargout = {[]}; return; end
figDATA = guidata(fig);
nbIN = length(varargin);
switch option
    case {'new','set'} , stepFOR = 2; 
    case {'get','del'} , stepFOR = 1; 
end
for k=1:stepFOR:nbIN
    % dataName  = varargin{k}
    % dataValue = varargin{k+1}
    switch option
        case 'new'
            if ~isfield(figDATA,varargin{k})
                figDATA.(varargin{k}) = varargin{k+1};
                guidata(fig,figDATA);
            end
            
        case 'set' 
            figDATA.(varargin{k}) = varargin{k+1};
            guidata(fig,figDATA);
            
        case 'get'
            if isfield(figDATA,varargin{k})
                varargout{k} = figDATA.(varargin{k});
            else
                varargout{k} = '';
            end
            
        case 'del'
            if isfield(figDATA,varargin{k})
                varargout{k} = figDATA.(varargin{k});
                figDATA = rmfield(figDATA,varargin{k});
                guidata(fig,figDATA);
            else
                varargout{k} = '';
            end
    end
end
