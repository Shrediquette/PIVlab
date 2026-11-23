function tf = gui_active
%GUI_ACTIVE True when the PIVlab window holds two cameras combined into one larger image (2D data set).
%   tf = fov.gui_active
% The data set is then a normal 2D data set of camera 1; camera 2 and the 3D alignment are in
% gui.retr('fov_calib') / gui.retr('fov_src2'), the maps in gui.retr('fov_maps') (fov.update_maps).
tf = ~isequal(gui.retr('stereomode'), 1) && ~isempty(gui.retr('fov_calib')) && ~isempty(gui.retr('fov_src2'));
end
