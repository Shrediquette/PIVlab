function varargout = get(t,varargin)
%GET Get WDECTREE object field contents.
%   [FieldValue1,FieldValue2, ...] = ...
%       GET(T,'FieldName1','FieldName2', ...) returns
%   the contents of the specified fields for the WDECTREE
%   object T.
%   For the fields, which are objects or structures, you
%   may get subfield contents (see DTREE/GET).
%
%   [...] = GET(T) returns all the field contents of T.
%
%   The valid choices for 'FieldName' are:
%   'dtree' - Parent object
%   'typData' - Type of data.
%   'dimData' - Dimension of data.
%   'WT_Settings' - Structure of Wavelet Transform Settings.
%     'typeWT'  - type of Wavelet Transform.
%     'wname'   - Wavelet Name.
%     'extMode' - DWT extension mode.
%     'shift'   - DWT shift value.
%     'Filters' - Structure of filters
%        'Lo_D' - Low Decomposition filter
%        'Hi_D' - High Decomposition filter
%        'Lo_R' - Low Reconstruction filter
%        'Hi_R' - High Reconstruction filter
%
%   Or fields in DTREE parent object.
%   Type help dtree/get for more information on other
%   valid choices for 'FieldName'.
%
%   See also DTREE/READ, DTREE/SET, DTREE/WRITE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 15-Mar-2008.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbin = length(varargin);
if nbin==0 , varargout = struct2cell(struct(t))'; return; end
varargout = cell(nbin,1);
okArg = ones(1,nbin);
for k=1:nbin
    field = varargin{k};
    try
      varargout{k} = t.(field);
    catch ME %#ok<NASGU>
      varargout{k} = get(t.dtree,field);
      if isequal(varargout{k},'errorWTBX') , okArg(k) = 0; end
    end    
end
notOk = find(okArg==0);
if ~isempty(notOk)
    [varargout{notOk}] = getwtbo(t,varargin{notOk});
end
