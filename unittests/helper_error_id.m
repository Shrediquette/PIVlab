function [id, msg] = helper_error_id(fun, varargin)
%HELPER_ERROR_ID Identifier (and message) of the error of fun(varargin{:}), '' if there is none.
%   fun is the name of the function as text, e.g. 'pivlab.analyze'.
id = '';
msg = '';
try
    feval(fun, varargin{:});
catch err
    id = err.identifier;
    msg = err.message;
end
end
