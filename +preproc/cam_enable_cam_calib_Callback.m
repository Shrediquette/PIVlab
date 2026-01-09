function cam_enable_cam_calib_Callback(caller,~,~)
handles=gui.gethand;
filepath=gui.retr('filepath');
if size(filepath,1) <= 1 && handles.calib_usecalibration.Value == 1 %did the user load piv images?
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','No PIV images were loaded.','modal');
    handles.calib_usecalibration.Value = 0;
    return
end
cameraParams=gui.retr('cameraParams');
if isempty (cameraParams)
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','"Estimate cam parameters" or "Load parameters" needs to be performed first','modal');
    handles.calib_usecalibration.Value = 0;
    return
end
cam_selected_target_images = gui.retr('cam_selected_target_images');

if ~strcmpi(caller,'calib_viewtype')
    res=gui.custom_msgbox('msg',getappdata(0,'hgui'),'Warning','Masks, ROI, background images, and results will be reset when changing this setting. Continue?','modal',{'OK','Cancel'},'OK');
else
    res='OK';
end
if ~strcmpi(res,'OK')
    if handles.calib_usecalibration.Value == 1
        handles.calib_usecalibration.Value = 0;
    else
        handles.calib_usecalibration.Value = 1;
    end
    return
end

if handles.calib_usecalibration.Value == 1
    gui.toolsavailable(0,'Applying undistortion...');drawnow;
end
if ~isempty (cameraParams) && ~isempty(cam_selected_target_images)
    %disp('muss bei jeder Änderung eigentlich masken löschen, ROI löschen, ergebnisse löschen...')
    gui.put ('resultslist', []); %clears old results
    gui.put ('derived',[]);
    gui.put('displaywhat',1);%vectors
    gui.put('ismean',[]);
    gui.put('framemanualdeletion',[]);
    gui.put('manualdeletion',[]);
    gui.put('streamlinesX',[]);
    gui.put('streamlinesY',[]);
    gui.put('bg_img_A',[]);
    gui.put('bg_img_B',[]);
    set(handles.bg_subtract,'Value',1);
   % set(handles.fileselector, 'value',1);
    set(handles.minintens, 'string', 0);
    set(handles.maxintens, 'string', 1);
    roi.clear_roi_Callback
    gui.put('masks_in_frame',[]);
end
if handles.calib_usecalibration.Value == 1
    if ~isempty (cameraParams) && ~isempty(cam_selected_target_images)
        gui.put('cam_use_calibration',1);
    else
        gui.put('cam_use_calibration',0);
        handles.calib_usecalibration.Value = 0;
    end
else
    gui.put('cam_use_calibration',0);
end

%% check what the image size will be after image undistortion
if handles.calib_usecalibration.Value ==1
    
    handles.calib_userectification.Value =0; %new cam calib disables existing rectification.
    gui.put('cam_use_rectification',0);
    
    % wir müssen hier schon das erste Bild laden um die echte Dateigröße zu bekommen. Dann berechnen wie sich die ändert, dann expected image size setzen.
    gui.put('cam_use_calibration',0); %so we get the raw image without any undistortion
    [currentimage,~] = import.get_img(1);
    gui.put('cam_use_calibration',1);
    expected_image_size_before_calibration = size(currentimage(:,:,1));

    if strcmpi (class(cameraParams),'cameraParameters')
        cam_calibration_performed_for_size= cameraParams.ImageSize;
    elseif strcmpi (class(cameraParams),'fisheyeParameters')
        cam_calibration_performed_for_size=cameraParams.Intrinsics.ImageSize;
    end
    if cam_calibration_performed_for_size(1) ~= expected_image_size_before_calibration(1) || cam_calibration_performed_for_size(2) ~= expected_image_size_before_calibration(2)
        gui.put('cam_use_calibration',0);
        handles.calib_usecalibration.Value = 0;
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Calibration images and PIV images must have identical size.','modal');
        return
    end
    view_raw=handles.calib_viewtype.Value;
    if view_raw==1
        view='valid';
    elseif view_raw==2
        view='same';
    elseif view_raw==3
        view='full';
    end
    cam_use_calibration = gui.retr('cam_use_calibration');
    cam_use_rectification = gui.retr('cam_use_rectification');
    cameraParams=gui.retr('cameraParams');
    rectification_tform = gui.retr('rectification_tform');

    expected_image_size_after_camera_calibration = size(preproc.cam_undistort(currentimage,'cubic',view,cam_use_calibration,cam_use_rectification,cameraParams,rectification_tform));
    expected_image_size_after_camera_calibration=expected_image_size_after_camera_calibration(1:2);
    gui.put('expected_image_size',expected_image_size_after_camera_calibration);
else
    if ~isempty(gui.retr('filepath'))
        gui.put('cam_use_calibration',0);
        gui.put('expected_image_size',[]);
        [currentimage,~] = import.get_img(1);
        expected_image_size = size(currentimage);
        expected_image_size=expected_image_size(1:2);
        gui.put('expected_image_size',expected_image_size);
    end
end
gui.toolsavailable(1);
gui.sliderdisp(gui.retr('pivlab_axis'));