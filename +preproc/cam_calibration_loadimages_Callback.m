function cam_calibration_loadimages_Callback(~, ~, ~)
filepath=gui.retr('filepath');
if size(filepath,1) >1
    handles=gui.gethand;
    [cam_selected_target_images,location]=uigetfile(...
        {'*.bmp;*.tif;*.tiff;*.jpg;*.png','Image files';
        '*.bmp','Bitmaps'; ...
        '*.tif;*.tiff','TIF'; ...
        '*.jpg','JPEG'; ...
        '*.png','PNG'; ...
        '*.*',  'All Files'}...
        ,"MultiSelect","on",'Select images of the calibration target',gui.retr('pathname'));
    if ~isempty(cam_selected_target_images)
        pathfiles=fullfile(location,cam_selected_target_images);
        gui.put('cam_selected_target_images',pathfiles)
        handles.calib_usecalibration.Value = 0;
    end
else
    gui.custom_msgbox('error',getappdata(0,'hgui'),'No PIV images','You need to load some PIV images first.','modal');
end