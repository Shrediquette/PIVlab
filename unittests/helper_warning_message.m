function msg = helper_warning_message(id, fun, varargin)
%HELPER_WARNING_MESSAGE Message of the warning id issued by fun(varargin{:}), '' if there is none.
%   (evalc does not see warnings in matlab -batch: they go to stderr. lastwarn also records
%   warnings that are switched off, so fun must not issue other warnings after this one.)
state = warning;
warning('off', 'all');
warning('on', id);
lastwarn('');
try
    feval(fun, varargin{:});
catch err
    warning(state);
    rethrow(err);
end
[msg, last] = lastwarn;
warning(state);
if ~strcmp(last, id)
    msg = '';
end
end
