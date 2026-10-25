function found = imaqfind(name, value)
%IMAQFIND Open simulated cameras (capture tests), optionally only those with a property value, e.g. 'Tag'.
objects = getappdata(0, 'mock_imaq_objects');
found = videoinput.empty;
for k = 1:numel(objects)
    obj = objects{k};
    if ~isvalid(obj)
        continue
    end
    if nargin < 2 || isequal(obj.(name), value)
        found(end + 1) = obj; %#ok<AGROW>
    end
end
end
