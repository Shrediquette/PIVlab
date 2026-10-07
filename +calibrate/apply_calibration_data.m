function apply_calibration_data(data)
% Restores the calibration from its data (calibrate.calibration_data) and the calibration
% controls (reference length, time step, axis directions), which must already be set.
% Computes the calibration factors like "Apply calibration", without dialogs.
handles = gui.gethand;
names = {'pointscali', 'points_offsetx', 'points_offsety', 'size_of_the_image'};
for k = 1:numel(names)
    if isfield(data, names{k})
        gui.put(names{k}, data.(names{k}));
    else
        gui.put(names{k}, []);
    end
end
pointscali = gui.retr('pointscali');
time_inp = str2double(get(handles.time_inp, 'String'));
if isempty(pointscali)
    gui.put('calxy', 1);
    gui.put('calu', 1);
    gui.put('calv', 1);
    gui.put('offset_x_true', 0);
    gui.put('offset_y_true', 0);
    gui.put('displacement_only', double(time_inp == 0));
    if gui.retr('darkmode')
        bg_col = [35/255 35/255 35/255];
    else
        bg_col = [0.9411764705882353 0.9411764705882353 0.9411764705882353];
    end
    set(handles.calidisp, 'string', 'inactive', 'backgroundcolor', bg_col);
else
    cal = calibrate.compute_calibration(pointscali, str2double(get(handles.realdist, 'String')), time_inp, ...
        get(handles.x_axis_direction, 'Value'), get(handles.y_axis_direction, 'Value'), ...
        gui.retr('points_offsetx'), gui.retr('points_offsety'), gui.retr('size_of_the_image'));
    gui.put('calxy', cal.calxy);
    gui.put('calu', cal.calu);
    gui.put('calv', cal.calv);
    gui.put('offset_x_true', cal.offset_x_true);
    gui.put('offset_y_true', cal.offset_y_true);
    gui.put('displacement_only', cal.displacement_only);
    calibrate.update_green_calibration_box(cal.calxy, cal.calu, cal.offset_x_true, cal.offset_y_true, handles);
end
gui.put('derived', []); % derived parameters were computed with the previous calibration
calibrate.pixeldist_changed_Callback(); % shows the length of the reference distance in px
gui.update_dependent_controls(handles); % offsets panel needs a reference distance
end
