function varargout = getwtbo(O,varargin)
%GETWTBO Get object field contents.
%   [FieldValue1,FieldValue2, ...] = ...
%       GETWTBO(O,'FieldName1','FieldName2', ...) returns
%   the contents of the specified fields for any object O
%   in the Wavelet Toolbox.
%
%   First, the search is done in O. If it fails, the
%   subobjects and substructures fields are examined.
%
%   Examples:
%     t = ntree(2,3);   % t is a NTREE object.
%     [o,wtboInfo,tn,depth] = getwtbo(t,'order','wtboInfo','tn','depth');
%
%     t = wpdec(rand(1,120),3,'db3');  % t is a WPTREE object.
%     [o,tn,Lo_D,EntName] = getwtbo(t,'order','tn','Lo_D','EntName');

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Jun-97.
%   Last Revision: 17-Sep-1999.
%   Copyright 1995-2020 The MathWorks, Inc.

nbArg = length(varargin);
[varargout{1:nbArg}] = wgfields(Inf,O,varargin{:});
