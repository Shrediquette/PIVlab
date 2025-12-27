function img_out = cam_undistort(img_in,method)
cam_use_calibration = gui.retr('cam_use_calibration');
cam_use_rectification = gui.retr('cam_use_rectification');
handles=gui.gethand;
view_raw=handles.calib_viewtype.Value;
if view_raw==1
    view='valid';
elseif view_raw==2
    view='same';
elseif view_raw==3
    view='full';
end

%tic
if cam_use_calibration
    cameraParams=gui.retr('cameraParams');
    if strcmpi (class(cameraParams),'cameraParameters')
        %disp(['Size of the incoming image to cam_undistort: ' num2str(size(img_in))])
        %disp(['Size of the camera params: ' num2str(cameraParams.ImageSize)]);
        img_out = undistortImage(img_in,cameraParams,method,'OutputView',view);

        %disp(['Size of the outgoing image from cam_undistort: ' num2str(size(img_out))])

    elseif strcmpi (class(cameraParams),'fisheyeParameters')
        %disp(['Size of the incoming image to cam_undistort: ' num2str(size(img_in))])
        %disp(['Size of the camera params: ' num2str(cameraParams.Intrinsics.ImageSize)]);
        img_out = undistortFisheyeImage(img_in,cameraParams.Intrinsics,method,'OutputView',view,'ScaleFactor',1);
        %disp(['Size of the outgoing image from cam_undistort: ' num2str(size(img_out))])
    end
    if cam_use_rectification
        rectification_tform = gui.retr('rectification_tform');
        img_out = imwarp(img_out,rectification_tform);
        %disp(['Size of the outgoing image from rectify: ' num2str(size(img_out))])
    end
else
    img_out=img_in;
end
%toc







