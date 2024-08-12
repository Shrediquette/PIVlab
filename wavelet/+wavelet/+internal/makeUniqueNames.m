function newlabel = makeUniqueNames(existlabels,copiedlabel)
%   This function is for internal use only, it may change in a future
%   release.
%   Convert labels to strings. This is just a wrapper on MATLAB's
%   makeUniqueStrings()

%   Copyright 2017-2020 The MathWorks, Inc.

copiedlabel = strrep(copiedlabel,'Copy','_');
existlabels = string(existlabels);

% Find existing '_' in name
underscores = strfind(copiedlabel,'_');
if iscell(underscores)
    underscores = cell2mat(underscores);
    underscores = max(underscores);
else
    underscores = max(underscores);
end
% Replace existing 'Copy' with '_'
replaceCopy = strrep(existlabels,'Copy','_');
uniqueNames = matlab.lang.makeUniqueStrings(replaceCopy,copiedlabel);
% Now replace the underscore with 'Copy'
diffset = setdiff(uniqueNames,replaceCopy);
if any(underscores)
    diffset = char(diffset);
    prefix = diffset(1:underscores);
    postfix = diffset(underscores+1:end);
    replaceUnderScore = strrep(postfix,'_','Copy');
    newlabel = deblank(strcat(prefix,replaceUnderScore));
elseif ~any(underscores)
    replaceUnderScore = strrep(diffset,'_','Copy');
    newlabel = char(deblank(replaceUnderScore));
end

