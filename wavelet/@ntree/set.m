function [t,ME] = set(t,varargin)
%SET Set NTREE object fields contents.
%   T = SET(T,'FieldName1',FieldValue1,'FieldName2',FieldValue2,...)
%   sets the contents of the specified fields for the NTREE object T.
%   
%   The valid choices for 'FieldName' are:
%     'wtbo'  : wtbo parent object
%     'order' : Order of tree
%     'depth' : Depth of tree
%     'spsch' : Split scheme for nodes
%     'tn'    : Array of terminal nodes of tree
%
%   Or fields in WTBO object:
%     'wtboInfo' : Object information
%     'ud'       : Userdata field
%
%   Caution: Use the SET function only for the field 'ud'.
%
%   See also DISP, GET.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Aug-2000.
%   Last Revision: 15-Mar-2008.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbin = length(varargin);
for k=1:2:nbin
    field = varargin{k};
    try
        t.(field) = varargin{k+1};
        ME = [];
    catch ME    %#ok<NASGU>
        [t.wtbo,ME] = set(t.wtbo,field,varargin{k+1});
    end
end
