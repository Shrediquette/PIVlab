function data = calibration_data()
% The data of the calibration that is not a control: the end points of the reference distance
% and the offset points. Stored in settings files and sessions together with the settings of
% the group 'calibration' (reference length, time step, axis directions).
data.pointscali = gui.retr('pointscali');
data.points_offsetx = gui.retr('points_offsetx');
data.points_offsety = gui.retr('points_offsety');
data.size_of_the_image = gui.retr('size_of_the_image');
end
