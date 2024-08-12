function [uniqueStrings, modified] = makeUniqueStrings(inStr, excludes, maxStringLength)
%   This function is for internal use only, it may change in a future
%   release.
%   See also MATLAB.LANG.MAKEUNIQUESTRINGS

%   Copyright 2013-2020 The MathWorks, Inc.

% Validate number of inputs.
narginchk(1,3);

% Validate input string.
inputIsChar = false;
if matlab.internal.datatypes.isCharString(inStr)
    inputIsChar = true;
    returnConverter = @char;
elseif (isvector(inStr) || isempty(inStr)) && matlab.internal.datatypes.isCharStrings(inStr, true)
    returnConverter = @cellstr;
elseif isstring(inStr)
    if any(ismissing(inStr))
        error(message('MATLAB:makeUniqueStrings:MissingNames', ...
                      getString(message('MATLAB:string:MissingDisplayText'))));
    end
    returnConverter = @string;
else
    error(message('MATLAB:makeUniqueStrings:InvalidInputStrings'))
end

if isempty(inStr)
    uniqueStrings = inStr;
    if inputIsChar
        modified = false;
    else
        modified = false(size(inStr));
    end
    return;
end
inStr = string(inStr);

% Set/validate EXCLSTRORELEMTOCHK and MAXSTRINGLENGTH.
[~, maxArraySize] = computer;
if nargin < 3
    maxStringLength = maxArraySize;
else
    maxStringLength = validateMaxStringLength(maxStringLength, maxArraySize);
end

if nargin < 2
    exclStrOrElemToChk = string.empty;
else
    exclStrOrElemToChk = validateExclStrOrElemToChk(excludes, inStr);
end

% Process differently for 2nd option as checkElements or stringsToProtect.
if isnumeric(exclStrOrElemToChk) || islogical(exclStrOrElemToChk) % checkElements
    
    % Construct stringsToCheck from STRINGS that need to be made unique.
    stringsToCheck = inStr(exclStrOrElemToChk);
    
    % Truncate only the stringsToCheck.
    if nargout > 1
        truncated = false(size(inStr));
    end
    if maxStringLength < maxArraySize
        [stringsToCheck, truncated(exclStrOrElemToChk)] = truncateString(stringsToCheck, maxStringLength);
    end
    
    % Construct stringsToProtect from STRINGS that should not be modified.
    if islogical(exclStrOrElemToChk)
        stringsToProtect = inStr(~exclStrOrElemToChk);
    else % exclStrOrElemToChk is indices
        stringsToProtect = inStr(setdiff(1:numel(inStr),exclStrOrElemToChk));
    end
    
    % Make stringsToCheck unique against itself and stringsToProtect.
    [stringsChecked, modifiedInStringsChecked] = ...
        makeUnique(stringsToCheck, stringsToProtect, maxStringLength);
    
    % Combine the protected subset of strings with the checked subset.
    uniqueStrings = inStr;
    uniqueStrings(exclStrOrElemToChk) = stringsChecked;
    
    % Compute the positions of modified strings in the now completed set.
    if nargout > 1
        uniquified = false(size(inStr));
        uniquified(exclStrOrElemToChk) = modifiedInStringsChecked;
    end
else % stringsToProtect
    if maxStringLength < maxArraySize
        [inStr, truncated] = truncateString(inStr, maxStringLength);
    elseif nargout > 1
        truncated = false(size(inStr));
    end    
    [uniqueStrings, uniquified] = ...
        makeUnique(inStr, exclStrOrElemToChk, maxStringLength);
end

if maxStringLength == 0 && inputIsChar
    uniqueStrings = char(zeros(1, 0));
    modified = true;
    return;
end

uniqueStrings = returnConverter(uniqueStrings);
if nargout > 1
    modified = truncated | uniquified;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  HELPERS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [str, uniquified] = makeUnique(str, stringsToProtect, maxStringLength)
szStrings = size(str);
uniquified = false(szStrings);
numStrings = numel(str);
[str, sortIdx] = sort(reshape(str, 1, []));
inverseSortIdx(sortIdx) = 1:numStrings;
stringsToProtect = reshape(stringsToProtect, 1, []);

% Find where there are groups of duplicates by comparing two sorted strings
% having a one-element shift.
isDuplicateOfPrevious = [false(min(1, numStrings)), strcmp(str(1:end-1), str(2:end))];
isDuplicateOfPreviousDiff = diff([isDuplicateOfPrevious, false]);
isDuplicateStart = (isDuplicateOfPreviousDiff > 0);
isDuplicateStopIdx = find(isDuplicateOfPreviousDiff < 0);

% Find where groups of protected strings start.
isProtectedStart = false(1, numStrings);
% For performance, only call ismember if there are elements in both stringsToProtect
% and in str to compare to each other.  This is important for the case when
% maxStringLength is needed but where the second input is {}.
if ~isempty(stringsToProtect) && any(~isDuplicateOfPrevious)
    isProtectedStart(~isDuplicateOfPrevious) = ismember(str(~isDuplicateOfPrevious), stringsToProtect);
end

