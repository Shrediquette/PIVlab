function s = session_extras(s, data)
% settings that a session stores as data: region of interest, velocity limits and the
% calibration factors (a session made by pivlab.toMetric may have no reference distance)
if isfield(data,'roirect')
    s.preprocess.Roi = data.roirect;
end
if isfield(data,'velrect') && numel(data.velrect) == 4
    r = double(data.velrect); % [umin vmin width height] in calibrated units
    s.filter.VelocityLimits = [r(1) r(1)+r(3) r(2) r(2)+r(4)];
end
c = s.calibration;
for n = {'calxy','calu','calv','offset_x_true','offset_y_true'}
    if isfield(data, n{1}) && ~isempty(data.(n{1}))
        c.(n{1}) = double(data.(n{1}));
    end
end
if isfield(data,'displacement_only') && ~isempty(data.displacement_only)
    c.displacement_only = logical(data.displacement_only);
end
s.calibration = c;
% velocity / notch limits stored in PIVlab files are in calibrated units
if ~((c.calu==1 || c.calu==-1) && c.calxy==1)
    s.filter.LimitUnits = "calibrated";
end
end
