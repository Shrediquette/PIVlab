function varargout = get(P,varargin)
%GET Get LP object field contents.
%   [FieldValue1,FieldValue2, ...] = ...
%       GET(P,'FieldName1','FieldName2', ...) returns
%   the contents of the specified fields for the LP object P.
%
%   [...] = GET(P) returns all the field contents of P.
%
%   The valid choices for 'FieldName' are:
%     'maxDEG' - maximal degree of monomials
%     'coefs'  - Row Vector of coefficients 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Apr-2001.
%   Last Revision: 18-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbin = length(varargin);
if nbin==0 , varargout = struct2cell(struct(P))'; return; end
varargout = cell(nbin,1);
for k=1:nbin
    field = varargin{k};
    try
      varargout{k} = P.(field);
    end
end
