function varargout = wconvertStringsToChars(varargin)
% This function is for internal use only. It may change or be removed in a
% a future release.
% This function converts all scalar strings to chars. It is not intended
% to handle vector strings. It should also look inside of cell arrays and
% structure arrays.

%   Copyright 2018-2020 The MathWorks, Inc.

Numinputs = nargin;
for kk = 1:Numinputs
    if iscell(varargin{kk})
        varargin{kk} = convertCellElementsToChars(varargin{kk});
    elseif isstruct(varargin{kk})
        varargin{kk} = convertStructFieldsToChars(varargin{kk});
    elseif ~iscell(varargin{kk}) && ~isstruct(varargin{kk}) ...
            && isStringScalar(varargin{kk})
        varargin{kk} = convertStringsToChars(varargin{kk});
    end
end

varargout = cell(size(varargin));
for nout = 1:nargout
    varargout{nout} = varargin{nout};
    
end




%-------------------------------------------------------------------------
function A = convertCellElementsToChars(A)
% Convert all scalar strings in a cell array to chars. This will also look
% inside structure arrays.

% Obtain number of elements in cell array
N = numel(A);
for numelem = 1:N
    if isStringScalar(A{numelem})
        A{numelem} = convertStringsToChars(A{numelem});
    elseif iscell(A{numelem})
        A{numelem} = convertCellElementsToChars(A{numelem});
    elseif isstruct(A{numelem})
        A{numelem} = convertStructFieldsToChars(A{numelem});
    end
end


function A = convertStructFieldsToChars(A)
% Convert all scalar strings in a structure array to chars.

% See if it is an array of structs. This can occur in lifting for example

Nstruct = numel(A);
for ns = 1:Nstruct
    Atmp = A(ns);
    Names = fieldnames(Atmp);
    for kk = 1:numel(Names)
        currentval = Atmp.(Names{kk});
        if isStringScalar(currentval)
            Atmp.(Names{kk}) = convertStringsToChars(Atmp.(Names{kk}));
        elseif iscell(currentval)
            Atmp.(Names{kk}) = ...
                convertCellElementsToChars(Atmp.(Names{kk}));
        elseif isstruct(currentval)
            Atmp.(Names{kk}) = ...
                convertStructFieldsToChars(Atmp.(Names{kk}));
        end
    end
    A(ns) = Atmp;
end














