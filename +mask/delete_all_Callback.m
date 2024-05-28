function delete_all_Callback(~,~,~)
gui.put('masks_in_frame',[])
delete(findobj('UserData','ROI_object_freehand'));
delete(findobj('UserData','ROI_object_rectangle'));
delete(findobj('UserData','ROI_object_circle'));
delete(findobj('UserData','ROI_object_polygon'));
delete(findobj('UserData','ROI_object_external'));
gui.sliderdisp(gui.retr('pivlab_axis'));

