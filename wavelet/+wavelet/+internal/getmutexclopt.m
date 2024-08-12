function [opt, arglist] = getmutexclopt(validopts,defaultopt,arglist)
%GETMUTEXCLOPT - get any of the specified mutually exclusive options and
% remove from the argument list.  Allows initial matches.
%
%   This function is for internal purposes only and may be removed in a
%   future release.
%
%   validopts  - a string vector of valid options
%                 (e.g. ["power","psd"]
%
%   defaulttype - the default option to use if no type is found
%
%   arglist    - the input argument list
%
%   Errors out if different estimation types are matched in the arglist.
%
%   See also CHKUNUSEDOPT.

%   Copyright 2016-2020 The MathWorks, Inc.



opt = defaultopt;
found = false;

iarg = 1;
while iarg <= numel(arglist)
    arg = arglist{iarg};
    if ischar(arg) || (isstring(arg) && isscalar(arg))
        arg = string(arg);
        matches = find(strncmpi(arg,validopts,strlength(arg)), 1);
        if ~isempty(matches)
            if ~found
                found = true;
                opt = validopts(matches(1));
                arglist(iarg) = [];
            else
                error(message('Wavelet:FunctionInput:ConflictingOptions', ...
                    char(opt),char(validopts(matches(1)))));
            end
        else
            iarg = iarg + 1;
        end
    else
        iarg = iarg + 1;
    end
end


