function imaqreset()
%IMAQRESET Closes all simulated cameras (capture tests).
objects = getappdata(0, 'mock_imaq_objects');
for k = 1:numel(objects)
    if isvalid(objects{k})
        delete(objects{k});
    end
end
setappdata(0, 'mock_imaq_objects', {});
end
