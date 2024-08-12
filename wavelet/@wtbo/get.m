function varargout = get(O,varargin)
%GET Get WTBO object field contents.
%   [FieldValue1,FieldValue2, ...] = ...
%       GET(O,'FieldName1','FieldName2', ...) returns
%   the contents of the specified field for the WTBO
%   object O.
%
%   [...] = GET(O) returns all the field contents of O.
%
%   The valid choices for 'FieldName' are:
%     'wtboInfo' : Object information
%        (Not used in the current version of the Toolbox)
%     'ud'       : Userdata field
%
%   See also SET.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Aug-2000.
%   Last Revision: 15-Mar-2008.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbin = length(varargin);
if nbin==0 , varargout = struct2cell(struct(O))'; return; end
varargout = cell(nbin,1);
for k=1:nbin
    try
        field = varargin{k}; varargout{k} = O.(field);
    catch ME %#ok<NASGU>
        varargout{k} = 'errorWTBX';
    end
end
