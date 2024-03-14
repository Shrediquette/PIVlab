function validate_clear_vel_limit_Callback(~, ~, ~)
gui.gui_put('velrect', []);
handles=gui.gui_gethand;
set (handles.vel_limit_active, 'String', 'Limit inactive', 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
set (handles.limittext, 'String', '');
set (handles.vel_limit, 'String', 'Select velocity limits');

