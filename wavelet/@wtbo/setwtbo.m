function O = setwtbo(O,varargin)
%SETWTBO Set object field contents.
%   O = SETWTBO(O,'FieldName1','FieldValue1','FieldName2','FieldValue2' ...)
%   sets the contents of the specified fields for any object O
%   in the Wavelet Toolbox.
%
%   First, the search is done in O. If it fails, the
%   subobjects and substructures fields are examined.
%
%   Caution: Don't use the SETWTBO function!

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Jun-97.
%   Last Revision: 17-Sep-1999.
%   Copyright 1995-2020 The MathWorks, Inc.

O = wsfields(Inf,O,varargin{:});
