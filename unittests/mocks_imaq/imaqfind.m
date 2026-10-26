function found = imaqfind(name, value)
%IMAQFIND Open simulated cameras (capture tests), optionally only those with a property value, e.g. 'Tag'.
%   Like the Image Acquisition Toolbox: without arguments an object array, with a property filter a CELL array.
objects = getappdata(0, 'mock_imaq_objects');
if nargin == 0
    found = videoinput.empty;
else
    found = {};
end
for k = 1:numel(objects)
    obj = objects{k};
    if ~isvalid(obj)
        continue
    end
    if nargin == 0
        found(end + 1) = obj; %#ok<AGROW>
    elseif isequal(obj.(name), value)
        found{end + 1} = obj; %#ok<AGROW>
    end
end
end
