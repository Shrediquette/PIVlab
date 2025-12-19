function img_out = cam_undistort(img_in,method)
cam_use_calibration = gui.retr('cam_use_calibration');
handles=gui.gethand;
view_raw=handles.calib_viewtype.Value;
if view_raw==1
    view='valid';
elseif view_raw==2
    view='same';
elseif view_raw==3
    view='full';
end

if cam_use_calibration
    cameraParams=gui.retr('cameraParams');
end
if cam_use_calibration
    if strcmpi (class(cameraParams),'cameraParameters')
        disp(['Size of the incoming image to cam_undistort: ' num2str(size(img_in))])
        disp(['Size of the camera params: ' num2str(cameraParams.ImageSize)]);
        img_out = undistortImage(img_in,cameraParams,method,'OutputView',view);

        disp(['Size of the outgoing image from cam_undistort: ' num2str(size(img_out))])

    elseif strcmpi (class(cameraParams),'fisheyeParameters')
        disp(['Size of the incoming image to cam_undistort: ' num2str(size(img_in))])
        disp(['Size of the camera params: ' num2str(cameraParams.Intrinsics.ImageSize)]);
        img_out = undistortFisheyeImage(img_in,cameraParams.Intrinsics,method,'OutputView',view,'ScaleFactor',2);
        disp(['Size of the outgoing image from cam_undistort: ' num2str(size(img_out))])
    end
else
    img_out=img_in;
end