duplicateNum = 1;
for changeIdx = find(isDuplicateStart | isProtectedStart)
    if isDuplicateStart(changeIdx) && isProtectedStart(changeIdx)
        startIdx = changeIdx;
        stopIdx = isDuplicateStopIdx(duplicateNum);
        duplicateNum = duplicateNum + 1;
    elseif isDuplicateStart(changeIdx)
        startIdx = changeIdx + 1;
        stopIdx = isDuplicateStopIdx(duplicateNum);
        duplicateNum = duplicateNum + 1;
    else % isProtectedStartIdx(changeIdx)
        startIdx = changeIdx;
        stopIdx = changeIdx;
    end
    try
        str(startIdx:stopIdx) = makeNameUnique(str, startIdx, stopIdx, stringsToProtect, maxStringLength);
    catch ex
        throwAsCaller(ex);
    end
    uniquified(startIdx:stopIdx) = true;
end

% Unsort and reshape the now unique STRINGS and MODIFIED to match how
% STRINGS was input.
str = reshape(str(inverseSortIdx), szStrings);
uniquified = uniquified(inverseSortIdx);
end

function stringsToChange = makeNameUnique(str, startIdx, stopIdx, stringsToProtect, maxStringLength)
stringsToChange = str(startIdx:stopIdx);
stringsToKeep = str;
stringsToKeep(startIdx:stopIdx) = [];
namesToCheck = [stringsToChange, stringsToKeep(startIdx:end), stringsToProtect];

while true
    baseName = stringsToChange(1);
    candidateVarNums = findNumbersToAppend(baseName, namesToCheck, numel(stringsToChange));
    baseNameLength = strlength(baseName);
    appendLength = 1 + strlength(string(candidateVarNums(end)));
    if appendLength > (maxStringLength - min(1, baseNameLength))
        % The append itself violates the limit imposed by maxStringLength.
        % Note that, if the name is not empty, its first character must be
        % preserved.
        error(message('MATLAB:makeUniqueStrings:CannotMakeUnique'));
    elseif appendLength > (maxStringLength - baseNameLength)
        % The name must be truncated.
        % This invalidates the previous calculation, since the new name
        % will likely conflict with a different set of names, some of
        % which might be lexigraphically less than the old name.
        stringsToChange = truncateString(stringsToChange, maxStringLength - appendLength);
        namesToCheck = [stringsToChange, stringsToKeep, stringsToProtect];
    else
        % Append can be done without needing to truncate.
        stringsToChange = baseName + "Copy" + candidateVarNums;
        break;
    end
end
end

function [str, truncateIdx] = truncateString(str, maxStringLength)
truncateIdx = (strlength(str) > maxStringLength);
str(truncateIdx) = extractBefore(str(truncateIdx), 1 + maxStringLength);
end

function appendValues = findNumbersToAppend(baseName, namesToCheck, numAppendValues)
namesToGuard = startsWith(namesToCheck, baseName + "Copy");
protectedNums = double(extractAfter(namesToCheck(namesToGuard), strlength(baseName)+1));
protectedNums(isnan(protectedNums)) = [];
appendValues = setdiff(1:numel(namesToCheck), protectedNums);
appendValues(numAppendValues+1:end) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%  INPUT VALIDATION HELPERS %%%%%%%%%%%%%%%%%%%%%%%%
function exclStrOrElemToChk = validateExclStrOrElemToChk(exclStrOrElemToChk, inputStr)
% Validate EXCLUDEDSTRINGS or ELEMENTSTOCHECK.
if matlab.internal.datatypes.isCharString(exclStrOrElemToChk) ...
        || ((isvector(exclStrOrElemToChk) || isempty(exclStrOrElemToChk)) ...
             && matlab.internal.datatypes.isCharStrings(exclStrOrElemToChk,true))
    % exclStrOrElemToChk is a (potentially empty) char vector or cellstr.
    exclStrOrElemToChk = string(exclStrOrElemToChk);
elseif isnumeric(exclStrOrElemToChk) && ~any(mod(exclStrOrElemToChk,1))
    % Assume exclStrOrElemToChk is checkElements intended to be a range or
    % linear indices into STRINGS.
    if isempty(exclStrOrElemToChk)
        % Nothing to check for uniqueness.
        exclStrOrElemToChk = false(size(inputStr));
    elseif max(exclStrOrElemToChk) > numel(inputStr)
        % checkElements exceed the range of STRINGS number of elements.
        error(message('MATLAB:makeUniqueStrings:OutOfBoundRange'));
    elseif min(exclStrOrElemToChk)<=0 || any(isnan(exclStrOrElemToChk))
        % Elements of the range must be positive.
        error(message('MATLAB:makeUniqueStrings:NonPositiveRange'));
    end
elseif islogical(exclStrOrElemToChk)
    % Assume exclStrOrElemToChk is checkElements when exclStrOrElemToChk is
    % a logical array; the logical indices array must be the same length as
    % STRINGS.
    if ~isequal(numel(exclStrOrElemToChk), numel(inputStr))
        error(message('MATLAB:makeUniqueStrings:BadLengthLogicalMask'));
    end
elseif ~isstring(exclStrOrElemToChk)
    % Though they are useless here, <missing> string values are allowed.
    error(message('MATLAB:makeUniqueStrings:InvalidFirstOptionalArg'));
end
end

function maxStringLength = validateMaxStringLength(maxStringLength, maxArraySize)
% Validate MAXSTRINGLENGTH, which must be a scalar, non-negative integer.
if isnumeric(maxStringLength) && isscalar(maxStringLength) && ~any(mod(maxStringLength,1)) && maxStringLength>=0    
    maxStringLength = min(maxStringLength, maxArraySize); % Cap maxStringLength at maxArraySize.
else     
    error(message('MATLAB:makeUniqueStrings:BadMaxStringLength'));
end
end
